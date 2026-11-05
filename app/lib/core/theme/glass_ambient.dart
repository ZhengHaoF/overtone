import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// 设备姿态 → 玻璃高光的环境漂移。
///
/// 苹果 Liquid Glass 的高光会随设备运动游移。移动端没有指针，柔光完全
/// 静止的玻璃读起来像「印在屏幕上的贴图」；这里用加速度计的重力向量
/// 近似倾角，让所有玻璃的左上柔光与 rim 渐变角一起向「低的那一侧」
/// 漂移 ±GlassMotion.ambientTravel px —— 玻璃读起来是「被光照着的
/// 实体」，而不是一张静态贴图。
///
/// - 仅 Android / iOS 自动启动传感器流（桌面没有姿态传感器）；
/// - 桌面 / 特殊场景用 [attach] 接一个归一化 (-1..1) 的自定义驱动；
/// - 传感器不可用时 [tilt] 恒为 (0,0)，玻璃退回静态高光，无额外开销。
class GlassAmbient {
  GlassAmbient._();

  static final GlassAmbient instance = GlassAmbient._();

  /// 归一化倾斜。x/y ∈ [-1, 1]：+x = 右侧低，+y = 底部低。
  ///
  /// 静止时加速度计读数 ≈ 重力向量，直接除以 g 即倾角的正弦近似；
  /// 高频抖动交给下游（高光本来就只漂移 ±4px），不做额外滤波。
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);

  StreamSubscription<AccelerometerEvent>? _sub;
  ValueListenable<Offset>? _external;
  VoidCallback? _externalRemover;
  bool _started = false;

  /// 幂等启动。由第一块 [LiquidGlass] 挂载时调用，无需在 main 里初始化。
  void ensureStarted() {
    if (_started) return;
    _started = true;
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _sub = accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 50),
        ).listen(
          (event) {
            tilt.value = Offset(
              (event.x / 9.81).clamp(-1.0, 1.0),
              (event.y / 9.81).clamp(-1.0, 1.0),
            );
          },
          onError: (_) {},
          cancelOnError: false,
        );
      }
    } catch (_) {
      // 平台无传感器 / 插件未注册：保持 (0,0)，玻璃退回静态高光。
    }
  }

  /// 自定义驱动（桌面演示 / 测试）。源的取值应为归一化 (-1..1)。
  void attach(ValueListenable<Offset> source) {
    detach();
    _external = source;
    source.addListener(_onExternal);
    _externalRemover = () => source.removeListener(_onExternal);
  }

  void detach() {
    _externalRemover?.call();
    _externalRemover = null;
    _external = null;
  }

  void _onExternal() => tilt.value = _external?.value ?? Offset.zero;

  void dispose() {
    _sub?.cancel();
    detach();
  }
}
