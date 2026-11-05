#include <flutter/runtime_effect.glsl>

// 液态玻璃的折射 + 色散片元着色器。
//
// 用法：作为 ImageFilter.shader 传给 BackdropFilter 的 filter，配合
// ImageFilter.compose(blur / 饱和度矩阵) 一起用，见
// lib/shared/widgets/liquid_glass.dart。
//
// 引擎约定（见 sky_engine/lib/ui/painting.dart `ImageFilter.shader`）：
//   - 第一个 uniform 必须是 vec2，引擎写入「输入纹理尺寸」；
//   - 至少一个 sampler2D，第一个由引擎绑定为 filter input（期望是背板快照）；
//   - GLES 后端 y 轴反转，必须自己翻。
//
// 本文件只做几何位移，不做模糊、不做饱和 —— 那两步由 ImageFilter 链完成，
// 与对照稿 `url(#svg) blur() saturate() contrast()` 的顺序一致。

uniform vec2 u_size;     // 引擎填：输入纹理尺寸（物理 px）
uniform sampler2D u_tex; // 引擎填：filter input（背板）
uniform vec2 u_box;      // 玻璃尺寸（物理 px）
uniform float u_radius;  // 圆角半径（物理 px）
uniform float u_band;    // 折射带宽（物理 px）
uniform float u_disp;    // 色散比例，0 = 关（对照稿 0.045）
uniform float u_peak;    // 位移峰值（物理 px）= band * 0.40
uniform vec2 u_origin;   // 玻璃左上角在全屏中的位置（物理 px）
uniform float u_adapt;   // 内容自适应染色强度：>0 深色玻璃（亮背景加深），<0 浅色玻璃（暗背景提白），0 = 关
uniform vec3 u_scrim;    // 自适应混入的玻璃底色 rgb

out vec4 frag_color;

// 有符号距离：负数在内部（与对照稿 sdRoundRect 一致）
float sdRoundRect(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  vec2 qq = max(q, vec2(0.0));
  return length(qq) + min(max(q.x, q.y), 0.0) - r;
}

// 正数在内部的高度场
float shape(vec2 p, vec2 halfBox, float radius) {
  return -sdRoundRect(p - halfBox, halfBox, radius);
}

// 从边缘（t=0）到内部（t=1）的位移比例。
// 导数 < 1，保证采样映射单调，滚动时不出现「死区」。
// 对照稿：a = 0.10, b = 0.40, rise = 0.30。
float profile(float t) {
  float a = 0.10;
  float b = 0.40;
  float rise = 0.30;
  if (t < rise) {
    return a + (b - a) * (t / rise);
  }
  float u = (t - rise) / (1.0 - rise);
  return b * 0.5 * (1.0 + cos(3.14159265 * u));
}

void main() {
  vec2 uv = FlutterFragCoord().xy / u_size;
  vec2 geomUv = uv;

#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif

  vec2 halfBox = u_box * 0.5;
  float radius = min(u_radius, min(halfBox.x, halfBox.y));

  // 「bound texture」到底是元素自身大小，还是整屏快照，引擎没有写进文档。
  // 这里用尺寸比自适配：纹理明显大于玻璃 → 认定是整屏快照，把坐标从
  // 屏幕空间搬回元素局部空间。两种情况下 u_box 都是元素尺寸。
  vec2 pFull = geomUv * u_size;
  bool fullscreenTex = (u_size.x > u_box.x * 1.15) || (u_size.y > u_box.y * 1.15);
  vec2 p = fullscreenTex ? (pFull - u_origin) : pFull;
  vec2 localMax = u_box;

  float d = shape(p, halfBox, radius);

  vec2 shift = vec2(0.0);
  if (d < u_band) {
    float t = max(0.0, d / u_band);
    float amount = profile(t) * u_band;
    float e = 0.55;
    vec2 pl = max(p - vec2(e, 0.0), vec2(0.0));
    vec2 pr = min(p + vec2(e, 0.0), localMax);
    vec2 pt = max(p - vec2(0.0, e), vec2(0.0));
    vec2 pb = min(p + vec2(0.0, e), localMax);
    float gx = (shape(pr, halfBox, radius) - shape(pl, halfBox, radius)) / (2.0 * e);
    float gy = (shape(pb, halfBox, radius) - shape(pt, halfBox, radius)) / (2.0 * e);
    float gl = length(vec2(gx, gy));
    if (gl < 1e-4) {
      gl = 1.0;
    }
    // ∇shape 指向内部；取反得到向外的法线
    shift = -vec2(gx, gy) / gl * amount;
    // 最外 2px 羽化（对照稿位移贴图的 edgeFactor = min(1, edgeDistance/2)）：
    // 位移在贴边处平滑归零，避免玻璃最外一圈出现一条突然静止的硬边。
    shift *= clamp(d / 2.0, 0.0, 1.0);
  }

  // 采样区被玻璃 layer 的 bounds 裁住，位移会把「玻璃外」的像素读成
  // 纹理外的空白：这里 clamp 到 [0,1]，避免边缘出现拉伸条纹（R3）。
  // 采样坐标在纹理空间，GLES 上 y 已翻转，所以位移的 y 也要跟着取反。
  vec2 baseUv = clamp(uv, vec2(0.0), vec2(1.0));
  vec2 sampleShift = shift;
#ifdef IMPELLER_TARGET_OPENGLES
  sampleShift.y = -sampleShift.y;
#endif
  vec2 texel = sampleShift / u_size;

  vec4 c;
  if (u_disp > 0.0) {
    // 三通道色散：R/B 相对 G 各偏移 ±u_disp
    vec2 uvR = clamp(baseUv + texel * (1.0 + u_disp), vec2(0.0), vec2(1.0));
    vec2 uvG = clamp(baseUv + texel, vec2(0.0), vec2(1.0));
    vec2 uvB = clamp(baseUv + texel * (1.0 - u_disp), vec2(0.0), vec2(1.0));
    c = vec4(
      texture(u_tex, uvR).r,
      texture(u_tex, uvG).g,
      texture(u_tex, uvB).b,
      texture(u_tex, uvG).a
    );
  } else {
    c = texture(u_tex, clamp(baseUv + texel, vec2(0.0), vec2(1.0)));
  }

  // 内容自适应染色：对玻璃内部取 5 点背板采样求平均亮度，按亮度把
  // 折射结果向玻璃底色靠拢（HIG「blurs and adjusts the luminosity」的
  // 可移植近似）。深色玻璃在背景偏亮时加深，浅色玻璃在背景偏暗时提白；
  // 幅度由 u_adapt 控制，0 时整段跳过。采样在纹理空间进行：全屏快照
  // 用 u_origin 换算，元素尺寸纹理直接用局部坐标；GLES 需翻 y（与
  // baseUv 的约定一致）。
  if (abs(u_adapt) > 0.001) {
    float lum = 0.0;
    for (int i = 0; i < 5; i++) {
      vec2 frac = vec2(0.5, 0.5);
      if (i == 1) { frac = vec2(0.30, 0.30); }
      else if (i == 2) { frac = vec2(0.70, 0.30); }
      else if (i == 3) { frac = vec2(0.30, 0.70); }
      else if (i == 4) { frac = vec2(0.70, 0.70); }
      vec2 local = u_box * frac;
      vec2 nq = fullscreenTex ? (u_origin + local) / u_size : local / u_box;
#ifdef IMPELLER_TARGET_OPENGLES
      nq.y = 1.0 - nq.y;
#endif
      vec3 s = texture(u_tex, clamp(nq, vec2(0.0), vec2(1.0))).rgb;
      lum += dot(s, vec3(0.2126, 0.7152, 0.0722));
    }
    lum /= 5.0;
    float act = u_adapt > 0.0
        ? smoothstep(0.45, 0.85, lum)
        : smoothstep(0.45, 0.10, lum);
    c.rgb = mix(c.rgb, u_scrim, clamp(abs(u_adapt) * act, 0.0, 1.0));
  }

  frag_color = c;
}
