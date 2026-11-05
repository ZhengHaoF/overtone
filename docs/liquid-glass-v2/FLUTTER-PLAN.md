# Liquid Glass v2 · Flutter 可行性方案

> 配套对照稿：[index.html](./index.html)（Chrome 打开，`?refract=0` 可关折射）。
> 本文只讨论「能不能做、用什么 API、代价多大」，不含实现代码。

---

## 0. 结论先行

| 问题 | 结论 |
| --- | --- |
| 能否在 Flutter 里做出「背景被折射」而不是「背景被模糊」？ | **能，但只有 A 档能。** 前提是 `ImageFilter.shader` 在 `BackdropFilter` 里能拿到背板纹理并允许在 shader 内偏移采样；这一点**本机无法验证，必须真机跑一次**（见 §6）。 |
| 能不能做到和 iOS 26 一模一样的折射/色散数值？ | **不能。** 苹果不公开 shader 参数，对照稿里所有数值都是工程拟合值（见对照稿 §参数与可信度）。能做到「同一类光学行为」，做不到「同一组数字」。 |
| 不写 shader 能不能提升？ | **能明显提升，但仍是 B 档。** 高光、内阴影、按压、融合形变做足后，观感会从「半透明卡片」变成「厚玻璃」，但边缘不会折背景。 |
| 中低端 Android 能扛住 A 档吗？ | 单层大面积玻璃（底部 sheet）**大概率能**；同屏 3 层以上 + 滚动列表**大概率掉帧**，需要降档。详见 §3。 |

---

## 1. 基准事实（已核对，非猜测）

- Flutter **3.47.6**，Dart **3.13.5**，Engine revision `692136cb65`（`flutter --version` 实测）。
- `app/pubspec.yaml`：`environment: sdk ^3.12.0`；**没有** `flutter_shaders` 依赖；已有 shader 注册：

```yaml
flutter:
  shaders:
    - shaders/rhine_finish.frag     # 1585 B
    - shaders/rhine_reveal.frag     # 1595 B
```

- 仓库里已有一条可用的 `FragmentProgram` 链路：[rhine_demo_page.dart](file:///D:/work/Overtone/app/lib/features/ui_demo/rhine_demo_page.dart) 用 `ui.FragmentProgram.fromAsset(...)` 加载并绘制。**新增 glass shader 不需要动构建体系**，只要往 `shaders:` 里加一行。
- 现版 [liquid_glass.dart](file:///D:/work/Overtone/app/lib/shared/widgets/liquid_glass.dart) 的实际做法：
  - `ImageFilter.compose(blur → ColorFilter.matrix)`，暗色主题 `blur 16 / saturate 1.45`，亮色 `blur 16 / saturate 1.20`；
  - 一层 `LinearGradient` 染色（暗色 alpha ≈ 0.78，亮色 ≈ 0.88）；
  - 1px 渐变描边 + 左上 radial 柔光；
  - 顶部 1px 亮线、底部内阴影（内阴影在 `_LiquidGlassPainter` 里画）。
  - **没有位移、没有色散、没有融合**——这就是用户说「不是液态玻璃」的技术原因：它只做了「背景模糊 + 提饱和」，没有改变背景的**几何**。

---

## 2. HTML 效果 → Flutter API 映射

状态含义：**确认支持** = SDK 文档/源码可查；**需验证** = API 存在但该用法没有官方文档背书，必须真机跑；**不支持** = 当前版本做不到。

| # | 对照稿里的效果 | Flutter 手段 | 状态 | 说明 / 代价 |
| --- | --- | --- | --- | --- |
| 1 | 背景模糊 | `BackdropFilter(filter: ImageFilter.blur(sigmaX/Y))` | 确认支持 | 现版就在用。 |
| 2 | 模糊 + 饱和/对比一体 | `ImageFilter.compose(outer: blur, inner: ColorFilter.matrix)` | 确认支持 | 对照稿 `saturate 1.62 / contrast 1.06` 可直接写成 5×4 矩阵。 |
| 3 | iOS 式「磨砂」边界 | `ImageFilterConfig.blur(..., bounded: true)` + `BackdropFilter(filterConfig: ...)` | 确认支持 | SDK 注释原文：`replicate the high-fidelity frosted-glass effect seen on iOS`。比裸 `blur` 少了边缘外溢，**建议 B 档就用它**。 |
| 4 | **边缘位移折射**（圆角 SDF 高度场） | `BackdropFilter(filter: ImageFilter.shader(fragmentShader))`，shader 内算 SDF + 法线 + 偏移采样 | **需验证** | `ImageFilter.shader` 确认存在（Impeller-only，运行时用 `ImageFilter.isShaderFilterSupported` 判定）；**但它作为 BackdropFilter 的 filter 时，第一个 sampler 拿到的到底是不是「背板快照」、坐标域是不是元素 bounds，没有官方文档**——这是整个 A 档的成败点。 |
| 5 | 三通道色散 | 同 shader 内 3 次 `texture()`，采样偏移 ×(1±4.5%)，按通道合成 | **需验证** | 与 #4 同生共死；额外 2 次全区域采样，填充率 ×3。 |
| 6 | 顶部 1px 亮线 / 左上柔光 / 底沿品红 | `CustomPainter` + `LinearGradient` 描边 + `RadialGradient` | 确认支持 | 现版已有，属于纯 2D 绘制，最便宜。 |
| 7 | 高光随指针/滚动移动 | `Listener`/`NotificationListener` → 一个 `ValueNotifier<Offset>` → `CustomPainter` 重绘 | 确认支持 | 只重绘高光层，别触发 backrop 重采。 |
| 8 | 两个玻璃融合（smooth-union） | A：同一个 shader 里画两个胶囊 SDF，动画 `gap` 与 `k`；B：`ClipPath` + 预计算 `Path` 帧 | A 需验证 / B 确认支持 | B 档用 `Path.combine(PathOperation.union)` 只能得到硬并集，颈部要「表面张力」必须自己插值贝塞尔或按 SDF 采样成多边形。对照稿的 24 帧预计算就是 B 档的低成本近似。 |
| 9 | 按压压缩 + 内阴影加深 | `AnimatedScale`/`AnimatedContainer` + 内阴影参数插值 | 确认支持 | 30–40ms，纯属性动画。 |
| 10 | 背景实时跟随滚动 | `BackdropFilter` 本身每帧重采背板 | 确认支持 | **代价型确认**：玻璃压在列表上时，每一帧都要重采一次背板。 |
| 11 | 多层玻璃共享背板 | `BackdropGroup` + `BackdropFilter.grouped(...)` | 确认支持（语义）/ **组合需验证** | 能省掉重复快照；但「grouped + shader filter」是否同样共享，未验证。 |

### 关键源码依据

- `ImageFilter.shader` 存在且仅 Impeller：
  `D:\flutter\bin\cache\pkg\sky_engine\lib\ui\painting.dart` — 注释写明 *“only supported when using the Impeller rendering engine”*，并要求 **第一个 uniform 必须是 vec2（引擎写入纹理尺寸）**、**至少一个 sampler2D（引擎写入 filter input）**；GLES 后端 y 轴翻转，shader 里要自己翻。
- `BackdropFilter` / `BackdropFilter.grouped` / `filterConfig` 参数：
  `D:\flutter\packages\flutter\lib\src\widgets\basic.dart`。
- `ImageFilterConfig.blur(bounded: true)` 的 iOS 磨砂注释：
  `D:\flutter\packages\flutter\lib\src\rendering\image_filter_config.dart`。

---

## 3. 分档实现

### A 档：真折射 + 色散（shader 采样背板）

**做法**

```dart
BackdropFilter(
  filter: ui.ImageFilter.shader(_glassShader),   // 需 isShaderFilterSupported
  child: CustomPaint(painter: GlassRimPainter(...)), // 高光/内阴影叠在上层
)
```

shader 草案（仅示意结构，非最终代码）：

```glsl
#include <flutter/runtime_effect.glsl>
uniform vec2  u_size;     // 引擎自动填：输入纹理尺寸
uniform sampler2D u_tex;  // 引擎自动填：filter input（期望是背板）
uniform vec2  u_box;      // 玻璃逻辑尺寸
uniform float u_radius;
uniform float u_band;     // 折射影响半径
uniform float u_peak;     // 峰值位移 = band * 0.40
uniform float u_disp;     // 色散比例 0 / 0.045
out vec4 frag_color;

float sdRound(vec2 p, vec2 b, float r){
  vec2 q = abs(p) - b + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}
```

片元里：`uv = FlutterFragCoord().xy / u_size; p = uv * u_box;`
算 `d = -sdRound(p - u_box/2, u_box/2, u_radius)`（正数在内部），
`d < u_band` 时按对照稿的 `profile(t)` 与法线方向偏移采样；
色散开时对 R/G/B 分别用 `u_peak*(1±u_disp)` 采样三次再按通道合成。

**代价**

- 每帧、每块玻璃一次**离屏背板采样**（RGBA，屏幕大小量级）；
- 玻璃区域内每像素：1 次 SDF + 1 次数值梯度（4 次 SDF）+ 1~3 次纹理采样；
- 1080×2400 屏上一块 1080×800 的 sheet ≈ 86 万像素，色散开启时 ≈ 260 万次采样/帧；
- 内存：一张全屏背板纹理 ≈ 1080×2400×4B ≈ **10 MB**（瞬时，复用后可回落）；
- 裁剪约束：背板只在玻璃 layer 的 bounds 内可见。**边缘位移会把「玻璃外面」的像素折进来，如果玻璃外紧贴一个 `ClipRRect`，那些像素根本不存在** → 必须在视觉边缘外扩 16–24dp 做采样区，再裁回可见形状。

**中低端 Android 预期**：单层大面积玻璃 **可接受**（约多 3–6 ms/帧 GPU）；同屏 ≥3 层、且下面压着滚动列表时 **大概率 30–45 fps**。这不是拍脑袋，对照稿在桌面 Chromium 软/硬合成下同屏 13 层也只有 38–46 fps，移动 GPU 只会更紧。

### B 档：不折射，但把「玻璃感」做足

- `ImageFilterConfig.blur(bounded: true)` + 饱和矩阵（**推荐替换现版的裸 blur**）；
- 双层描边（外 1px 冷白 + 内 1px 暖白，顶部最亮）；
- 左上 radial 柔光 + 顶部 1px 锐线；底沿内阴影带**随按压深度插值**；
- `AnimatedScale(0.985)` + 内阴影加深 + 外投影收缩，40ms `easeOut`；
- 融合：预计算 20–24 个 `Path` 帧（SDF 采样成多边形），`easeOutBack` 播放；或 `Path.combine` 硬并集 + 一个「颈部」补丁路径。

**代价**：与现版同一量级，只多一层绘制。**中低端 Android 基本无感掉帧。**

**用户能感知到什么**：按压有「压下去」的厚度、边缘亮线不再像描边滤镜、相邻胶囊会黏在一起而不是淡入淡出。**但滚动时背景文字仍然是「糊成一片」，不会弯。**

### C 档：纯色降级

- 无 `BackdropFilter`，纯 `LinearGradient` + 描边 + 内阴影；
- 触发条件：`glassEffectsEnabled == false`、系统高对比度、`isShaderFilterSupported == false` 且设备分档为低端。

**代价**：接近 0。现版已有这条路径（`OvertoneTheme.glassEffectsEnabled`），继续沿用即可。

### 档位选择建议

```
isShaderFilterSupported && 设备档位 >= 中端 && 玻璃面积占比 < 35%  → A
否则                                                              → B
无障碍/低端/关闭特效                                              → C
```

---

## 4. 工程风险与规避

| 风险 | 具体表现 | 规避 |
| --- | --- | --- |
| **R1. `ImageFilter.shader` 拿不到背板** | 如果 BackdropFilter 的 filter input 不是背景快照，A 档直接不成立 | 先写 10 行验证 demo：一个 shader 把输入整体染红，看玻璃区域是否变红。**这一步不做完，不要动生产代码。** 若失败 → 退回「`RepaintBoundary.toImageSync` 手动截背板 + `FragmentShader` 自绘」路线，代价是多一次截屏 + 坐标系换算。 |
| **R2. 采样域 / DPR 对不上** | 玻璃尺寸按逻辑像素传，纹理按物理像素，偏移量差 2–3 倍 | shader 里用 `u_size`（引擎给的是纹理尺寸）归一化，`u_box` 传物理像素；或直接传 `devicePixelRatio`。 |
| **R3. 边缘采样越界** | 位移把纹理外的内容折进来，出现拉伸条纹/镜像边 | 采样区比可见形状外扩 `band` 像素；shader 内对 uv 做 `clamp` 到 `[band/size, 1-band/size]`，并给越界区域 8–12px 渐隐。对照稿的「背景过界会被镜像回来」现象在 Flutter 里同样存在。 |
| **R4. 玻璃压在滚动列表上每帧重采** | 列表滚动时 GPU 填充率翻倍，帧时间抖动 | 滚动中用 `LiquidGlass.scrolling`（现成开关）把 A 档降为 B 档，停手 300ms 再恢复；或 `BackdropGroup` 共享一次快照。 |
| **R5. `BackdropFilter` 的裁剪语义** | 玻璃放进 `ClipRRect` 后，采样区也跟着被裁，边缘没有背景可折 | 采样层放在裁剪层**外面**：外层 `Positioned.fill` 扩张，内层 `ClipRRect` 只负责视觉裁切。 |
| **R6. Impeller / Skia 差异** | Android 老设备可能回落 Skia，`isShaderFilterSupported == false` | 运行时判定 + 静态兜底，不要 try/catch 猜。 |
| **R7. GLES y 翻转** | 只在 OpenGL ES 后端上下颠倒 | shader 里 `uv.y = 1 - uv.y`（按 `#ifdef` 或统一处理后再在 Vulkan 上反翻）。SDK 注释明确提到这一点。 |
| **R8. 色散在 sRGB 空间做会脏** | 边缘出现灰边而不是彩边 | 通道分离用 `ColorFilter.matrix` 而不是 alpha 叠加；对照稿里用的是三次位移 + 通道隔离 + screen 混合，Flutter 里对应 shader 内三次采样后按 `vec3(r,g,b)` 直接取通道。 |
| **R9. 融合形变的物理真实度** | SDF 平滑并集只是「几何近似」，没有真正的表面张力/体积守恒 | 明说：这是近似。若要更真，需要网格 + 弹簧，成本远超收益。 |

---

## 5. 分期落地

| 期 | 交付 | 用户立刻能感知 | 回退 |
| --- | --- | --- | --- |
| **P0**（最小可信） | 把现版 blur 换成 `ImageFilterConfig.blur(bounded: true)`；双层描边；按压 40ms 压缩 + 内阴影加深；高光跟随滚动位置 | 「边不再像画上去的线，按下去有厚度」 | 一个 `glassQuality` 开关回 C 档 |
| **P1** | 融合：两个相邻胶囊在距离 < k 时黏合（预计算 Path 帧）；`BackdropGroup` 共享背板 | 「相邻玻璃会合并成一块，不是淡入淡出」 | 关闭 `mergeGlass` 布尔 |
| **P2**（关键验证） | 写 A 档验证 demo（R1），只在「全播放器底部控制面」一块玻璃上开 | 若成功：滚动歌词时，文字在玻璃边缘**真的弯折** | 全局 `isShaderFilterSupported` 兜底 |
| **P3** | A 档铺到 sheet / Dock，加色散；滚动时降档 | 「边缘有彩色细边，背景被局部放大」 | 单层关闭色散（`u_disp = 0`） |
| **P4** | 分档策略 + 真机帧率采样 + 内存回收 | 中低端不掉帧 | 一键全局 B 档 |

**建议先做 P0+P1**：这两期不依赖任何未验证 API，能立刻把「半透明卡片」的观感拉开；P2 是一次纯粹的可行性验证，失败也只是「没做成 A 档」，不会拖累已有交付。

---

## 6. 不确定 / 做不到（必须单列）

1. **`ImageFilter.shader` 作为 `BackdropFilter.filter` 时的输入语义未验证。** API 存在、约束清楚，但「第一个 sampler 就是背板快照」是我基于命名的推断，SDK 文档没有这句话。本机没有 Android/iOS 设备，无法在本轮确认。
2. **`BackdropFilter.grouped` + shader filter 能否共享同一张背板**，未验证。
3. **Impeller 下 `sampler2D` 的过滤质量 / mipmap / `FilterQuality`** 行为未知，边缘可能比对照稿更锯齿。
4. **中低端 Android 的真实帧率**：本方案给的「3–6 ms / 30–45 fps」是从对照稿的桌面数据外推，**不是真机实测**。
5. **苹果的具体数值不可得**：折射位移量、色散强度、band 宽度、融合时长曲线，苹果都没有公开。对照稿里的 `band 8/14/22`、`peak = band × 0.40`、`色散 ±4.5%`、`融合 460ms easeOutBack` 全部是**工程拟合**，只能保证「同类行为」，不能保证「同参数」。
6. **「融合」在 Flutter 里做不到苹果那种真正的表面张力**：SDF 平滑并集是几何近似，体积不守恒；对照稿的颈部也会比真机略「肥」。
7. **Web 对照稿与 Flutter 实现不可能逐像素一致**：浏览器是 SVG 滤镜在 sRGB 空间做位移，Flutter 是 shader 采样，两者的边缘插值、色彩空间、抗锯齿都不同。对照稿的作用是「定目标与量级」，不是「验收基准」。
8. **没有 iOS 26 实机对照**：本轮参考证据来自 Apple 官方文案/HIG/WWDC 文字稿与社区拆解，没有拿到逐帧真机视频做定量测量。
9. **对照稿只在 Chromium 系验证过**：`backdrop-filter: url(#svgFilter)` 是 Chromium 特性，Safari/Firefox 会直接退化成「只模糊」。页面已做能力检测与提示，但**没有在 Safari 上验证过降级后的观感**。

---

## 7. v2.1 落地记录

针对「与苹果 Liquid Glass 的差距」评审（静态质感已到位，差距全在动态），本轮落地：

| # | 项 | 实现 | 位置 |
| --- | --- | --- | --- |
| 1 | **融合 / 形变** | 新原语 `GlassMergeGroup`（容器拥有玻璃，对齐 `GlassEffectContainer` 语义）：间距进入 `mergeNeck` 作用范围后按 SDF smooth-union 连续长出颈部，marching squares（3px 网格）抽联合轮廓，rim 连续；k 由实时间距插值，无帧动画、任意时刻可反向。未融合单 blob 走 `LiquidGlass` 全量 A 档 | `shared/widgets/glass_merge.dart`；演示在 probe 页 |
| 2 | **内容自适应染色** | `glass_refract.frag` 采样背板 5 点平均亮度，按 `spec.adaptiveStrength`（深色 > 0 / 浅色 < 0）向 scrim 靠拢 —— 材料会「看」底下内容。仅 A 档 | `shaders/glass_refract.frag`、`GlassSpec.adaptiveStrength` |
| 3 | **移动端环境光** | `GlassAmbient`：加速度计重力向量 → 归一化倾角 → 所有玻璃柔光 / rim 渐变角漂移 ±4px。仅 Android/iOS 自动启动；桌面可用 `attach()` 接自定义驱动 | `core/theme/glass_ambient.dart`（新增 `sensors_plus` 依赖） |
| 4 | **滚动折射收敛** | 滚动中 band / peak 乘 `scrollRefractionScale(0.35)`，抑制「u_origin 比背板快照慢一帧」的错帧游动；与降模糊同策略，停手恢复 | `GlassMotion.scrollRefractionScale` |
| 5 | **按压缩放** | 按压 = 下沉 1.5px + 收缩至 0.975（材料收缩，不是卡片被按进去） | `GlassMotion.pressScale` |
| 6 | **嵌套玻璃保留材质** | 玻璃套玻璃不再整块变实：保留底色 / rim / 柔光，只关背板采样 | `liquid_glass.dart`（`effectsOn` / `useBlur` 拆开） |
| 7 | **浅色 rim 加强** | 浅色三档 `rimSide` / `rimBottom` 加深约一倍，边缘轮廓立得住 | `glass_tokens.dart` |

**已知取舍**：融合簇面板走 B 档（bounded blur + 连续 rim），双箱 smooth-union 折射需要 shader 支持多 box，留待 v2.2；融合面板无外投影；B 档无内容自适应（拿不到背板亮度）。
