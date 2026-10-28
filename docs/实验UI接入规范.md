# 实验 UI（Experimental UI）接入与扩展开发规范

> 本文档面向开发者及 AI Coding Assistant。用于指导在 Overtone 中新增、修改或扩展一套全新的「实验 UI 风格」（如瑞士国际排版、新粗野主义、赛博朋克等）。

---

## 1. 核心架构与设计原则

Overtone 的实验 UI 采用 **数据驱动 + 抽屉自动枚举 + 全局主题注入** 架构：

```
                    ┌─────────────────────────┐
                    │  ExperimentalUiSkin 枚举 │
                    │(settings_controller.dart)│
                    └────────────┬────────────┘
                                 │
             ┌───────────────────┴───────────────────┐
             ▼                                       ▼
┌─────────────────────────┐             ┌─────────────────────────┐
│     设置抽屉侧栏 UI       │             │    SettingsController   │
│  (settings_pickers.dart)│             │ (SharedPreferences 持久化)│
│  自动遍历枚举生成选项卡片   │             └────────────┬────────────┘
└─────────────────────────┘                          │
                                                     ▼
                                        ┌─────────────────────────┐
                                        │  Theme Resolver & Scope │
                                        │   (ThemeData 动态注入)   │
                                        └────────────┬────────────┘
                                                     │
                                                     ▼
                                        ┌─────────────────────────┐
                                        │  全站页面 / 播放器 / 详情页│
                                        │  OvertoneTheme.of(ctx)  │
                                        └─────────────────────────┘
```

1. **自动渲染**：侧栏抽屉（`showExperimentalUiPicker`）通过循环 `ExperimentalUiSkin.values` 动态生成选项卡片，**新增皮肤时无需修改任何抽屉 UI 代码**。
2. **即时热切换**：在抽屉中点击任意皮肤，Riverpod 全局状态立即更新，整站（主页、侧边栏、播放器、详情页）在毫秒级无缝重绘，用户可原地实时对比。
3. **强类型约束**：全站受 `design_tokens_policy_test.dart` 严格保护，字号与圆角必须遵循设计系统阶梯。

---

## 2. 关键文件索引

| 模块 | 文件路径 | 职责 |
| :--- | :--- | :--- |
| **枚举与配置** | `app/lib/features/settings/settings_controller.dart` | 定义 `ExperimentalUiSkin`、持久化、读取与状态分发 |
| **设置抽屉侧栏** | `app/lib/shared/widgets/settings_pickers.dart` | `showExperimentalUiPicker` 抽屉侧栏实现 |
| **设置页入口** | `app/lib/features/settings/settings_page.dart` | 外观设置区域的「实验UI」入口与角标 |
| **主题解析与注入**| `app/lib/core/theme/archive_skin.dart`<br/>`app/lib/shared/widgets/archive_skin_scope.dart` | 样式解析器（Resolver）与 Scope 包裹层 |
| **设计 Token 约束**| `app/lib/core/theme/overtone_tokens.dart` | 调色板、字号阶梯、圆角定义 |
| **自动化测试** | `app/test/experimental_ui_picker_test.dart`<br/>`app/test/design_tokens_policy_test.dart` | 侧栏抽屉测试、设计系统合规性测试 |

---

## 3. 新增一套实验 UI 的标准步骤（只需 3 步）

### 第一步：在枚举中注册新皮肤

打开 [`app/lib/features/settings/settings_controller.dart`](file:///d:/work/Overtone/app/lib/features/settings/settings_controller.dart)，在 `ExperimentalUiSkin` 中增加你的新项：

```dart
enum ExperimentalUiSkin {
  off('默认', '标准深浅自适应样式'),
  swiss('瑞士国际排版', '纸白墨黑无衬线排版，选中后全站切换为浅色'),
  
  // ── 新增示例 ──
  cyberpunk('赛博朋克', '霓虹高对比光谱与终端发光质感'),
  neoBrutalism('新粗野主义', '高饱和撞色、粗描边与硬阴影线框');

  const ExperimentalUiSkin(this.label, this.desc);
  final String label;   // 卡片与设置项展示的标题
  final String desc;    // 抽屉卡片下方的设计风格说明
  
  static ExperimentalUiSkin fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ExperimentalUiSkin.off;
    for (final skin in ExperimentalUiSkin.values) {
      if (skin.name == wire) return skin;
    }
    return ExperimentalUiSkin.off;
  }
}
```

> **注意**：完成此步后，运行应用打开「设置 → 实验UI」，右侧抽屉**已经能自动显示该新卡片**并支持点击切换与落盘保存！

---

### 第二步：定义该 UI 的主题调色板（Palette & ThemeData）

创建或在 `app/lib/core/theme/` 下编写独立文件（例如 `cyberpunk_skin.dart`）：

```dart
import 'package:flutter/material.dart';
import 'overtone_theme.dart';
import 'overtone_tokens.dart';

abstract final class CyberpunkSkin {
  static const palette = OvertonePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0F1016),
    surface: Color(0xFF161822),
    surfaceElevated: Color(0xFF1E202E),
    primary: Color(0xFF00FFCC),       // 霓虹青
    favorite: Color(0xFFFF0055),      // 霓虹粉
    danger: Color(0xFFFF3333),
    textPrimary: Color(0xFFF0F6FC),
    textSecondary: Color(0xFF8B949E),
    textTertiary: Color(0xFF484F58),
    divider: Color(0x3300FFCC),
    overlay: Color(0x66000000),
  );

  static ThemeData theme(OvertoneAccent accent) {
    final base = buildOvertoneTheme(
      Brightness.dark,
      accent: accent,
      palette: palette.withAccent(accent),
    );

    return base.copyWith(
      // 可在此覆盖 AppBar、Card、TabBar 等组件的特定样式
    );
  }
}
```

---

### 第三步：在 Theme Resolver 中挂载解析

打开 [`app/lib/shared/widgets/archive_skin_scope.dart`](file:///d:/work/Overtone/app/lib/shared/widgets/archive_skin_scope.dart)，在作用域中挂载新皮肤主题：

```dart
ThemeData? skinTheme;
if (skin == ExperimentalUiSkin.swiss) {
  skinTheme = ArchiveSkin.theme(settings.accent);
} else if (skin == ExperimentalUiSkin.magi) {
  skinTheme = MagiSkin.theme(settings.accent);
}
```

> 新皮肤只需在 [ArchiveSkinScope](file:///d:/work/Overtone/app/lib/shared/widgets/archive_skin_scope.dart) 的 `switch` 里挂一个分支。皮肤在桌面与移动端一致生效；`ThemeData.brightness` 由皮肤自己决定（swiss 恒为浅色，magi 恒为深色），与「外观」设置无关，状态栏/导航栏由 Scope 按皮肤主题同步。

---

## 4. 已有实验 UI 案例参考

### 1. 瑞士国际排版 (`swiss`)
- **设计基调**：纸白底色（`#F5F5F7`）、极黑正文（`#111111`）、单主色瑞士红（`#E53935`）、编号导向（`01 / NOW PLAYING`）、网格点阵底纹、冷峻强对比度。
- **生效条件**：桌面端与移动端一致生效；选中即覆盖外观设置，全站切换为浅色纸面（移动端同样生效）。

### 2. MAGI 霓虹终端 (`magi`)
- **设计基调**：福音战士海报 / NERV 终端：深紫黑底 + 霓虹朱红 + 紫色光晕，参考图里的「大字号 + 光线 + 水印」而不是军工线框：
  - 深紫黑渐变：`#09040F`（底色）→ `#1B0B2B`（中部）→ `#0A0510`（回落），卡片层 `#140B1E` / `#1D1029` / `#2A1738`
  - 霓虹朱红：`#FF2743`（主色 / 选中 / 进度）与 `#FF5C72`（高亮）
  - 霓虹紫：`#8B5CF6`（光晕 / 次级参数）与 `#C084FC`（同步状态、日文注释）
  - 品红：`#D946EF`（收藏 / 喜欢）
  - 暖白文字：`#F6EEF9`，次级 `#C9B6D6`，三级 `#9683A6`
  - 形状：12px 圆角卡片、胶囊按钮、发丝朱红描边 + 柔和外发光（不再使用 0 圆角）
- **桌面左栏排版**：一屏只留一个焦点——`38px` 巨幅曲名（`MagiSkin.heroSize`）+ 单个 `T-` 倒计时读数（`MagiSkin.readoutSize`）；PRIORITY / SYNC / DECODER / 坐标等装饰性假读数不进左栏，结构性分隔线改用中性色（`MagiSkin.lineSoft`），朱红只留给强调。
- **氛围层**：`MagiBackdrop` 统一负责深紫渐变、左上紫晕 / 右下红晕、斜向灯带、NERV 圆形水印章、巨号 NERV 幽灵字、日文引句与右下 `ALERT! // CONDITION: RED` 角标；桌面与手机外壳、播放页共用。
- **专属组件**：
  - `MagiTargetFrame`：封面霓虹描边框，`TARGET` / `CODE` 角标叠在封面角上，不占额外纵向空间
  - `MagiEqualizerBar`：朱红→霓虹紫的阶梯频谱（移动端元信息区使用）
  - `MagiConsensusBar`：单行 MELCHIOR-1 / BALTHASAR-2 / CASPAR-3 状态带
  - `MagiProgressGauge`：`T-` 剩余时间 + `TOTAL` 总长 + 朱红渐变辉光刻度（含可拖动播放头）
  - `MagiHazardBar`：带辉光的朱红分隔线
  - `MagiFrameCorners`：四角发光线标
  - `MagiTagButton`：胶囊按钮，强调态朱红渐变 + 发光
  - `MagiStatusLed`：呼吸式同步灯（外壳用静态模式，避免 `pumpAndSettle` 挂起）
- **页面级差异**：发现页页头为「编号条 + 大标题 + 日文副标题 + 红色日期」，搜索框与区块标题使用发光描边；侧栏显示 `EVA-01 版`，选中项带红色光晕；Dock / 播放条使用紫色渐变背景与霓虹红进度。

---

## 5. 页面级差异化与专属小部件（可选）

对于大多数页面，修改 `ThemeData` 的背景、文字色与圆角已经足够完成风格转换。但如果新 UI 包含**强烈的专属形态**（例如瑞士排版的编号与标尺、粗野主义的厚黑边卡片）：

### 推荐模式：提取轻量抽象组件

参考 `app/lib/shared/widgets/archive_chrome.dart` 与 `archive_controls.dart`：

1. **状态读取**：
   在组件中通过 `ref.watch(settingsControllerProvider).experimentalUi` 判断当前皮肤：
   ```dart
   final isSwiss = ref.watch(settingsControllerProvider).experimentalUi == ExperimentalUiSkin.swiss;
   ```
2. **插槽式渲染**：
   ```dart
   if (isSwiss)
     const ArchiveKicker(label: '01 / NOW PLAYING')
   else
     Text('正在播放', style: theme.section);
   ```

---

## 5. 必须遵守的设计系统规范（避坑指南）

提交代码前，请务必注意项目内置的 `test/design_tokens_policy_test.dart` 自动化红线：

### 1. 字号阶梯强制约束（仅允许 5 档）
全站所有字号必须且只能是以下五档之一（或使用 `OvertoneFontSize.*`）：
- `10.0`：角标、小标签、Kicker 编号
- `12.0`：Caption 说明、二级副标题
- `15.0`：Body 正文、列表标题
- `18.0`：Section 区块标题
- `22.0`：Title / Header 标题
- *(特例：`display` 28px 仅限顶部问候语与全屏播放页主歌名)*
> **严禁**使用 `11.0`、`13.0`、`14.0`、`16.0` 等梯外字号，否则静态测试会直接拦截失败！

### 2. 圆角规范（仅允许描边级 ≤4 或 OvertoneRadius）
- 细微倒角（≤4）：允许直接写 `BorderRadius.circular(2)` 或 `circular(4)`。
- 组件级圆角：**必须使用 `OvertoneRadius` 常量**：
  - `OvertoneRadius.small` (6.0)
  - `OvertoneRadius.tag` (8.0)
  - `OvertoneRadius.button` / `tile` / `cover` (10.0)
  - `OvertoneRadius.card` (12.0)
  - `OvertoneRadius.chip` (999.0 胶囊)
> **严禁**写死 `BorderRadius.circular(8)` 或 `BorderRadius.circular(10)`，需写成 `BorderRadius.circular(OvertoneRadius.tag)`！

### 3. 色彩对比度（WCAG 规范）
- 文本色对背景色对比度必须满足：
  - `textPrimary` ≥ 7:1
  - `textSecondary` ≥ 4.5:1
  - `textTertiary` ≥ 3:1
- 语义色（`favorite`, `danger`, `primary`）之间必须具备足够的感知色差，不可重叠。

---

## 6. 验证与提交前检查清单

每次新增或调整实验 UI 后，请依次执行以下命令确保零回归：

```powershell
# 1. 静态代码分析（必须 0 error, 0 warning）
cd app
flutter analyze lib/features/settings/ lib/shared/widgets/ lib/core/theme/

# 2. 设计规范红线测试
flutter test test/design_tokens_policy_test.dart

# 3. 实验UI抽屉联动与落盘测试
flutter test test/experimental_ui_picker_test.dart test/settings_archive_skin_test.dart

# 4. 全局测试
flutter test test/player_archive_skin_test.dart test/archive_shell_explore_test.dart
```
