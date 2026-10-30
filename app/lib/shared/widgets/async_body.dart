import 'package:flutter/material.dart';

import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import 'package:overtone/l10n/l10n.dart';

/// Loading / empty / error body shell used across list pages.
class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.loading,
    required this.hasError,
    required this.isEmpty,
    required this.child,
    this.onRetry,
    this.emptyMessage = '',
    this.errorMessage = '',
  });

  final bool loading;
  final bool hasError;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    // 三态（骨架 / 错误 / 空 / 内容）之间做交叉淡入 + 8px 上移，而不是 if 硬切：
    // 请求一回来整页「啪」地换掉，是这个 app 最明显的糙点之一。
    final Widget target;
    if (loading) {
      target = const KeyedSubtree(
        key: ValueKey('async-loading'),
        child: SkeletonList(),
      );
    } else if (hasError) {
      target = KeyedSubtree(
        key: const ValueKey('async-error'),
        child: _StatusView(
          icon: Icons.wifi_off_rounded,
          message: errorMessage,
          actionLabel: context.l10n.chongShi,
          onAction: onRetry,
        ),
      );
    } else if (isEmpty) {
      target = KeyedSubtree(
        key: const ValueKey('async-empty'),
        child: _StatusView(
          icon: Icons.music_off_rounded,
          message: emptyMessage,
          actionLabel: onRetry == null ? null : context.l10n.shuaXin,
          onAction: onRetry,
        ),
      );
    } else {
      target = KeyedSubtree(
        key: const ValueKey('async-content'),
        child: child,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: target,
    );
  }
}

class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  // 整列骨架共用一个 ticker：每行按相位错开，不再一行挂一个
  // AnimationController（三个详情页首屏同时加载时就是十几个常驻 ticker）。
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(OvertoneSpacing.lg),
      itemCount: widget.itemCount,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: OvertoneSpacing.md),
        child: _SkeletonRow(
          opacity: _controller.drive(_PhaseWaveTween(phase: index * 0.12)),
        ),
      ),
    );
  }
}

/// 相位错开的呼吸曲线：0.35 ↔ 0.8，隔行相差 [phase] 个周期。
///
/// 只走动画求值（FadeTransition 直接读），不触发 widget 重建。
class _PhaseWaveTween extends Tween<double> {
  _PhaseWaveTween({required this.phase}) : super(begin: 0.35, end: 0.8);

  final double phase;

  @override
  double transform(double t) {
    final shifted = (t + phase) % 1.0;
    final wave = shifted <= 0.5 ? shifted * 2 : (1.0 - shifted) * 2;
    return 0.35 + 0.45 * Curves.easeInOut.transform(wave);
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.opacity});

  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return FadeTransition(
      opacity: opacity,
      child: Row(
        children: [
          _box(theme, 52, 52, radius: OvertoneRadius.cover),
          const SizedBox(width: OvertoneSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(theme, double.infinity, 14),
                const SizedBox(height: 8),
                _box(theme, 120, 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(OvertoneTheme theme, double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: theme.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.textTertiary),
          const SizedBox(height: OvertoneSpacing.md),
          Text(message, style: theme.caption),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: OvertoneSpacing.lg),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
