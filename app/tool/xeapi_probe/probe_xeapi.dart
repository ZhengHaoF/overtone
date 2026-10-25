// Dart 侧 xeapi 复刻探针。
//
// 目的：验证「Dart 能否逐字节复刻 Node 参考实现」，从而判定 Overtone 未来要不要
// 引入 xeapi 时有没有不可逾越的技术障碍。
//
// 对照实现：api-enhanced `util/crypto.js` + `util/request.js` 的 xeapi 分支
// （2026-10-03「xeapi from BSR to CSR」之后那一版）。
//
// 用法：
//   dart run tool/xeapi_probe/probe_xeapi.dart                 # 真实握手 + 真实请求
//   dart run tool/xeapi_probe/probe_xeapi.dart --det           # 确定性随机源，供跨语言逐字节比对
//   dart run tool/xeapi_probe/probe_xeapi.dart --path homepage/daily/song/config/get
//
// 依赖是独立的（cryptography 提供 X25519；PointyCastle 没有 X25519，也没有 Curve25519）。

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' as pc;

// ── 协议常量（来自 api-enhanced util/crypto.js，改动即失效）─────────────

/// 32 字节静态密钥 → AES-256-ECB。
final Uint8List kXeapiStaticKey = Uint8List.fromList(
  hexDecode(
    'ab1d5a430f6bb04a3f01e81ddd72bd916d5ce591248ac128714806d7f8fb1b84',
  ),
);

/// 签名密钥是**字符串字面量**，HMAC 用它的 UTF-8 字节（不是 base64 解码）。
const String kXeapiSignKey =
    'mUHCwVNWJbunMqAHf5MImuirT6plvs6VSFW62MGHstFQxhBGdEoIhLItH3djc4+FB/OKty3+lL2rGeoFBpVe5g==';

/// 响应解密密钥 → AES-128-ECB。
final Uint8List kEapiKey = Uint8List.fromList(utf8.encode('e82ckenh8dichen8'));

const String kApiDomain = 'https://interface.music.163.com';
const String kXeapiDomain = 'https://interface3.music.163.com';
const String kUserAgent =
    'NeteaseMusic/9.5.61.260802021928(9005061);Dalvik/2.1.0 (Linux; U; Android 12; HBN-AL00 Build/cd737a2.0)';

// 确定性比对用的固定 keyState（服务端每次下发的 sk/publicKey 都不同，
// 想让两边逐字节对齐就必须钉死）。必须与 Node 侧 probe_xeapi_node.mjs 一致。
const String kFixtureSk = 'FIXTURESK000000000000000';
const String kFixtureVersion = '1000000000000';
const String kFixturePublicKey = 'HdtNLpLo9BKeX3RxtjLTnkI8F0nGHqAcFLs6/fjOsGs=';

Uint8List hexDecode(String s) => Uint8List.fromList(
  List<int>.generate(
    s.length ~/ 2,
    (i) => int.parse(s.substring(i * 2, i * 2 + 2), radix: 16),
  ),
);

// ── 随机源 ────────────────────────────────────────────────────────────

/// 确定性字节流：counter n → sha256('xeapi-det-$n')。
/// Node 侧用同一算法，两边即可逐字节比对 C/S/R。
class DetRandom {
  int _counter = 0;

  Uint8List take(int n) {
    final out = Uint8List(n);
    var filled = 0;
    while (filled < n) {
      final block = crypto.sha256.convert(utf8.encode('xeapi-det-$_counter')).bytes;
      _counter++;
      final take = min(block.length, n - filled);
      out.setRange(filled, filled + take, block);
      filled += take;
    }
    return out;
  }
}

/// 随机源抽象：det 模式走确定性流，否则走安全随机。
class Rand {
  Rand.det() : _det = DetRandom();
  Rand.secure() : _det = null;

  final DetRandom? _det;
  final Random _secure = Random.secure();

  Uint8List take(int n) {
    final d = _det;
    if (d != null) return d.take(n);
    final out = Uint8List(n);
    for (var i = 0; i < n; i++) {
      out[i] = _secure.nextInt(256);
    }
    return out;
  }
}

// ── 基础密码学 ────────────────────────────────────────────────────────

/// AES-ECB 加密（PKCS#7 填充）。key 长度决定 AES-128/256。
Uint8List aesEcbEncrypt(Uint8List key, List<int> data) {
  final cipher = pc.PaddedBlockCipherImpl(
    pc.PKCS7Padding(),
    pc.ECBBlockCipher(pc.AESEngine()),
  );
  cipher.init(
    true,
    pc.PaddedBlockCipherParameters<pc.CipherParameters, pc.CipherParameters>(
      pc.KeyParameter(key),
      null,
    ),
  );
  return cipher.process(Uint8List.fromList(data));
}

Uint8List aesEcbDecrypt(Uint8List key, List<int> data) {
  final cipher = pc.PaddedBlockCipherImpl(
    pc.PKCS7Padding(),
    pc.ECBBlockCipher(pc.AESEngine()),
  );
  cipher.init(
    false,
    pc.PaddedBlockCipherParameters<pc.CipherParameters, pc.CipherParameters>(
      pc.KeyParameter(key),
      null,
    ),
  );
  return cipher.process(Uint8List.fromList(data));
}

/// AES-128-GCM。**Node 的 GCM 不自动填充**（实测 autoPadding 开关输出相同），
/// PointyCastle 的 `process()` 同样直接给出 `ciphertext || tag`（无填充）。
Uint8List aesGcmEncrypt(Uint8List key, Uint8List iv, List<int> data) {
  final cipher = pc.GCMBlockCipher(pc.AESEngine());
  cipher.init(
    true,
    pc.AEADParameters<pc.CipherParameters>(
      pc.KeyParameter(key),
      128,
      iv,
      Uint8List(0),
    ),
  );
  return cipher.process(Uint8List.fromList(data));
}

/// application/x-www-form-urlencoded 序列化（对齐 JS 的 URLSearchParams）。
String formEncode(Map<String, String> params) => params.entries
    .map((e) => '${formEscape(e.key)}=${formEscape(e.value)}')
    .join('&');

String formEscape(String s) {
  final sb = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    final unreserved =
        (rune >= 0x41 && rune <= 0x5a) ||
        (rune >= 0x61 && rune <= 0x7a) ||
        (rune >= 0x30 && rune <= 0x39) ||
        '*-._'.contains(ch);
    if (unreserved) {
      sb.write(ch);
    } else if (rune == 0x20) {
      sb.write('+');
    } else {
      sb.write('%${rune.toRadixString(16).toUpperCase().padLeft(2, '0')}');
    }
  }
  return sb.toString();
}

/// base64url 且**不带 padding**（对齐 Node 的 toString('base64url')）。
String base64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// Cookie 头拼装：`k=v; k2=v2`（对齐 Node 的 cookieObjToString）。
/// 注意**不能**用 formEncode——那是 `&` 分隔的查询串格式。
String cookieHeader(Map<String, String> cookie) => cookie.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .join('; ');

const String _alphaChars = 'abcdefghijklmnopqrstuvwxyz';
const String _nmtidChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

String _randAlpha(int n) {
  final r = Random.secure();
  return List.generate(n, (_) => _alphaChars[r.nextInt(26)]).join();
}

String _randNmtid(int n) {
  final r = Random.secure();
  return List.generate(n, (_) => _nmtidChars[r.nextInt(64)]).join();
}

// ── xeapi 核心 ───────────────────────────────────────────────────────

/// 请求明文信封。字段顺序与 JSON 序列化顺序都要与 Node 一致。
String buildEnvelope(String uri, Map<String, String> data) {
  final fields = <String, String>{};
  final url = Uri.parse(uri);
  if (url.hasQuery) fields['queryString'] = url.query;
  if (data.isNotEmpty) {
    final body = formEncode(data);
    if (body.isNotEmpty) fields['content'] = body;
  }
  fields['queryString'] = fields.containsKey('queryString')
      ? '${fields['queryString']}&e_r=true'
      : 'e_r=true';
  return jsonEncode(fields);
}

/// XOR 混淆 + 循环移位（对齐 xeapiMidTransform）。
Uint8List midTransform(Uint8List ciphertext, Uint8List random) {
  final xored = Uint8List(ciphertext.length);
  for (var i = 0; i < ciphertext.length; i++) {
    xored[i] = ciphertext[i] ^ random[i & 0x0f];
  }
  final rot = xored.isEmpty ? 0 : (random[0] & 0x0f) % xored.length;
  return Uint8List.fromList([
    ...random,
    ...xored.sublist(rot),
    ...xored.sublist(0, rot),
  ]);
}

/// 从共享密钥派生 AES-128 密钥（HMAC 两级）。
Uint8List deriveX25519AesKey(Uint8List sharedSecret, Uint8List ephemeral) {
  final prk = crypto.Hmac(crypto.sha256, Uint8List(32)).convert(sharedSecret).bytes;
  return Uint8List.fromList(
    crypto.Hmac(crypto.sha256, prk).convert([...ephemeral, 1]).bytes.sublist(0, 16),
  );
}

class XeapiKeyState {
  XeapiKeyState({
    required this.sk,
    required this.publicKey,
    required this.version,
  });

  final String sk;
  final Uint8List publicKey;
  final String version;
}

/// 生成 C / S / R 三段载荷。
///
/// 随机消耗顺序（与 Node 对齐，det 模式逐字节可比）：
///   1. dynamicKey  16B
///   2. midTransform 16B
///   3. X25519 种子  32B
///   4. GCM iv       12B
Future<Map<String, String>> xeapiEncrypt({
  required String uri,
  required Map<String, String> data,
  required XeapiKeyState keyState,
  required Rand rand,
  String sessionKey = '',
  String sessionId = '',
  String os = 'android',
}) async {
  final dynamicKey = sessionKey.isNotEmpty
      ? Uint8List.fromList(utf8.encode(sessionKey))
      : rand.take(16);
  final plaintext = Uint8List.fromList(utf8.encode(buildEnvelope(uri, data)));

  // C
  final mid = midTransform(
    aesEcbEncrypt(kXeapiStaticKey, plaintext),
    rand.take(16),
  );
  final c = aesEcbEncrypt(dynamicKey, mid);

  // S：X25519 ECDH + AES-128-GCM
  final alg = X25519();
  final seed = rand.take(32);
  final keyPair = await alg.newKeyPairFromSeed(seed);
  final publicKey = await keyPair.extractPublicKey();
  final ephemeral = Uint8List.fromList(publicKey.bytes);
  final shared = await alg.sharedSecretKey(
    keyPair: keyPair,
    remotePublicKey: SimplePublicKey(
      keyState.publicKey,
      type: KeyPairType.x25519,
    ),
  );
  final sharedSecret = Uint8List.fromList(await shared.extractBytes());
  final aesKey = deriveX25519AesKey(sharedSecret, ephemeral);
  final iv = rand.take(12);
  final sPlain = utf8.encode('${base64.encode(dynamicKey)}|$os|${keyState.sk}');
  final sEnc = aesGcmEncrypt(aesKey, iv, sPlain);
  final s = Uint8List.fromList([...ephemeral, ...iv, ...sEnc]);

  // R
  final r = aesEcbEncrypt(
    kXeapiStaticKey,
    utf8.encode(
      '${keyState.version}|${sessionKey.isNotEmpty ? sessionId : ''}',
    ),
  );

  return {
    'C': base64UrlNoPad(c),
    'S': base64.encode(s),
    'R': base64.encode(r),
  };
}

/// 响应解密：AES-128-ECB(eapiKey) → 可选 gunzip → JSON。
Map<String, dynamic> xeapiResDecrypt(Uint8List body) {
  var plain = aesEcbDecrypt(kEapiKey, body);
  if (plain.length >= 2 && plain[0] == 0x1f && plain[1] == 0x8b) {
    plain = Uint8List.fromList(ZLibCodec().decode(plain));
  }
  return jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
}

// ── 网络 ──────────────────────────────────────────────────────────────

String generateNonce() {
  final r = Random.secure();
  return List.generate(16, (_) => r.nextInt(10)).join();
}

String generateDeviceId() {
  const hex = '0123456789ABCDEF';
  final r = Random.secure();
  return List.generate(52, (_) => hex[r.nextInt(16)]).join();
}

/// 密钥握手：POST /api/bsr/sk/get。
Future<XeapiKeyState> registerXeapiKey(String deviceId) async {
  final nonce = generateNonce();
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final signature = base64.encode(
    crypto.Hmac(crypto.sha256, utf8.encode(kXeapiSignKey))
        .convert(utf8.encode('$timestamp$nonce'))
        .bytes,
  );
  final body = formEncode({
    'appVersion': '9.5.61',
    'currentKeyVersion': '',
    'deviceId': deviceId,
    'nonce': nonce,
    'os': 'android',
    'requestType': 'active',
    'signature': signature,
    't1': '',
    't2': '',
    'timestamp': timestamp,
    'uid': '',
  });

  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('$kApiDomain/api/bsr/sk/get'));
  req.headers.set(HttpHeaders.userAgentHeader, kUserAgent);
  req.headers.contentType = ContentType(
    'application',
    'x-www-form-urlencoded',
    charset: 'utf-8',
  );
  req.write(body);
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  client.close();

  final json = jsonDecode(text) as Map<String, dynamic>;
  final data = json['data'] as Map<String, dynamic>?;
  final encrypted = data?['encryptedData'] as String?;
  if (encrypted == null) {
    throw StateError('bsr/sk/get 失败: $text');
  }
  final decoded = jsonDecode(
    utf8.decode(aesEcbDecrypt(kXeapiStaticKey, base64.decode(encrypted))),
  ) as Map<String, dynamic>;
  return XeapiKeyState(
    sk: decoded['sk'] as String,
    publicKey: base64.decode(decoded['publicKey'] as String),
    version: '${decoded['version']}',
  );
}

/// 发起一次 xeapi 请求，返回 (解密后 JSON, 响应头, HTTP 状态码)。
Future<(Map<String, dynamic>, Map<String, String>, int)> xeapiRequest({
  required String path,
  required Map<String, String> data,
  required XeapiKeyState keyState,
  required String deviceId,
  required Rand rand,
  Map<String, String> cookie = const {},
  String sessionKey = '',
  String sessionId = '',
}) async {
  final uri = '/api/$path';
  final payload = await xeapiEncrypt(
    uri: uri,
    data: data,
    keyState: keyState,
    rand: rand,
    sessionKey: sessionKey,
    sessionId: sessionId,
  );

  final buildver = DateTime.now()
      .toIso8601String()
      .substring(0, 10)
      .replaceAll('-', '');
  // 对齐上游 util/request.js 的 processCookieObject + xeapi 分支。
  final nuid = cookie['_ntes_nuid'] ?? _randAlpha(32);
  final cookieObj = <String, String>{
    '__remember_me': 'true',
    'ntes_kaola_ad': '1',
    '_ntes_nuid': nuid,
    '_ntes_nnid': cookie['_ntes_nnid'] ?? '$nuid,${DateTime.now().millisecondsSinceEpoch}',
    'WNMCID': cookie['WNMCID'] ?? '${_randAlpha(6)}.${DateTime.now().millisecondsSinceEpoch}.01.0',
    'WEVNSM': '1.0.0',
    ...cookie,
    'os': 'android',
    'osver': '16',
    'appver': '9.1.65',
    'buildver': buildver,
    'deviceId': deviceId,
    'sDeviceId': deviceId,
    'channel': cookie['channel'] ?? 'netease',
  };
  cookieObj.putIfAbsent(
    'NMTID',
    () => '00O${_randNmtid(19)}',
  );
  final headers = <String, String>{
    'User-Agent': kUserAgent,
    'X-Client-Enc-State': 'ENCRYPTED',
    'x-aeapi': 'true',
    'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    'x-deviceid': deviceId,
    'x-os': 'android',
    'x-osver': '16',
    'x-appver': '9.1.65',
    'x-sdeviceid': deviceId,
    'x-buildver': buildver,
    'Cookie': cookieHeader(cookieObj),
  };
  if (cookieObj['MUSIC_U'] != null) {
    headers['x-music-u'] = cookieObj['MUSIC_U']!;
  }

  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('$kXeapiDomain/xeapi/$path'));
  headers.forEach(req.headers.set);
  req.write(formEncode(payload));
  final res = await req.close();
  final bytes = await res.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
  final respHeaders = <String, String>{};
  res.headers.forEach((k, v) => respHeaders[k.toLowerCase()] = v.join(', '));
  client.close();

  Map<String, dynamic> body;
  try {
    body = xeapiResDecrypt(Uint8List.fromList(bytes));
  } catch (e) {
    body = {
      'decryptError': '$e',
      'raw': utf8.decode(bytes, allowMalformed: true),
    };
  }
  return (body, respHeaders, res.statusCode);
}

// ── main ──────────────────────────────────────────────────────────────

Future<void> main(List<String> args) async {
  final det = args.contains('--det');
  final pathIndex = args.indexOf('--path');
  final path = pathIndex >= 0 && pathIndex + 1 < args.length
      ? args[pathIndex + 1]
      : 'v3/discovery/recommend/songs';
  final data = path.contains('recommend/songs')
      ? {'ispush': 'false'}
      : <String, String>{};

  final cookie = <String, String>{};
  final cookieIndex = args.indexOf('--cookie');
  if (cookieIndex >= 0 && cookieIndex + 1 < args.length) {
    for (final part in args[cookieIndex + 1].split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final sep = trimmed.indexOf('=');
      if (sep <= 0) continue;
      cookie[trimmed.substring(0, sep).trim()] = trimmed.substring(sep + 1).trim();
    }
  }

  final rand = det ? Rand.det() : Rand.secure();
  print('=== Dart xeapi 探针 · det=$det path=$path ===');

  // ── 确定性模式：固定 keyState + 固定随机源，与 Node 侧逐字节比对 ──
  if (det) {
    final keyState = XeapiKeyState(
      sk: kFixtureSk,
      publicKey: base64.decode(kFixturePublicKey),
      version: kFixtureVersion,
    );
    final payload = await xeapiEncrypt(
      uri: '/api/$path',
      data: data,
      keyState: keyState,
      rand: rand,
    );
    print('=== det 模式（固定 keyState + 确定性随机源）===');
    print('[det] envelope=${buildEnvelope('/api/$path', data)}');
    print('[det] C=${payload['C']}');
    print('[det] S=${payload['S']}');
    print('[det] R=${payload['R']}');
    return;
  }

  final deviceId = generateDeviceId();
  print('[1] 握手 POST /api/bsr/sk/get …');
  final keyState = await registerXeapiKey(deviceId);
  print(
    '[1] sk=${keyState.sk} version=${keyState.version} '
    'publicKeyLen=${keyState.publicKey.length}',
  );

  print('[2] 构造 C/S/R …');
  final payload = await xeapiEncrypt(
    uri: '/api/$path',
    data: data,
    keyState: keyState,
    rand: rand,
  );
  print('[2] envelope=${buildEnvelope('/api/$path', data)}');
  print('[2] C=${payload['C']}');
  print('[2] S=${payload['S']}');
  print('[2] R=${payload['R']}');

  print('[3] 请求 POST /xeapi/$path …');
  final (body, headers, status) = await xeapiRequest(
    path: path,
    data: data,
    keyState: keyState,
    deviceId: deviceId,
    rand: rand,
    cookie: cookie,
  );
  final ssid = headers['x-encr-ssid'];
  final sskey = headers['x-encr-sskey'];
  print('[3] status=$status sessionId=${ssid ?? '-'} sskey=${sskey ?? '-'}');
  final text = jsonEncode(body);
  print('[3] body=${text.length > 900 ? text.substring(0, 900) : text}');

  // 会话复用：第二次请求带上响应头给的 ssid/sskey，R 应随之变化且服务端仍认。
  if (ssid != null && sskey != null) {
    print('[4] 复用会话再请求一次 …');
    final (body2, headers2, status2) = await xeapiRequest(
      path: path,
      data: data,
      keyState: keyState,
      deviceId: deviceId,
      rand: rand,
      cookie: cookie,
      sessionKey: sskey,
      sessionId: ssid,
    );
    final t2 = jsonEncode(body2);
    print('[4] status=$status2 body=${t2.length > 300 ? t2.substring(0, 300) : t2}');
  }

  print('== done ==');
}
