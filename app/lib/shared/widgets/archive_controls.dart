import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/overtone_theme.dart';
import 'archive_chrome.dart';

/// 内容页用的档案交互件：主操作、标签页、输入入口、筛选 chip。
///
/// 与 `archive_chrome.dart` 的分工：那边是纯视觉原语，这边是带点击态的控件。

/// 46px 主/次操作块：描边或实心墨块，左文右图标（参考 `.solid-button`）。
class ArchiveActionButton extends StatelessWidget {
  const ArchiveActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.emphasized = false,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool emphasized;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final enabled = onPressed != null && !loading;
    final fg = enabled
        ? (emphasized ? theme.surface : theme.textPrimary)
        : ArchiveChrome.faint(theme);
    final borderColor = emphasized
        ? (enabled ? theme.textPrimary : ArchiveChrome.rule(theme))
        : ArchiveChrome.lineStrong(theme);
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: emphasized && enabled ? theme.textPrimary : Colors.transparent,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: fg,
                ),
              ),
            ),
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: fg),
              )
            else if (icon != null)
              Icon(icon, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}

/// 一档标签页的声明。
class ArchiveTabSpec {
  const ArchiveTabSpec({
    required this.id,
    required this.label,
    this.countLabel,
  });

  final String id;
  final String label;
  final String? countLabel;
}

/// 参考 `.detail-tabs`：底部一条发丝线，选中项压 2px 墨条。
class ArchiveTabBar extends StatelessWidget {
  const ArchiveTabBar({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ArchiveTabSpec> tabs;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ArchiveChrome.lineStrong(theme)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            _tab(theme, tabs[i], last: i == tabs.length - 1),
        ],
      ),
    );
  }

  Widget _tab(OvertoneTheme theme, ArchiveTabSpec tab, {required bool last}) {
    final active = tab.id == selectedId;
    final color = active ? theme.textPrimary : theme.textTertiary;
    return InkWell(
      onTap: () => onSelect(tab.id),
      child: Padding(
        padding: EdgeInsets.only(right: last ? 0 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    style: theme.caption.copyWith(
                      letterSpacing: 0.8,
                      color: color,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  if (tab.countLabel != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      tab.countLabel!,
                      style: theme.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: theme.textTertiary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              height: 2,
              color: active ? theme.textPrimary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

/// 方形输入入口：替代圆角输入框。
class ArchiveField extends StatelessWidget {
  const ArchiveField({
    super.key,
    required this.hint,
    this.icon = Icons.edit_outlined,
    this.onTap,
  });

  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: ArchiveChrome.lineStrong(theme)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.caption.copyWith(
                  letterSpacing: 0.6,
                  color: theme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 方形筛选 chip：选中态墨块反白，与参考项目的 pressed 态一致。
class ArchiveChip extends StatelessWidget {
  const ArchiveChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final fg = selected ? theme.surface : theme.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: selected ? 8 : 12,
            top: 7,
            bottom: 7,
          ),
          decoration: BoxDecoration(
            color: selected ? theme.textPrimary : Colors.transparent,
            border: Border.all(
              color: selected
                  ? theme.textPrimary
                  : ArchiveChrome.lineStrong(theme),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.caption.copyWith(
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 4),
                Icon(Icons.close_rounded, size: 14, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 发丝进度线：已播段实线、未播段淡线、每 10% 一道刻度，游标是一根竖线。
///
/// 不用 Slider —— Slider 的 track 有最小高度与触摸垫，画不出 1px 的发丝感。
/// 拖动语义与 Slider 一致：按下/拖动只更新预览，松手才 seek。
class ArchiveProgressRule extends StatelessWidget {
  const ArchiveProgressRule({
    super.key,
    required this.value,
    required this.onDrag,
    required this.onEnd,
  });

  final double value;
  final void Function(double ratio) onDrag;
  final void Function(double ratio) onEnd;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        // 点哪跳哪：down 先给一次预览，up 才真正 seek。
        onTapDown: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onTapUp: (d) =>
            onEnd((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragStart: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragUpdate: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragEnd: (d) => onEnd(
          (d.localPosition.dx / math.max(1.0, box.maxWidth)).clamp(0.0, 1.0),
        ),
        child: SizedBox(
          height: 22,
          child: CustomPaint(
            painter: _ProgressRulePainter(
              theme: theme,
              value: value.clamp(0.0, 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRulePainter extends CustomPainter {
  _ProgressRulePainter({required this.theme, required this.value});

  final OvertoneTheme theme;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final played = size.width * value;
    final rest = Paint()
      ..color = ArchiveChrome.gridLine(theme)
      ..strokeWidth = 1;
    final done = Paint()
      ..color = theme.textPrimary
      ..strokeWidth = 2;
    final tick = Paint()
      ..color = ArchiveChrome.rule(theme)
      ..strokeWidth = 1;
    final cursor = Paint()
      ..color = theme.primary
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, mid), Offset(size.width, mid), rest);
    if (played > 0) {
      canvas.drawLine(Offset(0, mid), Offset(played, mid), done);
    }
    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, mid - 5), Offset(x, mid + 5), tick);
    }
    canvas.drawLine(Offset(played, mid - 9), Offset(played, mid + 9), cursor);
  }

  @override
  bool shouldRepaint(_ProgressRulePainter old) =>
      old.value != value || old.theme != theme;
}
