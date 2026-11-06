#version 320 es
// 液态玻璃背板滤镜：轻度模糊 + 圆角 SDF 边缘折射 + RGB 色散。
// 由 BackdropFilter 使用；第一个 vec2 与 sampler 由引擎填充。

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform sampler2D u_texture_input;
uniform float u_radius;
uniform float u_band;
uniform float u_peak;
uniform float u_dispersion;
uniform float u_blur_radius;

layout(location = 0) out vec4 fragColor;

const float PI = 3.14159265359;

float roundedBoxSDF(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - halfSize + radius;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

vec2 clampUV(vec2 uv) {
  vec2 halfTexel = 0.5 / max(u_size, vec2(1.0));
  return clamp(uv, halfTexel, 1.0 - halfTexel);
}

vec3 frostedSample(vec2 uv) {
  vec2 offset = u_blur_radius / max(u_size, vec2(1.0));
  vec3 center = texture(u_texture_input, clampUV(uv)).rgb * 0.4;
  vec3 corners =
      texture(u_texture_input, clampUV(uv + offset * vec2(-1.0, -1.0))).rgb +
      texture(u_texture_input, clampUV(uv + offset * vec2(1.0, -1.0))).rgb +
      texture(u_texture_input, clampUV(uv + offset * vec2(-1.0, 1.0))).rgb +
      texture(u_texture_input, clampUV(uv + offset * vec2(1.0, 1.0))).rgb;
  return center + corners * 0.15;
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  vec2 textureSize = max(u_size, vec2(1.0));
  vec2 uv = coord / textureSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif

  vec4 source = texture(u_texture_input, clampUV(uv));
  vec3 blurred = frostedSample(uv);

  vec2 halfSize = textureSize * 0.5;
  float radius = min(u_radius, min(halfSize.x, halfSize.y));
  vec2 local = coord - halfSize;
  float depth = -roundedBoxSDF(local, halfSize, radius);
  float band = max(u_band, 1.0);
  float t = clamp(depth / band, 0.0, 1.0);
  float envelope = sin(t * PI);
  envelope *= envelope;

  vec3 color = blurred;
  if (envelope > 0.001 && u_peak > 0.0) {
    vec2 epsilon = vec2(1.0, 0.0);
    vec2 gradient = vec2(
        roundedBoxSDF(local + epsilon.xy, halfSize, radius) -
            roundedBoxSDF(local - epsilon.xy, halfSize, radius),
        roundedBoxSDF(local + epsilon.yx, halfSize, radius) -
            roundedBoxSDF(local - epsilon.yx, halfSize, radius));
    vec2 normal = gradient / max(length(gradient), 0.0001);
    vec2 offset = normal * u_peak * envelope / textureSize;
#ifdef IMPELLER_TARGET_OPENGLES
    offset.y = -offset.y;
#endif

    vec2 redUV = clampUV(uv - offset * (1.0 + u_dispersion));
    vec2 greenUV = clampUV(uv - offset);
    vec2 blueUV = clampUV(uv - offset * (1.0 - u_dispersion));
    vec3 refracted = vec3(
        texture(u_texture_input, redUV).r,
        texture(u_texture_input, greenUV).g,
        texture(u_texture_input, blueUV).b);
    color = mix(blurred, refracted, envelope * 0.9);
  }

  fragColor = vec4(color, source.a);
}
