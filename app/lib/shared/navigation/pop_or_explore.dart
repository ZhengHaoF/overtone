import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 顶级路由（`/player`、`/song` 等）的返回。
///
/// 正常从列表/底栏 push 进来时 pop；直接用 `OVERTONE_ROUTE` 冷启动时栈里只有
/// 它自己，pop 会抛 `GoError: There is nothing to pop`，退回避展示页兜底。
void popOrExplore(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/explore');
  }
}
