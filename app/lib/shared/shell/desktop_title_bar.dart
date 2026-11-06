import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/overtone_theme.dart';
import '../widgets/archive_chrome.dart';
import 'package:overtone/l10n/l10n.dart';

/// 自绘窗口标题栏（Windows）。
///
/// 配合 `windowManager.setTitleBarStyle(TitleBarStyle.hidden)` 使用：
/// 系统标题栏不再绘制，本组件负责拖拽移动 / 最小化 / 最大化 / 关闭。
/// 关闭走 shell 的 `setPreventClose` 链路（托盘），这里只发 `windowManager.close()`。
///
/// 皮肤分工：
/// - 档案 / MAGI：36px 硬边平铺（下沿一条 [ArchiveChrome.lineStrong]），
///   与侧栏、播放栏同一套硬边语言。
/// - 默认：不绘制底与边框，窗口底色直接透上来。
class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({super.key, this.onClose});

  /// 可选：接管关闭（关到托盘）。为空则调 `windowManager.close()`。
  final Future<void> Function()? onClose;

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

    final glass = context.isGlassSkin;
    // 玻璃皮肤：36px 玻璃条 + 顶部柔和光带。标题栏背后是窗口背景，没有可采样
    // 内容，所以这里只用染色/描边（blurred:false 的等价实现），不白挂一次模糊。
    return Container(
      height: 36,
      decoration: archive
          ? BoxDecoration(
              color: theme.bg,
              border: Border(
                bottom: BorderSide(color: ArchiveChrome.lineStrong(theme)),
              ),
            )
          : glass
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.palette.isLight
                    ? [
                        Colors.white.withValues(alpha: 0.62),
                        Colors.white.withValues(alpha: 0.24),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.03),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(
                    alpha: theme.palette.isLight ? 0.72 : 0.12,
                  ),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(child: _dragRegion(context, theme, archive, null)),
          _TitleBarButton(
            tooltip: context.l10n.zuiXiaoHua,
            icon: Icons.remove_rounded,
            onTap: () async {
              try {
                await windowManager.minimize();
              } catch (_) {}
            },
          ),
          _TitleBarButton(
            tooltip: _maximized ? context.l10n.huanYuan : context.l10n.zuiDaHua,
            icon: _maximized
                ? Icons.filter_none_rounded
                : Icons.crop_square_rounded,
            onTap: _toggleMaximize,
          ),
          _TitleBarButton(
            tooltip: context.l10n.guanBi,
            icon: Icons.close_rounded,
            hoverColor: const Color(0xFFE81123),
            hoverForeground: Colors.white,
            onTap: () => _onClose(),
          ),
        ],
      ),
    );
  }

  Future<void> _onClose() async {
    try {
      if (widget.onClose != null) {
        await widget.onClose!();
      } else {
        await windowManager.close();
      }
    } catch (_) {}
  }

  /// 整条可拖拽；按钮区各自吞掉命中，避免点按钮也拖窗口。
  ///
  /// [foreground] 非空时给「泛音」用主文字色。
  Widget _dragRegion(
    BuildContext context,
    OvertoneTheme theme,
    bool archive,
    Color? foreground,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) {
        try {
          windowManager.startDragging();
        } catch (_) {}
      },
      onDoubleTap: _toggleMaximize,
      child: Padding(
        // 左内边距 20：与侧栏 logo 区左对齐；右内边距 8：与按钮组留一点呼吸。
        padding: const EdgeInsets.only(left: 20, right: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (archive) ...[
                Container(width: 3, height: 10, color: theme.primary),
                const SizedBox(width: 8),
              ],
              if (foreground != null)
                Text(
                  context.l10n.fanYin,
                  style: theme.caption.copyWith(
                    fontSize: 12,
                    letterSpacing: archive ? 1.6 : null,
                    color: foreground,
                  ),
                ),
            ],
          ),
        ),
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
  });

  final String tooltip;
  final IconData icon;
  final Future<void> Function() onTap;
  final Color? hoverColor;
  final Color? hoverForeground;

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
        : theme.textSecondary;

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
              // 横向补足 48dp 命中下限；纵向受栏高限制。
              width: 48,
              height: 36,
              color: bg,
              child: Icon(widget.icon, size: 16, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
