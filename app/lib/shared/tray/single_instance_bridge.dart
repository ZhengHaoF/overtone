import 'package:flutter/services.dart';

/// 单实例唤醒：第二个进程启动时，`windows/runner/main.cpp` 用互斥量判重，
/// 并通过 `Overtone.Activate` 广播让已存在的主窗唤回前台（见
/// `flutter_window.cpp` 的 `HandleActivateRequest`）。
///
/// Dart 侧收到后走 [windowManager.show] 那条路，而不是只让原生 `ShowWindow`：
/// 否则 window_manager 的可见状态、任务栏缩略图会和真实窗口对不上。
class SingleInstanceBridge {
  static const MethodChannel _channel = MethodChannel(
    'overtone/single_instance',
  );

  static bool _listening = false;

  /// 只在主 isolate 调用一次。[onActivate] 通常是 `DesktopShell.showWindow`。
  static void ensureListening(Future<void> Function() onActivate) {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'activate') {
        await onActivate();
      }
    });
  }
}
