# 泛音 Overtone — 工程说明

多音源第三方 Flutter 音乐客户端（学习 / 研究向）。功能矩阵、下载与截图见[根 README](../README.md)。

## 环境

- Flutter 3.47.7 / Dart 3.13.5（仓库固定验证版本）
- Android SDK API 24+

## 运行

```bash
cd app
flutter pub get
flutter run -d <device-id>
```

## 构建

```bash
flutter build apk --release        # Android
flutter build windows --release    # Windows
flutter build linux --release --no-pub  # Linux（源码构建，无发行包）
```

Android 正式签名使用本机 `android/key.properties` + keystore（均不入库）；CI 的三种 ABI 签名 APK、Windows 安装程序与绿色 ZIP 见[交付说明](../docs/release-packaging.md)。

Linux 仅提供源码 / 本地构建；Wayland 全局悬浮歌词按现行决策暂缓，原生 Wayland 与未知后端使用应用内歌词，基础播放、MPRIS 与存储不受影响。

## 模块

```text
lib/
├─ core/           # tokens · models · api · mock · source（MusicSource 契约）· cache · platform
├─ data/           # repositories · sources/kugou（KugouSource + KugouSession）· storage（Drift）
├─ features/       # explore · discovery · profile · player · fm · likes · auth · settings · desktop_lyric · ui_demo · debug …
├─ l10n/           # 四语文案（app_<locale>.arb）+ gen-l10n 产物 + 全局 l10n 门面
└─ shared/         # widgets · shell · tray（托盘/关闭行为）· taskbar（Thumbar/进度）
```

## 多语言

界面支持 **简体中文 / English / 日本語 / 한국어**，默认跟随系统，可在「设置 → 语言」切换并落盘（`settings.language`）。

- 文案唯一来源：`lib/l10n/app_zh.arb`（模板）。新增词条先加中文，再补 `app_en/ja/ko.arb`；
  `flutter gen-l10n`（`flutter build/run` 也会自动跑）生成 `lib/l10n/app_localizations*.dart`。
- 取词：Widget 里用 `context.l10n.xxx`（依赖 Localizations，切语言即刻重建）；
  数据层、托盘、独立歌词进程等没有 `BuildContext` 的地方用全局 `l10n.xxx`。
  带参数的消息是方法，占位符统一 `{p1}`、`{p2}`。
- **不翻译**：品牌词（泛音 / Overtone）、MAGI 的日式数字与章节符号（壱弐参…）、
  服务端内容（歌名、歌手、歌单名、榜单名、评论）、以及用于识别上游返回的字符串
  （如 `URL过滤`、`Access Deny`、网易歌单名「我喜欢」——这些是控制信号，不是文案）。
- 桌面歌词子进程不经过 `SettingsController`，启动时直接读 `settings.language` 恢复语言。
- Windows 任务栏缩略图按钮的 tooltip 由 Dart 侧按当前语言下发（`TaskbarBridge.updateButtons(tips:)`），
  原生只在缺省时回退中文。
- 字体：正文 MiSans 覆盖中英；日文假名 / 韩文由系统字体回退，展示用衬线体（`OvertoneSerif` 为中文子集）
  在日/韩下会回退到系统字体。

测试护栏：`test/flutter_test_config.dart` 把测试默认语言钉成中文（既有断言都按中文写）；
`test/i18n_catalog_test.dart` 校验四语键集一致、占位符一致、英/韩无残留中文；
`test/i18n_layout_en_test.dart` 用英文跑一遍桌面外壳，防止英文文案把布局撑溢出。

## 网络说明

部分网络会把 `*.kugou.com` 拦成「URL过滤」HTML，App 会识别并提示，请更换热点或加入路由器白名单。详见 [api-notes](../docs/api-notes.md)。

## 合规

个人学习与研究用途。不提供音频中转或账号托管；请遵守当地法律与平台服务条款。对外发布请勿使用「酷狗」注册商标作为应用名。
