#version 320 es
// 盖板解密揭示：前沿自上而下走过，磨砂层在它经过之后消失。输出用作 ShaderMask 的 alpha。
// 对应原实现里 onBeforeCompile 注入 transmission 着色器的 glass-reveal。
//
// FlutterFragCoord 的 y 方向在两个后端上不保证一致，所以给 u_reveal.w 留一个翻转位，
// 由宿主按实测传 0 或 1，而不是重新编译着色器。

precision highp float;

#include <flutter/runtime_effect.glsl>

// x = progress(0..1), y = feather(px), z = noise, w = flipY(0|1)
layout(location = 0) uniform vec4 u_reveal;
// 被遮罩区域的设备像素尺寸
layout(location = 1) uniform vec2 u_size;

layout(location = 0) out vec4 fragColor;

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  vec2 coord = FlutterFragCoord();
  float h = max(u_size.y, 1.0);
  // 归一到 0..1，flip 后 0 恒为「揭开开始的那一侧」
  float y = coord.y / h;
  y = mix(y, 1.0 - y, u_reveal.w);

  float feather = max(u_reveal.y / h, 0.001);
  // 前沿走完时多留 2 倍羽化余量，保证终态是完全揭开而不是残留一条边
  float frontier = u_reveal.x * (1.0 + feather * 2.0) - feather;
  float jitter = (hash12(floor(coord * 0.5)) - 0.5) * feather * u_reveal.z * 2.0;

  // 前沿之前 = 已揭开（alpha 0），还没走到的下方仍是磨砂（alpha 1）
  float a = smoothstep(frontier - feather + jitter, frontier + feather + jitter, y);
  fragColor = vec4(a);
}
