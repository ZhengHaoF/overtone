import 'package:flutter/material.dart';

import '../../core/theme/responsive.dart';

/// 内容页统一页头 —— 与「每日推荐」同一条 AppBar 带。
///
/// 高度 / 左右内边距 / 标题字号 / 分隔线全部由皮肤的 `appBarTheme` 决定。
/// 页面不要再在 body 里手写标题行：手写头拿不到这些，标题会跟着滚动区一起
/// 漂，右边距也会被外层 padding 叠加成另一套数。
///
/// 返回裸 `AppBar` 而不是包一层 `PreferredSize`：`Scaffold` 只有在
/// `appBar.preferredSize` 来自 AppBar 自己的 `_PreferredAppBarSize` 时才会
/// 采用 `AppBarTheme.toolbarHeight`（瑞士皮肤 52），包一层就会退回 56。
AppBar overtonePageHeader(
  BuildContext context, {
  required Widget title,
  List<Widget> actions = const [],
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    title: title,
    actions: actions,
    bottom: bottom,
    // 桌面端靠侧栏导航，返回键冗余；移动端交给 Navigator 按 canPop 判断。
    automaticallyImplyLeading: !isDesktopView(context),
  );
}
