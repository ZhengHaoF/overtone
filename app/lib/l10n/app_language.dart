import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'l10n.dart';

/// 界面语言落盘键（设置页写、歌词子进程读）。
const String kLanguagePrefKey = 'settings.language';

/// 界面语言。`system` 跟随系统；其余为显式选择。
enum AppLanguage {
  system,
  zh,
  en,
  ja,
  ko;

  /// 显式语言对应 Locale；`system` 返回 null（交给 MaterialApp 解析）。
  Locale? get locale => switch (this) {
        system => null,
        zh => const Locale('zh'),
        en => const Locale('en'),
        ja => const Locale('ja'),
        ko => const Locale('ko'),
      };

  /// 语言名用**自身语言**书写（English / 日本語 / 한국어），跟随系统时用当前 UI 语言。
  String get label => switch (this) {
        system => l10n.genSuiXiTong,
        zh => '简体中文',
        en => 'English',
        ja => '日本語',
        ko => '한국어',
      };

  static AppLanguage fromWire(String? wire) {
    for (final v in AppLanguage.values) {
      if (v.name == wire) return v;
    }
    return AppLanguage.system;
  }
}

/// 设置值 → 实际生效的 Locale。`system` 取平台语言里第一个受支持的（按语言码匹配）。
Locale resolveAppLocale(AppLanguage language) {
  final explicit = language.locale;
  if (explicit != null) return explicit;
  final platform = WidgetsBinding.instance.platformDispatcher.locale;
  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == platform.languageCode) return supported;
  }
  return AppLocalizations.supportedLocales.first;
}

/// 更新全局兜底文案实例（数据层 / 独立进程 / 测试用）。
void applyAppLanguage(AppLanguage language) {
  setAppLocale(resolveAppLocale(language));
}

/// 独立进程（桌面歌词）启动时直接读盘恢复语言，不经过 SettingsController。
Future<void> restoreAppLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  applyAppLanguage(AppLanguage.fromWire(prefs.getString(kLanguagePrefKey)));
}
