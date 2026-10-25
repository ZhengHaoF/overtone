#version 320 es
// Rhine 风格「成片层」：颗粒 + 暗角 + 缓慢下移的扫描带 + 边缘色散 tint。
// 作为覆盖层绘制在 stage 之上，不采样子树，所以零拷贝、可每帧跑。

precision highp float;

#include <flutter/runtime_effect.glsl>

// x = time(s), y = grain, z = vignette, w = scan
layout(location = 0) uniform vec4 u_params;
// 逻辑像素尺寸，用于把 FlutterFragCoord 归一化
layout(location = 1) uniform vec2 u_size;
// 边缘色散色 + 强度
layout(location = 2) uniform vec4 u_tint;

layout(location = 0) out vec4 fragColor;

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  vec2 coord = FlutterFragCoord();
  // 设备像素与逻辑像素可能不同（devicePixelRatio），按 u_size 归一化。
  vec2 uv = coord / max(u_size, vec2(1.0));
  float time = u_params.x;

  // 暗角：中心 1，边角 0
  float vig = smoothstep(0.68, 0.22, length(uv - 0.5));

  // 颗粒：按整数像素取噪声，随时间跳到新帧（对齐原片 25fps 的离散感）
  float grain = hash12(floor(coord) + floor(time * 25.0));

  // 扫描带：一条弱亮带缓慢下移
  float bandPos = fract(time * 0.055);
  float band = smoothstep(0.035, 0.0, abs(uv.y - bandPos));

  float a = (1.0 - vig) * u_params.z + (grain - 0.5) * u_params.y + band * u_params.w;
  vec3 tint = u_tint.rgb * u_tint.a * (1.0 - vig);

  fragColor = vec4(tint, clamp(a, 0.0, 1.0) * (1.0 - band * 0.4));
}
