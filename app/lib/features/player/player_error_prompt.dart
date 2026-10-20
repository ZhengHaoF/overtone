import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_navigator.dart';
import '../profile/source_account.dart';
import 'player_controller.dart';

/// MaterialApp 级播放错误提示。
///
/// 登录类失败只弹一次（播放态从非 error 进入 error 时），并给出对应音源的
/// 登录入口。挂在 MaterialApp.builder 上而不是某个页面里：全屏播放页
/// （`/player`）是 shell 外的顶级路由，页面内提示在桌面端也根本不存在。
class PlayerErrorPrompt extends ConsumerWidget {
  const PlayerErrorPrompt({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlayerState>(playerControllerProvider, (previous, next) {
      final justFailed =
          next.display == PlayerDisplayState.error &&
          previous?.display != PlayerDisplayState.error;
      if (!justFailed || next.errorKind != PlayerErrorKind.loginRequired) {
        return;
      }
      final platform = next.current?.platform;
      final messenger = overtoneScaffoldMessengerKey.currentState;
      if (platform == null || messenger == null) return;

      final loginRoute = loginRouteFor(platform);
      final alreadyOnLogin =
          router.routerDelegate.currentConfiguration.uri.path == loginRoute;
      final message = next.errorCode.trim().isEmpty
          ? '${platform.label}播放需要登录'
          : next.errorCode.trim();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
            action: alreadyOnLogin
                ? null
                : SnackBarAction(
                    label: '去登录',
                    onPressed: () => router.push(loginRoute),
                  ),
          ),
        );
    });
    return child;
  }
}
