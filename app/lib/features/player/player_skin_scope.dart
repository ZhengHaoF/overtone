import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/archive_skin.dart';
import '../settings/settings_controller.dart';

/// 给播放页套上「档案终端」皮肤（实验性，默认关）。
///
/// **必须包在页面之外**（路由与页面之间），不能写在页面 build 里：页面的
/// `OvertoneTheme.of(context)` 读的是自己那个 BuildContext，包层若在其下方，
/// 页内那几十处取值仍然拿到旧调色板，只有子组件会变——那是半迁移的观感。
///
/// 关掉时直接返回 child，不产生任何额外 Widget。
class PlayerSkinScope extends ConsumerWidget {
  const PlayerSkinScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final skin = ArchiveSkin.resolve(
      context,
      enabled: settings.playerSkinArchive,
      accent: settings.accent,
    );
    if (skin == null) {
      return ArchiveSkinActive(active: false, child: child);
    }
    return ArchiveSkinActive(
      active: true,
      child: Theme(data: skin, child: child),
    );
  }
}
