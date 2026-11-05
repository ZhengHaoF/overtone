import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import '../widgets/archive_chrome.dart';
import '../widgets/liquid_glass.dart';
import 'package:overtone/l10n/l10n.dart';

/// 自绘窗口标题栏（Windows）。
///
/// 配合 `windowManager.setTitleBarStyle(TitleBarStyle.hidden)` 使用：
/// 系统标题栏不再绘制，本组件负责拖拽移动 / 最小化 / 最大化 / 关闭。
/// 高度刻意压到 36，把纵向空间还给内容；关闭走 shell 的 `setPreventClose`
/// 链路（托盘），这里只发 `windowManager.close()`。
class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({
    super.key,
    this.onClose,
    this.glass = false,
    this.tint,
  });

  /// 可选：接管关闭（关到托盘）。为空则调 `windowManager.close()`。
  final Future<void> Function()? onClose;

  /// 拟物浮光：标题栏变成一块悬浮玻璃（背景由 shell 的氛围底板提供）。
  final bool glass;

  /// 玻璃自适应染色（当前封面主色）。
  final Color? tint;

  @override
  State<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends State<DesktopTitleBar> {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    // 只在创建时读一次最大化态；之后靠按钮动作后的本地翻转。
    // 不挂 WindowListener：shell 已有一份，双监听容易在 hide/show
    // 过程中叠出无谓的 platform channel 往返。
    _initMaximized();
  }

  Future<void> _initMaximized() async {
    try {
      final maximized = await windowManager.isMaximized();
      if (mounted) setState(() => _maximized = maximized);
    } catch (_) {
      // 测试环境 / 窗口未就绪：保持 false。
    }
  }

  Future<void> _toggleMaximize() async {
    try {
      if (_maximized) {
        await windowManager.unmaximize();
        _maximized = false;
      } else {
        await windowManager.maximize();
        _maximized = true;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final barHeight = widget.glass && !archive ? 31.0 : 36.0;
    final content = Row(
      children: [
        // 整条可拖拽；按钮区各自吞掉命中，避免点按钮也拖窗口。
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) {
              try {
                windowManager.startDragging();
              } catch (_) {}
            },
            onDoubleTap: _toggleMaximize,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (archive) ...[
                      Container(width: 3, height: 10, color: theme.primary),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      context.l10n.fanYin,
                      style: theme.caption.copyWith(
                        fontSize: 12,
                        letterSpacing: archive ? 1.6 : null,
                        color: widget.glass
                            ? theme.textPrimary
                            : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 桌面歌词入口只留在底栏「词」/ 托盘 / 设置，标题栏不重复。
        _TitleBarButton(
          height: barHeight,
          foreground: widget.glass ? theme.textPrimary : null,
          tooltip: context.l10n.zuiXiaoHua,
          icon: Icons.remove_rounded,
          onTap: () async {
            try {
              await windowManager.minimize();
            } catch (_) {}
          },
        ),
        _TitleBarButton(
          height: barHeight,
          foreground: widget.glass ? theme.textPrimary : null,
          tooltip: _maximized ? context.l10n.huanYuan : context.l10n.zuiDaHua,
          icon: _maximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          onTap: _toggleMaximize,
        ),
        _TitleBarButton(
          height: barHeight,
          foreground: widget.glass ? theme.textPrimary : null,
          tooltip: context.l10n.guanBi,
          icon: Icons.close_rounded,
          hoverColor: const Color(0xFFE81123),
          hoverForeground: Colors.white,
          onTap: () async {
            try {
              if (widget.onClose != null) {
                await widget.onClose!();
              } else {
                await windowManager.close();
              }
            } catch (_) {}
          },
        ),
      ],
    );
    if (!widget.glass || archive) {
      return Container(
        height: 36,
        decoration: archive
            ? BoxDecoration(
                color: theme.bg,
                border: Border(
                  bottom: BorderSide(color: ArchiveChrome.lineStrong(theme)),
                ),
              )
            : null,
        child: content,
      );
    }
    // 拟物浮光：悬浮玻璃条，背景是 shell 的氛围底板；
    // 高度 5+31 保持原来的 36，不挤压内容。
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: LiquidGlass(
        tier: GlassTier.thin,
        radius: 13,
        height: 31,
        tint: widget.tint,
        padding: EdgeInsets.zero,
        shadow: const [],
        hoverElastic: true,
        child: content,
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.hoverColor,
    this.hoverForeground,
    this.foreground,
    this.height = 36,
  });

  final String tooltip;
  final IconData icon;
  final Future<void> Function() onTap;
  final Color? hoverColor;
  final Color? hoverForeground;

  /// 静止态图标色。玻璃模式传主文字色，保证透光底上仍然清晰。
  final Color? foreground;

  /// 玻璃模式下标题栏只有 31 高，按钮跟着收。
  final double height;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final bg = _hovered
        ? (widget.hoverColor ??
              theme.textPrimary.withValues(alpha: theme.isLight ? 0.08 : 0.16))
        : Colors.transparent;
    final fg = _hovered
        ? (widget.hoverForeground ?? theme.textPrimary)
        : (widget.foreground ?? theme.textSecondary);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Semantics(
          // 文案由外层 Tooltip 提供，这里只补按钮角色。
          button: true,
          child: GestureDetector(
            onTap: () => widget.onTap(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              // 横向补足 48dp 命中下限；纵向受 36px 栏高限制无法再加。
              width: 48,
              height: widget.height,
              color: bg,
              child: Icon(widget.icon, size: 16, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
