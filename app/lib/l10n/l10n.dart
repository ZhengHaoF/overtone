import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// 全局当前语言。
///
/// UI 层请用 `context.l10n`（依赖 Localizations，切语言会重建）；
/// 这个 getter 是给没有 BuildContext 的地方兜底：数据层错误文案、
/// 独立进程（桌面歌词子进程）、单元测试。
AppLocalizations get l10n => _current;

AppLocalizations _current = lookupAppLocalizations(const Locale('zh'));

/// 启动恢复设置、以及设置页切换语言时调用。
void setAppLocale(Locale locale) {
  _current = lookupAppLocalizations(locale);
}

/// 当前生效的 Locale（多窗口 / 独立进程里的 MaterialApp 直接用它）。
Locale get appLocale => Locale(_current.localeName);

extension AppL10nX on BuildContext {
  /// 优先跟随 MaterialApp 的 locale；测试里自建 MaterialApp 没挂 delegate
  /// 时退回全局实例（默认中文），既有断言不受影响。
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ?? _current;
}
