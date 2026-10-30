import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:overtone/l10n/l10n.dart';

/// 运行时包版本。唯一来源是 `pubspec.yaml` 的 `version`，构建时由 Flutter
/// 写进 Android `versionName` / Windows 资源 / 安装包，这里再读回来展示，
/// 避免 UI 里另存一份字符串。
abstract final class AppInfo {
  static String version = '';

  /// 展示用版本号；读取失败时明说「未知」而不是留空或猜一个。
  static String get versionLabel => version.isEmpty ? l10n.weiZhiShort : version;

  static Future<void> load() async {
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (error) {
      debugPrint(l10n.appInfoDuQuBanBenShiBai(error));
    }
  }
}
