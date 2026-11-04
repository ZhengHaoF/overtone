#include <flutter/runtime_effect.glsl>

// 折射命门验证用 shader（不是产品代码）。
//
// 目的只有一个：确认 `BackdropFilter(filter: ImageFilter.shader(...))` 里
// 第一个 sampler2D 拿到的**到底是不是背板快照**。做法是把采样坐标整体
// 平移 8 物理像素——如果玻璃里的背景「错位 8px」，说明拿到的就是背板；
// 如果纹丝不动，说明拿到的是元素自身内容 / 空图层，A 档不成立。
//
// 另外两个开关用来顺手验证 GLES y 翻转与 sampler 过滤质量。

uniform vec2 u_size;     // 引擎填：输入纹理尺寸（物理 px）
uniform sampler2D u_tex; // 引擎填：filter input
uniform float u_shiftX;  // 水平位移（物理 px）
uniform float u_shiftY;  // 垂直位移（物理 px）
uniform float u_tint;    // 1 = 整体染红（用来判断「有没有内容被采到」）
uniform float u_flip;    // 1 = 手动翻转 y（GLES 上默认应关闭）

out vec4 frag_color;

void main() {
  vec2 uv = FlutterFragCoord().xy / u_size;

  if (u_flip > 0.5) {
    uv.y = 1.0 - uv.y;
  }

  uv += vec2(u_shiftX, u_shiftY) / u_size;
  vec4 c = texture(u_tex, clamp(uv, vec2(0.0), vec2(1.0)));

  if (u_tint > 0.5) {
    c = vec4(1.0, c.g * 0.25, c.b * 0.25, c.a);
  }

  frag_color = c;
}
