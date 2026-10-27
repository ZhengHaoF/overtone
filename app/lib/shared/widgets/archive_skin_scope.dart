import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/responsive.dart';
import '../../features/settings/settings_controller.dart';

/// 给需要实验性 UI（瑞士国际排版 / MAGI 战术终端等）的页面套上皮肤。
class ArchiveSkinScope extends ConsumerWidget {
  const ArchiveSkinScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final skin = settings.experimentalUi;

    ThemeData? skinTheme;
    if (skin == ExperimentalUiSkin.swiss) {
      skinTheme = ArchiveSkin.resolve(
        context,
        enabled: true,
        accent: settings.accent,
      );
    } else if (skin == ExperimentalUiSkin.magi) {
      skinTheme = isDesktopView(context)
          ? MagiSkin.theme(settings.accent)
          : null;
    }

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
