import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/eva_palette.dart';
import '../../core/theme/overtone_theme.dart';
import '../../features/settings/settings_controller.dart';

/// EVA 家族皮肤的调色板：非 EVA 皮肤下回落到红版，调用点只应出现在
/// `skin.isEva` 为真的分支里。
extension EvaPaletteAccess on BuildContext {
  EvaPalette get eva => EvaPalette.forSkin(ArchiveSkinActive.skinOf(this));
}

/// 给需要实验性 UI（瑞士国际排版 / EVA 战术终端等）的页面套上皮肤。
class ArchiveSkinScope extends ConsumerWidget {
  const ArchiveSkinScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final skin = settings.experimentalUi;

    // 传本地化后的 textTheme：ListTile / InputDecorator 插值用的是 MaterialApp
    // 本地化那一份（inherit: false），皮肤这边不同源会抛 TextStyles 插值异常。
    final ThemeData? skinTheme = switch (skin) {
      ExperimentalUiSkin.swiss => ArchiveSkin.theme(
        settings.accent,
        textTheme: Theme.of(context).textTheme,
      ),
      ExperimentalUiSkin.magi || ExperimentalUiSkin.evaBlue =>
        EvaPalette.forSkin(skin).theme(settings.accent),
      ExperimentalUiSkin.off => null,
    };

    // 系统栏跟着**实际生效**的主题走：皮肤在根部又盖了一层 Theme，App builder
    // 里的 applyOvertoneSystemUi 只看得到外层基准主题，magi（深色皮肤 + 浅色外观）
    // 会给出看不清的状态栏图标；swiss 的导航栏也会退回标准浅色底。
    applyOvertoneSystemUi(
      skinTheme?.brightness ?? Theme.of(context).brightness,
      background: skinTheme?.extension<OvertoneTheme>()?.bg,
    );

    if (skinTheme == null) {
      return ArchiveSkinActive(
        active: false,
        skin: ExperimentalUiSkin.off,
        child: child,
      );
    }
    return ArchiveSkinActive(
      active: true,
      skin: skin,
      child: Theme(data: skinTheme, child: child),
    );
  }
}
