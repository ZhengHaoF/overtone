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
| **EVA 调色板** | `app/lib/core/theme/eva_palette.dart` | 红（`unit02`）/ 蓝（`unit00`）两套色板与皮肤主题；`context.eva` 取当前色板 |
| **EVA 版式字号** | `app/lib/core/theme/magi_skin.dart` | 红蓝共用的海报字号阶梯（`MagiSkin.heroSize` 等），不含颜色 |
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
final ThemeData? skinTheme = switch (skin) {
  ExperimentalUiSkin.swiss => ArchiveSkin.theme(settings.accent),
  ExperimentalUiSkin.magi || ExperimentalUiSkin.evaBlue =>
    EvaPalette.forSkin(skin).theme(settings.accent),
  ExperimentalUiSkin.off => null,
};
```

> 新皮肤只需在 [ArchiveSkinScope](file:///d:/work/Overtone/app/lib/shared/widgets/archive_skin_scope.dart) 的 `switch` 里挂一个分支。皮肤在桌面与移动端一致生效；`ThemeData.brightness` 由皮肤自己决定（swiss 与 EVA 蓝恒为浅色，EVA 红恒为深色），与「外观」设置无关，状态栏/导航栏由 Scope 按皮肤主题同步。

---

## 4. 已有实验 UI 案例参考

### 1. 瑞士国际排版 (`swiss`)
- **设计基调**：纸白底色（`#F5F5F7`）、极黑正文（`#111111`）、单主色瑞士红（`#E53935`）、编号导向（`01 / NOW PLAYING`）、网格点阵底纹、冷峻强对比度。
- **生效条件**：桌面端与移动端一致生效；选中即覆盖外观设置，全站切换为浅色纸面（移动端同样生效）。

### 2. EVA 战术终端 (`magi` / `evaBlue`)

红蓝两套**共用同一套版式、组件与文案**，只切调色板与角色元素；页面里不要为蓝版新增分支，用 `skin.isEva` 判定家族。

- **设计基调**：福音战士海报 / NERV 终端。硬边直角、白/蓝结构线分区、大字号对比、角色水印。
  - **EVA 红（`magi` · 贰号机）**：纯黑底 `#070709`，白结构线，朱红 `#E60012`；`EvaPalette.unit02`。
  - **EVA 蓝（`evaBlue` · 零号机）**：瓷白底 `#EFF6FA`，冰蓝结构线与主色 `#176B91`，酒红 `#AD3D57` 只做危险标记；`EvaPalette.unit00`。色值对齐参考项目 `dsh-plugin-eva-theme` 的绫波丽亮色令牌。
- **取色**：组件内一律 `final ev = context.eva;`（`ArchiveSkinActive.skinOf` 的调色板），不要再写死颜色；两套色值都在 `eva_palette.dart`。
- **氛围层**：`MagiBackdrop` 统一负责底色、48px 网格与 NERV 徽记，外加当前驾驶员的半身线稿水印（红版明日香 17%、蓝版绫波丽 19%，均 `srcIn` 按主色染色，窄屏收起）。蓝版另有「00」环阵 + 边缘刻度；徽记在蓝版整体染冰蓝。
- **专属组件**：
  - `MagiTargetFrame`：封面描边框，`TARGET` / `CODE` 角标叠在封面角上，不占额外纵向空间（蓝版角标是深海军蓝表头 + 白字）
  - `MagiEqualizerBar`：阶梯频谱
  - `MagiConsensusBar`：单行 MELCHIOR-1 / BALTHASAR-2 / CASPAR-3 状态带
  - `MagiProgressGauge`：`T-` 剩余时间 + `TOTAL` 总长 + 刻度槽（含可拖动播放头）
  - `MagiHazardBar`：整条结构线 + 左端强调块（蓝版沿用参考稿的酒红胶带）
  - `MagiFrameCorners`：四角定位标尺
  - `MagiTagButton`：直角硬边按钮，强调态整块反色
  - `MagiStatusLed`：呼吸式同步灯（外壳用静态模式，避免 `pumpAndSettle` 挂起）
- **页面级差异**：发现页页头为「编号条 + 大标题 + 日文副标题」；侧栏编号（壱弐参…）与 `[ 发现 ]` 选中态；Dock / 播放条硬边 + 结构线。

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
