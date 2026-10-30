import 'package:flutter/material.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/overtone_theme.dart';

/// 「档案终端」皮肤的通用视觉原语（播放页与内容页共用）。
///
/// 播放页与歌曲详情页的密度不同：播放页可以铺发丝网格，内容页是成段文字，
/// 所以颜色分 `rule`（淡，给网格/刻度）与 `lineStrong`（深，给正文分隔与边框）。
abstract final class ArchiveChrome {
  /// 发丝网格用的分隔线，比 [OvertonePalette.divider] 再淡一档：
  /// divider 是给列表分隔用的，铺满整屏会压过内容。
  static Color gridLine(OvertoneTheme t) =>
      t.divider.withValues(alpha: t.divider.a * 0.4);

  static Color rule(OvertoneTheme t) => t.divider;

  /// 内容页正文区的细线：divider 在满屏文字下太淡，单列排版用这一档。
  static Color lineStrong(OvertoneTheme t) =>
      t.textTertiary.withValues(alpha: 0.6);

  static Color faint(OvertoneTheme t) => t.textTertiary;
}

/// 纸白发丝网格 + 边缘刻度尺（整屏背景）。
class ArchiveGridPainter extends CustomPainter {
  ArchiveGridPainter({required this.theme});

  final OvertoneTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.bg);
    final hair = Paint()
      ..color = ArchiveChrome.gridLine(theme)
      ..strokeWidth = 1;
    final ruler = Paint()
      ..color = ArchiveChrome.rule(theme)
      ..strokeWidth = 1;

    const step = 56.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hair);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hair);
    }
    for (double x = 0; x < size.width; x += 14) {
      final tall = (x / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, tall ? 11 : 5),
        tall ? ruler : hair,
      );
    }
    for (double y = 0; y < size.height; y += 14) {
      final tall = (y / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(tall ? 11 : 5, y),
        tall ? ruler : hair,
      );
    }
  }

  @override
  bool shouldRepaint(ArchiveGridPainter old) => old.theme != theme;
}

/// 档案纸面背景：网格铺满父级、内容在其上滚动。
class ArchiveGridBackdrop extends StatelessWidget {
  const ArchiveGridBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: ArchiveGridPainter(theme: theme)),
          ),
        ),
        child,
      ],
    );
  }
}

/// 档案皮肤的页面骨架：透明 Scaffold + 网格 body。
///
/// 主 tab 页统一用它，皮肤关闭时行为与普通 Scaffold 一致。
class ArchivePageScaffold extends StatelessWidget {
  const ArchivePageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final archive = ArchiveSkinActive.of(context);
    // EVA 皮肤由 MagiBackdrop 画网格与角色线稿；档案网格的底色是不透明的，
    // 套在这里会把底板盖掉，所以 EVA 下只保留透明 Scaffold。
    final eva = ArchiveSkinActive.skinOf(context).isEva;
    return Scaffold(
      backgroundColor: archive ? Colors.transparent : backgroundColor,
      appBar: appBar,
      body: archive && !eva ? ArchiveGridBackdrop(child: body) : body,
    );
  }
}

/// 6px 间距的刻度尺，卡片与分区之间用。
class ArchiveRuler extends StatelessWidget {
  const ArchiveRuler({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: CustomPaint(painter: _RulerPainter(OvertoneTheme.of(context))),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter(this.theme);

  final OvertoneTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = ArchiveChrome.rule(theme)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      final tall = (x / 6).round() % 4 == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, tall ? 6 : 3), p);
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.theme != theme;
}

class ArchiveTicks extends StatelessWidget {
  const ArchiveTicks({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 2,
            height: 6,
            margin: const EdgeInsets.only(right: 3),
            color: ArchiveChrome.rule(theme),
          ),
      ],
    );
  }
}

/// 分区标题：3px 强调竖条 + 拉开字距的小标签。
class ArchiveSectionLabel extends StatelessWidget {
  const ArchiveSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3, height: 12, color: theme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 顶部元信息行：左侧主标签、右侧权限/状态，照参考项目 `.detail-kicker`。
class ArchiveKicker extends StatelessWidget {
  const ArchiveKicker({super.key, required this.left, this.right});

  final String left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: theme.textSecondary,
            ),
          ),
        ),
        if (right != null) ...[
          const SizedBox(width: 12),
          Text(
            right!,
            style: theme.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: theme.textTertiary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

/// 档案元信息里的一个字段。
class ArchiveMeta {
  const ArchiveMeta(this.label, this.value);

  final String label;
  final String value;
}

/// 两列元信息网格，照参考项目 `.metadata`（9px 标签 + 方块前缀）。
class ArchiveMetaGrid extends StatelessWidget {
  const ArchiveMetaGrid({super.key, required this.items, this.gap = 24});

  final List<ArchiveMeta> items;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 18,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: theme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(width: 4, height: 4, color: theme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: theme.textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 描边 tag 按钮：这套皮肤里的所有次级操作都长这样。
class ArchiveTagButton extends StatelessWidget {
  const ArchiveTagButton({
    super.key,
    this.label,
    this.icon,
    required this.tooltip,
    this.onPressed,
    this.emphasized = false,
    this.strong = false,
    this.large = false,
  });

  final String? label;
  final IconData? icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// 主操作（播放/暂停）用实心墨块，其余描边。
  final bool emphasized;

  /// 内容页正文区用更实的描边；播放页保持原来的淡线。
  final bool strong;

  /// 播放/暂停这类主操作里再升一档尺寸：更大高度与更宽字距，拉开层级。
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final enabled = onPressed != null;
    final fg = enabled
        ? (emphasized ? theme.surface : theme.textPrimary)
        : ArchiveChrome.faint(theme);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: BoxConstraints(
            minWidth: large ? 72 : 40,
            minHeight: large ? 44 : 32,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: large ? 18 : 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: emphasized && enabled
                ? theme.textPrimary
                : Colors.transparent,
            border: Border.all(
              color: emphasized && enabled
                  ? theme.textPrimary
                  : (strong
                        ? ArchiveChrome.lineStrong(theme)
                        : ArchiveChrome.rule(theme)),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 20, color: fg),
              if (icon != null && label != null) const SizedBox(width: 6),
              if (label != null)
                Text(
                  label!,
                  style: theme.caption.copyWith(
                    fontSize: large ? theme.body.fontSize : null,
                    color: fg,
                    fontWeight: FontWeight.w600,
                    letterSpacing: large ? 1.6 : 0.8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
