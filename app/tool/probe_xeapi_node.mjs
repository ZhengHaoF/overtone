// xeapi 参考探针（Node，零依赖）——验证网易云 xeapi 加密通道，抓取「每日指定风格推荐」接口。
//
// 用法:
//   node tool/probe_xeapi_node.mjs
//   node tool/probe_xeapi_node.mjs --cookie "MUSIC_U=xxx; __csrf=yyy"
//
// 对照实现: api-enhanced util/crypto.js + util/request.js 的 xeapi 分支
// （2026-10-03 「xeapi from BSR to CSR」之后的那一版）。
//
// 产出「黄金样本」: 密钥握手结果、请求明文信封、C/S/R 载荷、解密后的响应，
// 供 Dart 侧 (app/lib/core/api/netease/netease_crypto.dart) 逐字节比对。
//
// 注意: 本探针**不写**任何账号状态。`/api/homepage/daily/song/tag/save` 会改
// 服务端的风格设置，这里只做探测不发真实保存请求。

import crypto from 'node:crypto'
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import zlib from 'node:zlib'

const XEAPI_STATIC_KEY = Buffer.from(
  'ab1d5a430f6bb04a3f01e81ddd72bd916d5ce591248ac128714806d7f8fb1b84',
  'hex',
)
// 上游 xeapiSignKey 是**字符串**字面量，HMAC 用的是它的 UTF-8 字节，
// 不是 base64 解码后的字节。
const XEAPI_SIGN_KEY = Buffer.from(
  'mUHCwVNWJbunMqAHf5MImuirT6plvs6VSFW62MGHstFQxhBGdEoIhLItH3djc4+FB/OKty3+lL2rGeoFBpVe5g==',
  'utf8',
)
const EAPI_KEY = Buffer.from('e82ckenh8dichen8', 'utf8')
const X25519_SPKI_PREFIX = Buffer.from('302a300506032b656e032100', 'hex')
// PKCS#8: SEQUENCE { INTEGER 0, SEQUENCE(OID 1.3.101.110), OCTET STRING { OCTET STRING seed } }
const X25519_PKCS8_PREFIX = Buffer.from('302e020100300506032b656e04220420', 'hex')
const UA =
  'NeteaseMusic/9.5.61.260802021928(9005061);Dalvik/2.1.0 (Linux; U; Android 12; HBN-AL00 Build/cd737a2.0)'

const API_DOMAIN = 'https://interface.music.163.com'
const XEAPI_DOMAIN = 'https://interface3.music.163.com'

// 确定性比对用的固定 keyState（服务端每次下发的 sk/publicKey 都不同，
// 想让两边逐字节对齐就必须钉死）。
const FIXTURE_SK = 'FIXTURESK000000000000000'
const FIXTURE_VERSION = '1000000000000'
const FIXTURE_PUBLIC_KEY = 'HdtNLpLo9BKeX3RxtjLTnkI8F0nGHqAcFLs6/fjOsGs='

// ---------------------------------------------------------------- crypto

// 确定性随机源：counter n → sha256('xeapi-det-$n')。
// 与 Dart 侧 probe_xeapi.dart 的 DetRandom 完全一致，两边可逐字节比对 C/S/R。
let detCounter = 0
const detTake = (n) => {
  const out = Buffer.alloc(n)
  let filled = 0
  while (filled < n) {
    const block = crypto.createHash('sha256').update(`xeapi-det-${detCounter}`).digest()
    detCounter++
    const take = Math.min(block.length, n - filled)
    block.copy(out, filled, 0, take)
    filled += take
  }
  return out
}
const makeRand = (det) => ({ take: det ? detTake : (n) => crypto.randomBytes(n) })

const aesEcbEncrypt = (key, plaintext) => {
  const cipher = crypto.createCipheriv(
    `aes-${key.length * 8}-ecb`,
    key,
    Buffer.alloc(0),
  )
  return Buffer.concat([cipher.update(Buffer.from(plaintext)), cipher.final()])
}

const aesEcbDecrypt = (key, ciphertext) => {
  const decipher = crypto.createDecipheriv(
    `aes-${key.length * 8}-ecb`,
    key,
    Buffer.alloc(0),
  )
  return Buffer.concat([decipher.update(ciphertext), decipher.final()])
}

const xeapiSign = (timestamp, nonce) =>
  crypto
    .createHmac('sha256', XEAPI_SIGN_KEY)
    .update(String(timestamp) + nonce)
    .digest('base64')

const xeapiMidTransform = (ciphertext, random) => {
  const rnd = random || crypto.randomBytes(16)
  const xored = Buffer.alloc(ciphertext.length)
  for (let i = 0; i < ciphertext.length; i++) {
    xored[i] = ciphertext[i] ^ rnd[i & 0x0f]
  }
  const rot = xored.length ? (rnd[0] & 0x0f) % xored.length : 0
  return Buffer.concat([rnd, xored.subarray(rot), xored.subarray(0, rot)])
}

const deriveX25519AesKey = (sharedSecret, ephemeralPublicKey) => {
  const prk = crypto
    .createHmac('sha256', Buffer.alloc(32))
    .update(sharedSecret.length ? sharedSecret : Buffer.alloc(32))
    .digest()
  return crypto
    .createHmac('sha256', prk)
    .update(Buffer.concat([ephemeralPublicKey, Buffer.from([1])]))
    .digest()
    .subarray(0, 16)
}

const xeapiEncryptS = (dynamicKey, publicKeyState, os, opts = {}) => {
  const peerRaw = Buffer.from(publicKeyState.publicKey, 'base64')
  const peerKey = crypto.createPublicKey({
    key: Buffer.concat([X25519_SPKI_PREFIX, peerRaw]),
    format: 'der',
    type: 'spki',
  })
  let publicKey
  let privateKey
  if (opts.seed) {
    // 确定性模式：种子直接构造私钥（OpenSSL 内部按 RFC 7748 clamp，
    // 与 Dart 侧 modifiedPrivateKeyBytes 的 clamp 结果一致）。
    privateKey = crypto.createPrivateKey({
      key: Buffer.concat([X25519_PKCS8_PREFIX, opts.seed]),
      format: 'der',
      type: 'pkcs8',
    })
    publicKey = crypto.createPublicKey(privateKey)
  } else {
    ;({ publicKey, privateKey } = crypto.generateKeyPairSync('x25519'))
  }
  const ephemeralRaw = Buffer.from(
    publicKey.export({ format: 'der', type: 'spki' }),
  ).subarray(-32)
  const sharedSecret = crypto.diffieHellman({ privateKey, publicKey: peerKey })
  const aesKey = deriveX25519AesKey(sharedSecret, ephemeralRaw)
  const iv = opts.iv || crypto.randomBytes(12)
  const cipher = crypto.createCipheriv('aes-128-gcm', aesKey, iv)
  const plaintext = Buffer.from(
    `${dynamicKey.toString('base64')}|${os}|${publicKeyState.sk || ''}`,
  )
  const encrypted = Buffer.concat([cipher.update(plaintext), cipher.final()])
  return Buffer.concat([ephemeralRaw, iv, encrypted, cipher.getAuthTag()])
}

const utf8Decoder = new TextDecoder('utf-8', { fatal: true })
const isUtf8 = (buf) => {
  try {
    utf8Decoder.decode(buf)
    return true
  } catch {
    return false
  }
}

const buildXeapiPlaintext = (uri, data, options = {}) => {
  const fields = {}
  const contentType =
    options.contentType || 'application/x-www-form-urlencoded;charset=utf-8'
  const mediaType = contentType.split(';', 1)[0].toLowerCase()
  if (mediaType !== 'application/x-www-form-urlencoded') {
    fields.contentType = contentType
  }

  const method = (options.method || 'POST').toUpperCase()
  if (method !== 'POST') fields.method = method

  const url = new URL(uri, 'https://interface.music.163.com')
  if (url.search) fields.queryString = url.search.slice(1)

  if (data !== undefined && data !== null) {
    const bodyData = { ...data }
    delete bodyData.e_r
    const body = Buffer.from(new URLSearchParams(bodyData).toString())
    if (body.length) {
      if (mediaType === 'application/x-www-form-urlencoded' && isUtf8(body)) {
        fields.content = body.toString('utf8')
      } else {
        fields.body = body.toString('base64')
      }
    }
  }

  fields.queryString = fields.queryString
    ? fields.queryString + '&e_r=true'
    : 'e_r=true'
  return JSON.stringify(fields)
}

const xeapiEncrypt = (uri, data, options = {}) => {
  const publicKeyState = options.publicKeyState
  if (!publicKeyState) throw new Error('xeapi publicKeyState is required')
  const rand = options.rand || makeRand(false)
  const activeSessionKey = options.sessionKey
    ? Buffer.from(String(options.sessionKey))
    : null
  const activeSessionId = options.sessionId || ''
  const dynamicKey = activeSessionKey || rand.take(16)
  const plaintext = Buffer.from(buildXeapiPlaintext(uri, data, options))

  // 随机消耗顺序（与 Dart 侧一致）：dynamicKey 16B → midTransform 16B
  // → X25519 种子 32B → GCM iv 12B。
  const c = aesEcbEncrypt(
    dynamicKey,
    xeapiMidTransform(
      aesEcbEncrypt(XEAPI_STATIC_KEY, plaintext),
      rand.take(16),
    ),
  )
  const s = xeapiEncryptS(dynamicKey, publicKeyState, options.os || 'android', {
    seed: rand.take(32),
    iv: rand.take(12),
  })
  const r = aesEcbEncrypt(
    XEAPI_STATIC_KEY,
    Buffer.from(`${publicKeyState.version}|${activeSessionKey ? activeSessionId : ''}`),
  )

  return {
    C: c.toString('base64url'),
    S: s.toString('base64'),
    R: r.toString('base64'),
  }
}

const xeapiResDecrypt = (body) => {
  const decrypted = aesEcbDecrypt(EAPI_KEY, body)
  const plaintext =
    decrypted[0] === 0x1f && decrypted[1] === 0x8b
      ? zlib.gunzipSync(decrypted)
      : decrypted
  return JSON.parse(plaintext.toString())
}

// ---------------------------------------------------------------- wire

const randomHex = (bytes) => crypto.randomBytes(bytes).toString('hex')

const registerXeapiKey = async (deviceId) => {
  // nonce 必须是 16 位纯数字（上游 generateNonce 用 Math.random()*10），
  // 用十六进制字符会被服务端判 "Invalid signature"。
  const nonce = Array.from(
    { length: 16 },
    () => crypto.randomInt(0, 10).toString(),
  ).join('')
  const timestamp = String(Date.now())
  const body = new URLSearchParams({
    appVersion: '9.5.61',
    currentKeyVersion: '',
    deviceId,
    nonce,
    os: 'android',
    requestType: 'active',
    signature: xeapiSign(timestamp, nonce),
    t1: '',
    t2: '',
    timestamp,
    uid: '',
  }).toString()

  const res = await fetch(`${API_DOMAIN}/api/bsr/sk/get`, {
    method: 'POST',
    headers: {
      'User-Agent': UA,
      'Content-Type': 'application/x-www-form-urlencoded',
      Cookie: `deviceId=${encodeURIComponent(deviceId)}`,
    },
    body,
  })
  const text = await res.text()
  let json
  try {
    json = JSON.parse(text)
  } catch {
    throw new Error(`bsr/sk/get 返回非 JSON: ${res.status} ${text.slice(0, 300)}`)
  }
  if (!json?.data?.encryptedData) {
    throw new Error(
      `bsr/sk/get 失败: code=${json?.code} msg=${json?.msg ?? json?.message}`,
    )
  }
  const publicKey = JSON.parse(
    aesEcbDecrypt(
      XEAPI_STATIC_KEY,
      Buffer.from(json.data.encryptedData, 'base64'),
    ).toString(),
  )
  if (!publicKey.sk) throw new Error('bsr/sk/get 响应缺少 sk')
  return publicKey
}

const cookieToObject = (raw) => {
  const obj = {}
  if (!raw) return obj
  for (const part of raw.split(';')) {
    const trimmed = part.trim()
    if (!trimmed) continue
    const sep = trimmed.indexOf('=')
    if (sep <= 0) continue
    obj[trimmed.slice(0, sep).trim()] = trimmed.slice(sep + 1).trim()
  }
  return obj
}

const cookieObjToString = (cookie) =>
  Object.keys(cookie)
    .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(cookie[k])}`)
    .join('; ')

// 对齐上游 util/request.js 的 processCookieObject + xeapi 分支：
// 默认按 pc osMap 派生，再被 xeapi 分支覆盖 os/osver/appver。
const buildHeaders = ({ deviceId, sDeviceId, cookieObj, buildver }) => {
  const os = 'android'
  const osver = '16'
  const appver = '9.1.65'
  const nuid =
    cookieObj._ntes_nuid ||
    Array.from({ length: 32 }, () =>
      'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)],
    ).join('')
  const wnmcid =
    cookieObj.WNMCID ||
    `${Array.from({ length: 6 }, () =>
      'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)],
    ).join('')}.${Date.now()}.01.0`
  const cookie = {
    __remember_me: 'true',
    ntes_kaola_ad: '1',
    _ntes_nuid: nuid,
    _ntes_nnid: cookieObj._ntes_nnid || `${nuid},${Date.now()}`,
    WNMCID: wnmcid,
    WEVNSM: '1.0.0',
    ...cookieObj,
    os,
    osver,
    appver,
    buildver,
    deviceId,
    sDeviceId: sDeviceId || deviceId,
    channel: cookieObj.channel || 'netease',
  }
  if (!cookie.NMTID) {
    cookie.NMTID = `00O${Array.from({ length: 19 }, () =>
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'[
        Math.floor(Math.random() * 64)
      ],
    ).join('')}`
  }
  if (!cookie.MUSIC_U && !cookie.MUSIC_A) {
    cookie.MUSIC_A = cookieObj.MUSIC_A || ''
  }
  const headers = {
    'User-Agent': UA,
    'X-Client-Enc-State': 'ENCRYPTED',
    'x-aeapi': 'true',
    'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    'x-deviceid': deviceId,
    'x-os': os,
    'x-osver': osver,
    'x-appver': appver,
    'x-sdeviceid': sDeviceId || deviceId,
    'x-buildver': buildver,
    Cookie: cookieObjToString(cookie),
  }
  if (cookie.MUSIC_U) headers['x-music-u'] = cookie.MUSIC_U
  return headers
}

const xeapiRequest = async ({
  path,
  data = {},
  deviceId,
  sDeviceId,
  cookieObj,
  buildver,
  publicKeyState,
  session,
}) => {
  const uri = `/api/${path}`
  const payload = xeapiEncrypt(uri, data, {
    publicKeyState,
    sessionKey: session?.key,
    sessionId: session?.id,
    os: 'android',
  })

  const res = await fetch(`${XEAPI_DOMAIN}/xeapi/${path}`, {
    method: 'POST',
    headers: buildHeaders({ deviceId, sDeviceId, cookieObj, buildver }),
    body: new URLSearchParams(payload).toString(),
  })

  const raw = Buffer.from(await res.arrayBuffer())
  const headers = Object.fromEntries(res.headers.entries())
  let body
  let decrypted = false
  try {
    body = xeapiResDecrypt(raw)
    decrypted = true
  } catch (e) {
    body = { decryptError: String(e), raw: raw.toString('utf8').slice(0, 400) }
  }

  return {
    status: res.status,
    headers,
    setCookies:
      typeof res.headers.getSetCookie === 'function'
        ? res.headers.getSetCookie()
        : [res.headers.get('set-cookie')].filter(Boolean),
    body,
    decrypted,
    envelope: buildXeapiPlaintext(uri, data, { os: 'android' }),
    payload,
  }
}

// ---------------------------------------------------------------- eapi 对照
//
// api-enhanced 的新模块一律用 'xeapi'，但服务端未必认。这里提供 eapi 模式做对照：
// eapi 只需 MD5 盐 + AES-ECB，Overtone 侧已有实现（netease_crypto.dart:141）。
const eapiEncrypt = (url, object) => {
  const text = typeof object === 'object' ? JSON.stringify(object) : object
  const message = `nobody${url}use${text}md5forencrypt`
  const digest = crypto.createHash('md5').update(message).digest('hex')
  const data = `${url}-36cd479b6b5-${text}-36cd479b6b5-${digest}`
  return aesEcbEncrypt(EAPI_KEY, Buffer.from(data)).toString('hex').toUpperCase()
}

const eapiResDecrypt = (hexBody) => {
  const decrypted = aesEcbDecrypt(EAPI_KEY, Buffer.from(hexBody, 'hex'))
  return JSON.parse(decrypted.toString('utf8'))
}

const eapiRequest = async ({
  path,
  data = {},
  deviceId,
  cookieObj,
  buildver,
  realIp,
}) => {
  const uri = `/api/${path}`
  const header = {
    osver: '16',
    deviceId,
    os: 'android',
    appver: '9.5.61',
    versioncode: '140',
    mobilename: '',
    buildver,
    resolution: '1920x1080',
    __csrf: cookieObj.__csrf ?? '',
    channel: 's_hidemenu',
    requestId: `${Date.now()}_${Math.floor(Math.random() * 1000)}`,
  }
  if (cookieObj.MUSIC_U) header.MUSIC_U = cookieObj.MUSIC_U
  if (cookieObj.MUSIC_A) header.MUSIC_A = cookieObj.MUSIC_A
  if (cookieObj.NMTID) header.NMTID = cookieObj.NMTID

  const params = eapiEncrypt(uri, { ...data, header })
  const extraHeaders = {}
  if (realIp) {
    extraHeaders['X-Real-IP'] = realIp
    extraHeaders['X-Forwarded-For'] = realIp
  }
  const res = await fetch(
    `https://interfacepc.music.163.com/eapi/${path}`,
    {
      method: 'POST',
      headers: {
        'User-Agent': UA,
        'content-type': 'application/x-www-form-urlencoded',
        Cookie: Object.keys(header)
          .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(header[k])}`)
          .join('; '),
        ...extraHeaders,
      },
      body: new URLSearchParams({ params }).toString(),
    },
  )
  const text = await res.text()
  let body
  try {
    body = JSON.parse(text)
  } catch {
    try {
      body = eapiResDecrypt(text.trim())
    } catch {
      body = { parseError: true, raw: text.slice(0, 300) }
    }
  }
  const setCookie = res.headers.getSetCookie?.() ?? []
  return { status: res.status, body, params, setCookie }
}

// ---------------------------------------------------------------- 扫码登录
//
// 上游 api-enhanced 的 login_qr_key / login_qr_check 用的是**未加密的 api** 通道
// （createOption(query) → crypto='' → 落到 'api' 分支）：
//   POST https://interface.music.163.com/api/login/qrcode/unikey       {type:3}
//   POST https://interface.music.163.com/api/login/qrcode/client/login {key,type:3}
// 二维码内容是 https://music.163.com/login?codekey=<key>&chainId=<chainId>
//
// 注意：走 weapi（type=1 + /api/login/qr/check）现在会被判 8821
// 「请切换其他登录方式或升级新版本再试」；eapi 也不稳。
const plainRequest = async ({
  path,
  data = {},
  deviceId,
  cookieObj,
  buildver,
}) => {
  const header = {
    osver: '16',
    deviceId,
    os: 'android',
    appver: '9.1.65',
    versioncode: '140',
    mobilename: '',
    buildver,
    resolution: '1920x1080',
    __csrf: cookieObj.__csrf ?? '',
    channel: 'netease',
    requestId: `${Date.now()}_${Math.floor(Math.random() * 1000)}`,
  }
  if (cookieObj.MUSIC_U) header.MUSIC_U = cookieObj.MUSIC_U
  if (cookieObj.MUSIC_A) header.MUSIC_A = cookieObj.MUSIC_A

  const body = new URLSearchParams({ ...data, e_r: 'false' }).toString()
  const res = await fetch(`${API_DOMAIN}/api/${path}`, {
    method: 'POST',
    headers: {
      'User-Agent': 'NeteaseMusic 9.0.90/5038 (iPhone; iOS 16.2; zh_CN)',
      'content-type': 'application/x-www-form-urlencoded',
      Referer: 'https://music.163.com',
      Cookie: Object.keys(header)
        .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(header[k])}`)
        .join('; '),
    },
    body,
  })
  const text = await res.text()
  let parsed
  try {
    parsed = JSON.parse(text)
  } catch {
    parsed = { parseError: true, raw: text.slice(0, 300) }
  }
  return {
    status: res.status,
    body: parsed,
    setCookie:
      typeof res.headers.getSetCookie === 'function'
        ? res.headers.getSetCookie()
        : [res.headers.get('set-cookie')].filter(Boolean),
  }
}

const qrLogin = async ({ buildver, timeoutMs = 300000 }) => {
  const deviceId = generateDeviceId()
  const unikeyRes = await plainRequest({
    path: 'login/qrcode/unikey',
    data: { type: 3 },
    deviceId,
    cookieObj: {},
    buildver,
  })
  const unikey = unikeyRes.body?.unikey
  if (!unikey) throw new Error('取 unikey 失败: ' + JSON.stringify(unikeyRes.body))
  const chainId = `v1_unknown-${Math.floor(Math.random() * 1e6)}_web_login_${Date.now()}`
  const qrUrl = `https://music.163.com/login?codekey=${unikey}&chainId=${chainId}`
  console.log(`\n请在手机浏览器打开下面的链接并确认登录（${timeoutMs / 1000}s 内有效）：`)
  console.log(qrUrl)

  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, 2500))
    const r = await plainRequest({
      path: 'login/qrcode/client/login',
      data: { key: unikey, type: 3 },
      deviceId,
      cookieObj: {},
      buildver,
    })
    const code = r.body?.code
    if (code === 800) continue // 等待扫码
    if (code === 801) {
      console.log('已扫码，等待手机端确认…')
      continue
    }
    if (code === 802) {
      const cookie = {}
      for (const sc of r.setCookie) {
        Object.assign(cookie, cookieToObject(String(sc).split(';')[0] || ''))
      }
      console.log('登录成功，cookie 字段: ' + Object.keys(cookie).join(', '))
      return { cookie, deviceId }
    }
    if (code === 803) throw new Error('二维码已过期')
    throw new Error('扫码登录异常: ' + JSON.stringify(r.body))
  }
  throw new Error('扫码登录超时')
}

// ---------------------------------------------------------------- main

const parseArgs = () => {
  const args = { paths: [] }
  for (let i = 2; i < process.argv.length; i++) {
    const raw = process.argv[i]
    if (!raw.startsWith('--')) continue
    const key = raw.slice(2)
    const next = process.argv[i + 1]
    if (next === undefined || next.startsWith('--')) {
      args[key] = true
      continue
    }
    i++
    if (key === 'path') args.paths.push(next)
    else args[key] = next
  }
  return args
}

const TARGETS = [
  { path: 'homepage/daily/song/config/get', data: {}, label: '每日风格列表' },
  {
    path: 'homepage/category/daily/song/list',
    data: {},
    label: '每日风格歌曲',
  },
  {
    path: 'v3/discovery/recommend/songs',
    data: { ispush: false },
    label: '每日推荐歌曲(xeapi)',
  },
]

// 游客设备注册：deviceId 是 52 位大写十六进制，username = base64("<deviceId> <md5base64>")
// md5base64 = MD5(deviceId 与固定盐逐字符异或后的字符串)，对齐 module/register_anonimous.js。
const ID_XOR_KEY_1 = '3go8&$8*3*3h0k(2)2'

const generateDeviceId = () => {
  const hexChars = '0123456789ABCDEF'
  let out = ''
  for (let i = 0; i < 52; i++) {
    out += hexChars[crypto.randomInt(0, 16)]
  }
  return out
}

const cloudmusicDllEncodeId = (deviceId) => {
  let xored = ''
  for (let i = 0; i < deviceId.length; i++) {
    const code =
      deviceId.charCodeAt(i) ^ ID_XOR_KEY_1.charCodeAt(i % ID_XOR_KEY_1.length)
    xored += String.fromCharCode(code)
  }
  return crypto.createHash('md5').update(Buffer.from(xored, 'utf8')).digest('base64')
}

const registerAnonymous = async (ctx) => {
  const deviceId = generateDeviceId()
  const username = Buffer.from(
    `${deviceId} ${cloudmusicDllEncodeId(deviceId)}`,
    'utf8',
  ).toString('base64')

  const r = await xeapiRequest({
    path: 'register/anonimous',
    data: { username },
    deviceId,
    sDeviceId: deviceId,
    cookieObj: {},
    buildver: ctx.buildver,
    publicKeyState: ctx.publicKeyState,
    session: ctx.session,
  })

  // 服务端可能下发多个 Set-Cookie（游客态的 MUSIC_U/MUSIC_A 常在第 2 条以后），
  // 必须逐条取 k=v 再合并，否则只会拿到第一个 cookie。
  const guest = {}
  for (const sc of r.setCookies) {
    Object.assign(guest, cookieToObject(String(sc).split(';')[0] || ''))
  }
  console.log('  [raw set-cookie] ' + JSON.stringify(r.setCookies))
  return { deviceId, guest, body: r.body, status: r.status }
}

const main = async () => {
  const args = parseArgs()
  const mode = args.mode || 'xeapi'
  const buildver = new Date().toISOString().slice(0, 10).replace(/-/g, '')
  const targets = args.paths.length
    ? args.paths.map((p) => ({
        path: p,
        data: args.data ? JSON.parse(args.data) : {},
        label: p,
      }))
    : TARGETS

  // ── 确定性模式：固定 keyState + 固定随机源，输出可直接与 Dart 侧逐字节比对 ──
  if (args.det) {
    const path = args.path || 'v3/discovery/recommend/songs'
    const data = path.includes('recommend/songs') ? { ispush: false } : {}
    const publicKeyState = {
      sk: FIXTURE_SK,
      version: FIXTURE_VERSION,
      publicKey: FIXTURE_PUBLIC_KEY,
    }
    const rand = makeRand(true)
    const uri = `/api/${path}`
    const payload = xeapiEncrypt(uri, data, { publicKeyState, rand })
    console.log('=== det 模式（固定 keyState + 确定性随机源）===')
    console.log(`[det] envelope=${buildXeapiPlaintext(uri, data)}`)
    console.log(`[det] C=${payload.C}`)
    console.log(`[det] S=${payload.S}`)
    console.log(`[det] R=${payload.R}`)
    return
  }

  let cookieObj = cookieToObject(args.cookie)
  if (args['cookie-file']) {
    cookieObj = {
      ...cookieObj,
      ...cookieToObject(readFileSync(args['cookie-file'], 'utf8').trim()),
    }
    console.log(`(从文件读入 cookie 字段: ${Object.keys(cookieObj).join(', ')})`)
  }
  let deviceId = args.device || generateDeviceId()

  if (args.qr) {
    console.log('=== 扫码登录 (api, type=3) ===')
    const q = await qrLogin({ buildver })
    cookieObj = { ...cookieObj, ...q.cookie }
    deviceId = q.deviceId
    if (args['save-cookie']) {
      writeFileSync(
        args['save-cookie'],
        Object.entries(cookieObj)
          .map(([k, v]) => `${k}=${v}`)
          .join('; '),
      )
      console.log('(已保存 cookie 到 ' + args['save-cookie'] + ')')
    }
  }

  if (mode === 'eapi') {
    console.log('=== 模式: eapi (https://interfacepc.music.163.com/eapi/*) ===')
    let cookie = { ...cookieObj }
    const realIp =
      args.realip === 'rand'
        ? `${[120, 117, 116, 223, 42, 183, 36][crypto.randomInt(0, 7)]}.` +
          `${crypto.randomInt(0, 256)}.${crypto.randomInt(0, 256)}.${crypto.randomInt(1, 255)}`
        : args.realip
    if (realIp) console.log(`(X-Real-IP: ${realIp})`)

    // 没有登录态时先注册游客设备
    if (!cookie.MUSIC_U && !cookie.MUSIC_A) {
      const anon = await eapiRequest({
        path: 'register/anonimous',
        data: {
          username: Buffer.from(
            `${deviceId} ${cloudmusicDllEncodeId(deviceId)}`,
            'utf8',
          ).toString('base64'),
        },
        deviceId,
        cookieObj: cookie,
        buildver,
        realIp,
      })
      console.log('\n--- 游客注册 POST /eapi/register/anonimous ---')
      console.log(
        `http=${anon.status} code=${anon.body?.code} ${anon.body?.message ?? ''}`,
      )
      for (const sc of anon.setCookie) {
        Object.assign(cookie, cookieToObject(sc.split(';')[0] || ''))
      }
      console.log('cookie 字段: ' + Object.keys(cookie).join(', '))
      if (args['save-cookie']) {
        writeFileSync(
          args['save-cookie'],
          Object.entries(cookie)
            .map(([k, v]) => `${k}=${v}`)
            .join('; '),
          'utf8',
        )
        console.log('(已保存 cookie 到 ' + args['save-cookie'] + ')')
      }
      if (args.dump) {
        mkdirSync(args.dump, { recursive: true })
        writeFileSync(
          `${args.dump}/_guest_cookie.json`,
          JSON.stringify(cookie, null, 2),
          'utf8',
        )
        writeFileSync(
          `${args.dump}/_guest_register.json`,
          JSON.stringify(anon.body, null, 2),
          'utf8',
        )
      }
      if (args['register-only']) return
    }

    for (const target of targets) {
      console.log(`\n--- ${target.label}  POST /eapi/${target.path} ---`)
      const r = await eapiRequest({
        path: target.path,
        data: target.data,
        deviceId,
        cookieObj: cookie,
        buildver,
        realIp,
      })
      console.log(`http=${r.status}`)
      console.log('body=' + JSON.stringify(r.body).slice(0, 1500))
      if (args.dump) {
        mkdirSync(args.dump, { recursive: true })
        const safe = target.path.replace(/[^a-z0-9]+/gi, '_')
        writeFileSync(
          `${args.dump}/${safe}.json`,
          JSON.stringify(r.body, null, 2),
          'utf8',
        )
      }
    }
    return
  }

  const ctx = { buildver, session: { id: '', key: '' } }

  console.log('=== 1. 密钥握手 POST /api/bsr/sk/get ===')
  ctx.publicKeyState = await registerXeapiKey(generateDeviceId())
  console.log(
    `sk=${ctx.publicKeyState.sk} version=${ctx.publicKeyState.version} ` +
      `publicKeyLen=${Buffer.from(ctx.publicKeyState.publicKey, 'base64').length}`,
  )

  console.log('\n=== 2. 游客设备注册 POST /xeapi/register/anonimous ===')
  const anon = await registerAnonymous(ctx)
  console.log(`deviceId=${anon.deviceId} http=${anon.status}`)
  console.log('code=' + (anon.body?.code ?? '?') + ' ' + (anon.body?.message ?? ''))
  console.log('guestCookie=' + JSON.stringify(anon.guest))
  ctx.deviceId = anon.deviceId
  ctx.sDeviceId = anon.deviceId

  // 用户 cookie 优先覆盖游客 cookie
  const merged = { ...anon.guest, ...cookieObj }
  console.log(`\n(合并 cookie 字段: ${Object.keys(merged).join(', ')})`)

  for (const target of targets) {
    console.log(`\n=== 3. ${target.label}  POST /xeapi/${target.path} ===`)
    const r = await xeapiRequest({
      path: target.path,
      data: target.data,
      deviceId: ctx.deviceId,
      sDeviceId: ctx.sDeviceId,
      cookieObj: merged,
      buildver,
      publicKeyState: ctx.publicKeyState,
      session: ctx.session,
    })
    console.log(`http=${r.status} decrypted=${r.decrypted}`)
    console.log(`envelope=${r.envelope}`)
    console.log(`C=${r.payload.C}`)
    console.log(`R=${r.payload.R}`)
    console.log('body=' + JSON.stringify(r.body).slice(0, 1500))
    if (r.headers['x-encr-ssid'] && r.headers['x-encr-sskey']) {
      ctx.session = {
        id: r.headers['x-encr-ssid'],
        key: r.headers['x-encr-sskey'],
      }
    }
  }
}

main().catch((e) => {
  console.error('PROBE FAILED:', e?.message ?? e)
  process.exitCode = 1
})
