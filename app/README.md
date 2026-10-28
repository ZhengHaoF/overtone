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
└─ shared/         # widgets · shell · tray（托盘/关闭行为）· taskbar（Thumbar/进度）
```

## 网络说明

部分网络会把 `*.kugou.com` 拦成「URL过滤」HTML，App 会识别并提示，请更换热点或加入路由器白名单。详见 [api-notes](../docs/api-notes.md)。

## 合规

个人学习与研究用途。不提供音频中转或账号托管；请遵守当地法律与平台服务条款。对外发布请勿使用「酷狗」注册商标作为应用名。
