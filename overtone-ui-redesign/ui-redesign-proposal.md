# Overtone 手机端默认皮肤改版方案（方向 A · 精致克制）

> 评审稿。配套静态视觉预览见同目录 `ui-redesign-preview.html`。
> 本文档由 2026-11 设计评审对话整理落盘；前三期实现已提交（截至 `1a5403f`），第 4 期参数补齐在工作区待提交。

## 1. 诊断：默认皮肤"素"在哪

token 体系（色板 / 字号阶梯 / 圆角 / 间距）本身是健康的——"素"不是 token 的锅，
是 token 之间没有被组织出层级。归为五类：

1. **表面层级是平的**：迷你播放条平铺无浮层、搜索框纯 surface 平涂、底部 Dock 与页面同底色且无分隔线，整屏像一张灰纸。
2. **主色太"隐身"**：青绿只出现在主按钮与播放中文字，首页是纯文字流，没有视觉焦点（对比 MAGI 分支的排版纪律）。
3. **列表行缺"物感"**：封面无投影、行间无稳定分隔，播放中仅文字变色。
4. **底部导航表达弱**：选中态只靠缩放弹跳，无色彩/指示承接选中语义。
5. **播放页头重脚轻**：封面取色渐变背景是最出彩资产，但封面圆角小、投影弱、控制区密排。

## 2. 三个候选方向

| | A. 精致克制（选定） | B. 封面驱动/编辑感 | C. 年轻化活力 |
|---|---|---|---|
| 关键词 | 分层表面、发丝分隔、单焦点色 | 杂志版式、大字、弱容器 | 渐变、圆角、高饱和 |
| 色彩 | 沿用现有色板，新增 elevation 规范 | 封面取色大面积铺底 | 主色+次生色双渐变 |
| Token 改动量 | 小 | 中 | 大 |
| 迁移成本/风险 | 低，可逐页灰度 | 中（浅色封面可读性兜底） | 高（廉价感风险，与 MAGI 强风格互相稀释） |

## 3. 推荐方向 A 的实施路线（已执行）

- **第 1 期 · 底座**：elevation 四档阴影 token（tile/raised/overlay/floating）+ `OvertoneRadius.floating=20`；迷你播放条浮起胶囊；底部 Dock 发丝分隔线 + 选中指示点 + 颜色过渡。
- **第 2 期 · 列表与首页**：TrackTile 封面轻投影 + 行间发丝分隔（第 4 期再放松密度）；发现页搜索面升级 + 搜索页聚焦描边；「为你推荐/探索」入口卡阴影化 + CoverPalette 渐变图标底。
- **第 3 期 · 播放器与我的**：封面圆角 floating(20) + 取色外发光 + 控制区呼吸节奏；「我的」三项统计迁出为浮起统计卡。
- **第 4 期 · 参数补齐（工作区，待提交）**：圆角整体上调（card 14 / cover 12 / 新增 search 13、bar 15）；深色主色提亮；搜索面内高光；Dock 半透明 + 背景模糊 + 悬浮化（外边距 / 圆角 / 投影）；入口卡整卡低强度渐变；列表行密度放松；歌单头部卡片化 + 「播全部」主色胶囊；「我的」真实入口卡组。

隔离原则：所有改动只在默认皮肤分支生效，MAGI / archive 硬边语汇零变化。

## 4. 与预览稿的偏差（第 4 期后）

上一版遗留的 6 项参数偏差已在第 4 期全部补齐；实机反馈后又补了 1 项此前文档漏写的偏差（Dock 悬浮化）：

1. 深色主色提亮为 `#17A398`（浅色保持 `#01756F`）；对 `bg` / `surface` 对比度约 6.2 / 5.6，主色上的白字约 3.1，均过守门阈值。
2. 圆角整体上调：`card 12→14`、`cover 10→12`，新增 `search=13`、`bar=15`（迷你条用 bar），其余档位不变。
3. 行密度放松：默认皮肤 TrackTile 竖向 padding `10→12`、封面 `52→42`、圆角走 `cover`；可见条目数不降。
4. 搜索面加内高光：默认皮肤用 `searchSheen`；浅色皮肤改为底部极轻内阴影（白面无法再提亮）。
5. Dock 改为半透明底 + 局部背景模糊（`ClipRRect` 只覆盖 Dock 一条，参数见第 8 条）；默认皮肤主 Tab 把 Dock 叠到内容之上（否则底栏下方没有可模糊的像素），实验皮肤仍挂 `bottomNavigationBar`。
6. 入口卡改为整卡低强度渐变（取色 16%→4%），渐变图标底保留。
7. **Dock 悬浮化（补漏项）**：此前预览稿画框与本文档都只写了「发丝线 + 选中点 + 半透明模糊」，画的是贴底通栏，实机上因此"看起来不悬浮"。本次把默认皮肤 Dock 改为离底悬浮圆角条：外边距横向 `OvertoneSpacing.floatingInset=10`（与迷你条同值）、底部 `OvertoneSpacing.sm=8`，圆角 `OvertoneRadius.bar=15`，投影 `theme.shadowRaised`，条高 58；3px 选中点位置不变。主 Tab 底部留白改为 `140 + 系统底部安全区`（迷你条 ≈70 + Dock 58 + 底距 8 ≈136）。图标 24 / 文字 10 沿用现有档位，未按预览稿的 19/9 缩小（9 不在字号阶梯内）。
8. **玻璃精进（A 级参数）**：默认皮肤玻璃收拢到 `shared/widgets/frosted_glass.dart`，在 `BackdropFilter` 里做「高斯模糊 σ=16 → 饱和度矩阵（浅色 1.20 / 深色 1.45）」；底色透明度降为浅色 `0xCE` / 深色 `0xC7`，叠 `glassSheen`（顶部受光 → 底部收暗）；描边从「整圈 1px 发丝线」改为顶边亮（浅色 `0xB3FFFFFF` / 深色 `0x2EFFFFFF`）、两侧发丝线、底边暗，模拟玻璃厚度。饱和度为 A 级新增：只改一个 `ColorFilter`，无额外布局与滚动开销。
9. **B1 自适应染色 + B2 模糊分层（已做）**：
   - **B1 自适应染色**：`RootShell` 用 `playerControllerProvider.select((s) => s.current?.coverUrl ?? '')` 取当前封面种子，再经 `CoverPalette.accentFromSeed` 得到主色，作为 `tint` 传给 Dock 的 `FrostedGlass`；玻璃内部按 `glassTintStrength`（**浅色 3% / 深色 6%**）把主色 `Color.lerp` 进 `dockScrim`，不直接铺封面色。切歌只改 `tint` 一次，由 `AnimatedContainer`（300ms / `easeOutCubic`）插值渐变，**不逐帧重算**。没有播放时 `tint = null`，玻璃回到纯 `dockScrim`，不残留上一首颜色。染色来源在 shell 侧计算，`OvertoneTheme` 不引入 Riverpod 依赖。
   - **B2 模糊分层**：迷你播放条默认皮肤也改用 `FrostedGlass`，但参数与 Dock 拉开一档——σ **10**、底色 `miniBarScrim`（浅色 `0xE6FFFFFF` / 深色 `0xE60B0E14`，90%）比 Dock 的 σ 16 / `0xCE`·`0xC7`（78~81%）更「实」，保证 44dp 封面旁的小字不糊；`radius = OvertoneRadius.bar`、`floatingInset` 与阴影仍用 `theme.shadowRaised`，进度线 / 封面 / 按钮布局未动。迷你条与 Dock 之间是 8px 间隙（`OvertoneSpacing.sm`），两条左右内缩同值，不会被模糊连成一片。
   - **性能兜底（已做，选了「滚动时降级」）**：`RootShell` 用 `ValueNotifier<bool> _glassGliding` + `NotificationListener<ScrollNotification>`，只在 `ScrollStart` / `ScrollEnd` 两个边界翻转（**不在 `ScrollUpdate` 里 setState**），滚停 300ms 后恢复；Dock 与迷你条各用一层 `ValueListenableBuilder` 消费，只重建自己。降级后 σ 为 Dock **16→8**、迷你条 **10→6**。另有集中开关 `OvertoneTheme.glassEffectsEnabled`（`static const`，默认 `true`）：置 `false` 时 `FrostedGlass` 退化成同色不透明面板，保留圆角 / 描边 / 投影，去掉模糊与饱和度——排查低端机掉帧时一键降级，无需改调用点。选滚动降级而不只做常量开关，是因为降级只在「正在滚动」这几十毫秒内生效，静止时仍保留完整玻璃观感；开关作为极端情况的兜底。
   - 参数集中点：`overtone_theme.dart` 的 `dockScrim` / `miniBarScrim` / `glassSheenWith` / `glassTintStrength` / `glassSaturation` / `glassDockSigma(+Scrolling)` / `glassThinSigma(+Scrolling)` / `glassEffectsEnabled`。

仍然保留的取舍（非遗漏）：

- 歌单头部卡片只在「默认皮肤 + 普通歌单」生效；榜单与 MAGI / archive 保留原大图头 + Hero 结构。
- 「我的」入口卡组只放真实入口（我喜欢 / 播放历史 / 音乐云盘（能力+开关）/ 设置（切页签）），不含任何占位项。
- 整卡渐变强度刻意压低（预览稿为高饱和整卡渐变），优先保证正文对比度。
- 圆角取值为“卡片 14 / 封面 12 / 胶囊 15”，未照单条预览稿逐像素对齐，属同一套档位的就近取整。
- Dock 悬浮参数由 token 阶梯推导（10/8、bar 15、raised），预览稿本身并未画悬浮形态；数值不能反推为预览稿的像素基准。

隔离原则复核：MAGI / archive 分支保持贴底、不透明、无圆角无投影、无模糊、无渐变、无入口卡组；本轮新增的 `floatingInset` 只被默认皮肤分支引用。B2 的玻璃迷你条只在默认皮肤生效——实验皮肤仍是 `Material(theme.surface)` 平铺条（硬边、无阴影、底部细进度线），Dock 的 `skinned` 分支也不接收 `tint` / `gliding`。

「我的」页滚动结构（实机反馈追加）：「歌单 / 设置」此前是「固定页头 + TabBarView 各自开视口」的两套滚动，实机反馈希望内容全部展开，已改成单层 `CustomScrollView`——身份卡 / 统计卡 / 入口卡组 / 吸顶 TabBar / 当前页签内容都排在同一条滚动里，页签切换只换内容 sliver、不新建视口也不复位位置。底部留白只在整页末尾算一次（不再与内层 padding 叠加）。预览稿只画静态版面，不涉及滚动结构。

## 5. 提交索引

| Hash | 内容 |
|---|---|
| `1a3e029` | feat(theme): elevation 规范（四档阴影 + floating 圆角） |
| `2fac4a9` | feat(ui): 底座浮起（迷你条胶囊 + Dock） |
| `d32a01e` | feat(ui): 列表与首页物感 |
| `1a5403f` | feat(ui): 播放器封面光晕与我的统计卡 |
| `5ca3736` | fix(ui): 语义标签、触控命中区与确认弹窗统一（前置修复批次） |

> 第 4 期（参数补齐）目前只在工作区，未提交、未分配 hash。
