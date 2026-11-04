import 'package:flutter/material.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_tokens.dart';
import 'liquid_glass.dart';

/// 旧名保留：默认皮肤既有的毛玻璃面板 API。
///
/// 内部已换成 [LiquidGlass]（regular 层级），调用点无需改动；
/// 新代码请直接用 [LiquidGlass] 并按场景选 [GlassTier]。
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.height,
    this.radius = OvertoneRadius.bar,
    this.padding = const EdgeInsets.symmetric(horizontal: OvertoneSpacing.sm),
    this.shadow,
    this.blurSigma,
    this.scrim,
    this.tint,
  });

  final Widget child;

  /// 固定高度；为 null 时由 [child] 撑开。
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// 面板投影。玻璃的立体感主要靠边缘高光，投影保持轻。
  final List<BoxShadow>? shadow;

  /// 覆盖默认模糊半径（滚动降级时由调用方传更小的值）。
  final double? blurSigma;

  /// 玻璃底色。默认取该层级参数（regular）。
  final Color? scrim;

  /// 自适应染色：当前播放封面的主色。
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      tier: GlassTier.regular,
      radius: radius,
      height: height,
      padding: padding,
      shadow: shadow,
      scrim: scrim,
      tint: tint,
      blurSigma: blurSigma,
      child: child,
    );
  }
}
