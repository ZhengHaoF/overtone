import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/archive_skin.dart';
import '../../features/settings/settings_controller.dart';

/// 给需要「档案终端」皮肤的页面套上皮肤（实验性，默认关）。
///
/// 目前覆盖播放页与歌曲详情页。**必须包在页面之外**（路由与页面之间），不能
/// 写在页面 build 里：页面的 `OvertoneTheme.of(context)` 读的是自己那个
/// BuildContext，包层若在其下方，页内那几十处取值仍然拿到旧调色板，只有子组件
/// 会变——那是半迁移的观感。
///
/// 关掉时仍发 `ArchiveSkinActive(active: false)`，让页面不必判空。
class ArchiveSkinScope extends ConsumerWidget {
  const ArchiveSkinScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final skin = ArchiveSkin.resolve(
      context,
      enabled: settings.archiveSkin,
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

/// 便捷包层：`child.withArchiveSkin()` 等价于 `ArchiveSkinScope(child: child)`。
extension ArchiveSkinWrap on Widget {
  Widget withArchiveSkin() => ArchiveSkinScope(child: this);
}
