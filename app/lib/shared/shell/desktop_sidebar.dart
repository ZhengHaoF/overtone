import 'dart:io' show Platform;

import 'package:flutter/gestures.dart' show PointerEnterEvent, PointerExitEvent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/playback_source.dart';
import '../../core/platform.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../core/source/capabilities.dart';
import '../../core/source/features.dart';
import '../../features/profile/source_account.dart';
import '../../features/settings/settings_controller.dart';
import '../../core/source/registry.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/overtone_theme.dart';
import '../../features/player/player_controller.dart';
import '../branding/app_logo.dart';
import '../widgets/archive_chrome.dart';
import '../widgets/magi_chrome.dart';
import '../widgets/archive_skin_scope.dart';

/// 桌面侧栏。展开 220 / 图标模式 64，选中指示条用绝对定位不挤占内容。
class DesktopSidebar extends ConsumerStatefulWidget {
  const DesktopSidebar({
    super.key,
    required this.location,
    required this.onNavigate,
  });

  final String location;

  /// Top-level destination switch. RootShell animates the content pane;
  /// a bare `go()` would hard-cut the right side.
  final void Function(String path) onNavigate;

  @override
  ConsumerState<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends ConsumerState<DesktopSidebar> {
  bool _collapsed = false;

  static const _expandedWidth = 220.0;
  static const _collapsedWidth = 64.0;

  /// 云盘入口是否显示：当前账号源具备 [CloudDiskSource] 能力，**且**该源的
  /// 「音乐云盘」功能子开关没被关掉（两级 AND，同其它入口类功能）。
  bool _cloudDiskEnabled(WidgetRef ref) {
    final platform = ref.watch(effectiveAccountSourceProvider);
    if (musicSourceRegistry?.capability<CloudDiskSource>(platform) == null) {
      return false;
    }
    return ref
        .watch(settingsControllerProvider)
        .isFeatureEnabled(platform, SourceFeature.cloud);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final magi = ArchiveSkinActive.skinOf(context).isEva;
    final ev = context.eva;
    // Only the LIVE badge depends on player state — don't rebuild the whole
    // rail (and its hover regions) on every position tick.
    final isFmActive = ref.watch(
      playerControllerProvider.select(
        (s) => s.queueSource == PlaybackQueueSource.fm,
      ),
    );

    // 宽度动画必须由 **一个** AnimatedContainer 驱动。
    // 外面再包一层 SizedBox(width:) 会瞬间改约束，动画等于没写。
    // 内容用 LayoutBuilder 跟实际宽度走：收窄到阈值以下自动切图标模式，
    // 展开过阈值再出文案——中途不会出现「宽 64 还硬排文字」的溢出。
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: _collapsed ? _collapsedWidth : _expandedWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: magi ? null : theme.surface,
        gradient: magi ? ev.sidebarGradient : null,
        border: Border(
          right: BorderSide(
            color: magi
                ? ev.textPrimary
                : (archive ? ArchiveChrome.lineStrong(theme) : theme.divider),
            width: magi ? 2 : 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 动画中途按**当前**宽度决定版式，而不是按 _collapsed 布尔。
          final compact = constraints.maxWidth < 120;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- 顶部 Logo + 折叠钮 ----------------
              // 紧凑态：logo 居中，展开钮在 logo 正下方。
              if (compact)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(),
                      const SizedBox(height: 6),
                      _CollapseButton(
                        collapsed: true,
                        onToggle: () => setState(() => _collapsed = false),
                      ),
                    ],
                  ),
                )
              else if (magi)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 12, 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ev.textPrimary,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MagiDisplayText(
                              '泛音',
                              matisse: true,
                              compression: 0.82,
                              style: TextStyle(
                                fontSize: MagiSkin.brandSize,
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                color: ev.textPrimary,
                              ),
                            ),
                          ),
                          _CollapseButton(
                            collapsed: false,
                            onToggle: () => setState(() => _collapsed = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        color: ev.accent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'CONCEPT // WIN',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                fontSize: MagiSkin.brandSubSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: ev.textOnAccent,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            MagiDisplayText(
                              '第壱版',
                              matisse: true,
                              compression: 1,
                              style: TextStyle(
                                fontSize: MagiSkin.brandSubSize,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                                color: ev.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 8, 16),
                  child: Row(
                    children: [
                      const AppLogo(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '泛音',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.title.copyWith(
                                fontSize: 18,
                                fontWeight: archive ? FontWeight.w800 : null,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _platformLabel(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.caption.copyWith(
                                fontSize: 10,
                                height: 1.25,
                                letterSpacing: archive ? 1.2 : null,
                                color: theme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CollapseButton(
                        collapsed: false,
                        onToggle: () => setState(() => _collapsed = true),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ---------------- 导航项列表 ----------------
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                  children: [
                    if (!compact) _buildGroupHeader('在线音乐', theme),
                    _SidebarItem(
                      icon: Icons.auto_awesome_rounded,
                      label: '发现',
                      magiIndex: '壱',
                      magiEn: 'DISCOVERY',
                      compact: compact,
                      selected:
                          widget.location.startsWith('/explore') ||
                          widget.location == '/',
                      onTap: () => widget.onNavigate('/explore'),
                    ),
                    _SidebarItem(
                      icon: Icons.explore_rounded,
                      label: '探索',
                      magiIndex: '弐',
                      magiEn: 'EXPLORE',
                      compact: compact,
                      selected: widget.location.startsWith('/discovery'),
                      onTap: () => widget.onNavigate('/discovery'),
                    ),
                    _SidebarItem(
                      icon: Icons.today_rounded,
                      label: '每日推荐',
                      magiIndex: '参',
                      magiEn: 'DAILY',
                      compact: compact,
                      selected: widget.location.startsWith('/daily'),
                      onTap: () => widget.onNavigate('/daily'),
                    ),
                    _SidebarItem(
                      icon: Icons.radio_rounded,
                      label: '私人 FM',
                      magiIndex: '肆',
                      magiEn: 'RADIO',
                      compact: compact,
                      selected: widget.location.startsWith('/fm'),
                      trailing:
                          isFmActive &&
                              !widget.location.startsWith('/fm') &&
                              !compact
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: archive
                                    ? Colors.transparent
                                    : theme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  archive ? 2 : 4,
                                ),
                                border: archive
                                    ? Border.all(color: theme.primary)
                                    : null,
                              ),
                              child: Text(
                                'LIVE',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: archive ? 1 : null,
                                ),
                              ),
                            )
                          : null,
                      onTap: () => widget.onNavigate('/fm'),
                    ),

                    const SizedBox(height: 16),
                    if (!compact) _buildGroupHeader('我的音乐', theme),
                    _SidebarItem(
                      icon: Icons.person_rounded,
                      label: '我的',
                      magiIndex: '伍',
                      magiEn: 'PROFILE',
                      compact: compact,
                      selected:
                          widget.location == '/profile' ||
                          (widget.location.startsWith('/profile') &&
                              !widget.location.startsWith('/profile/detail')),
                      onTap: () => widget.onNavigate('/profile'),
                    ),
                    _SidebarItem(
                      icon: Icons.badge_outlined,
                      label: '个人中心',
                      magiIndex: '陆',
                      magiEn: 'ACCOUNT',
                      compact: compact,
                      selected: widget.location.startsWith('/profile/detail'),
                      onTap: () => widget.onNavigate('/profile/detail'),
                    ),
                    _SidebarItem(
                      icon: Icons.favorite_rounded,
                      label: '我喜欢',
                      magiIndex: '柒',
                      magiEn: 'FAVORITE',
                      compact: compact,
                      selected: widget.location.startsWith('/likes'),
                      onTap: () => widget.onNavigate('/likes'),
                    ),
                    // 云盘是账号资产：当前账号源具备该能力才显示（酷狗/网易都有）；
                    // 再 AND 一下功能子开关（关掉「音乐云盘」即隐藏入口）。
                    if (_cloudDiskEnabled(ref))
                      _SidebarItem(
                        icon: Icons.cloud_rounded,
                        label: '音乐云盘',
                        magiIndex: '捌',
                        magiEn: 'CLOUD',
                        compact: compact,
                        selected: widget.location.startsWith('/cloud'),
                        onTap: () => widget.onNavigate('/cloud'),
                      ),
                    _SidebarItem(
                      icon: Icons.history_rounded,
                      label: '播放历史',
                      magiIndex: '玖',
                      magiEn: 'HISTORY',
                      compact: compact,
                      selected: widget.location.startsWith('/history'),
                      onTap: () => widget.onNavigate('/history'),
                    ),

                    const SizedBox(height: 16),
                    if (!compact) _buildGroupHeader('通用', theme),
                    _SidebarItem(
                      icon: Icons.settings_rounded,
                      label: '系统设置',
                      magiIndex: '零',
                      magiEn: 'CONFIG',
                      compact: compact,
                      selected: widget.location.startsWith('/settings'),
                      onTap: () => widget.onNavigate('/settings'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _platformLabel() {
    if (isWindowsPlatform) return '概念版 · Windows';
    if (Platform.isMacOS) return '概念版 · macOS';
    if (Platform.isLinux) return '概念版 · Linux';
    return '概念版';
  }

  Widget _buildGroupHeader(String title, OvertoneTheme theme) {
    final archive = ArchiveSkinActive.of(context);
    final magi = ArchiveSkinActive.skinOf(context).isEva;
    final ev = context.eva;
    if (magi) {
      const en = {
        '在线音乐': 'ONLINE AUDIO',
        '我的音乐': 'LOCAL',
        '通用': 'SYSTEM',
      };
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${en[title] ?? title} // $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: MagiSkin.groupSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: ev.accent,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              color: ev.accent.withValues(alpha: 0.4),
            ),
          ],
        ),
      );
    }
    if (archive) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1, color: ArchiveChrome.lineStrong(theme)),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.caption.copyWith(
                fontSize: 10,
                color: theme.textTertiary,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({required this.collapsed, required this.onToggle});

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    return Tooltip(
      message: collapsed ? '展开侧栏' : '折叠侧栏',
      child: archive
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: ArchiveChrome.lineStrong(theme)),
              ),
              child: _button(theme),
            )
          : _button(theme),
    );
  }

  Widget _button(OvertoneTheme theme) {
    return IconButton(
      onPressed: onToggle,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(
        collapsed
            ? Icons.keyboard_arrow_right_rounded
            : Icons.keyboard_arrow_left_rounded,
        color: theme.textTertiary,
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
    this.trailing,
    this.magiIndex,
    this.magiEn,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;
  final Widget? trailing;

  /// MAGI 皮肤下的汉字序号（壱/弐/参…），替代小图标。
  final String? magiIndex;

  /// MAGI 皮肤下右对齐的英文微标签（DISCOVERY / RADIO…）。
  final String? magiEn;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  // Stable tear-offs so MouseRegion doesn't see new closures every rebuild.
  void _handleEnter(PointerEnterEvent _) {
    if (_hovered) return;
    setState(() => _hovered = true);
  }

  void _handleExit(PointerExitEvent _) {
    if (!_hovered || !mounted) return;
    setState(() => _hovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final magi = ArchiveSkinActive.skinOf(context).isEva;
    final ev = context.eva;
    final activeColor = archive ? theme.textPrimary : theme.primary;
    final inactiveColor = theme.textSecondary;
    // Same RGB as the hover fill (black); only alpha animates. Avoids
    // Colors.transparent (transparent black) lerping through gray.
    final hoverFill = ev.isLight
        ? ev.accent.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.18);
    final idleFill = ev.isLight
        ? ev.accent.withValues(alpha: 0)
        : Colors.black.withValues(alpha: 0);
    final compact = widget.compact;
    // MAGI：选中项整块反色（白底黑字），与红色状态色分工。
    final inverted = magi && widget.selected;

    // 紧凑态整格就是编号/图标，不要套 Row / SizedBox(infinity)。
    final Widget body;
    if (compact) {
      body = Center(
        child: magi && widget.magiIndex != null
            ? MagiDisplayText(
                widget.magiIndex!,
                matisse: true,
                compression: 0.9,
                style: TextStyle(
                  fontSize: MagiSkin.numeralSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: inverted ? ev.bgBase : ev.accent,
                ),
              )
            : Icon(
                widget.icon,
                size: 20,
                color: widget.selected ? activeColor : inactiveColor,
              ),
      );
    } else if (magi) {
      body = Row(
        children: [
          if (widget.magiIndex != null) ...[
            Container(
              padding: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 2,
                    color: inverted
                        ? ev.bgBase.withValues(alpha: 0.45)
                        : ev.accentBorderStrong,
                  ),
                ),
              ),
              child: MagiDisplayText(
                widget.magiIndex!,
                matisse: true,
                compression: 0.9,
                style: TextStyle(
                  fontSize: MagiSkin.navNumeralSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: inverted ? Colors.black : ev.accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Icon(
              widget.icon,
              size: 20,
              color: inverted ? ev.bgBase : inactiveColor,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: MagiDisplayText(
              widget.label,
              compression: 0.88,
              style: TextStyle(
                fontSize: MagiSkin.navSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
                height: 1.0,
                color: inverted ? ev.bgBase : ev.textPrimary,
              ),
            ),
          ),
          if (widget.magiEn != null) ...[
            const SizedBox(width: 6),
            Text(
              widget.magiEn!,
              style: TextStyle(
                fontSize: MagiSkin.navEnSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontFamilyFallback: const [
                  'Consolas',
                  'Courier New',
                  'monospace',
                ],
                color: inverted
                    ? ev.bgBase.withValues(alpha: 0.54)
                    : ev.accent.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (widget.trailing != null) ...[
            const SizedBox(width: 6),
            widget.trailing!,
          ],
        ],
      );
    } else {
      body = Row(
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: widget.selected ? activeColor : inactiveColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.selected
                    ? FontWeight.w600
                    : FontWeight.normal,
                letterSpacing: archive ? 0.6 : null,
                color: widget.selected ? activeColor : theme.textPrimary,
              ),
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      );
    }

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.ease,
      margin: EdgeInsets.symmetric(vertical: archive || magi ? 0 : 2),
      height: compact ? 40 : null,
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12, vertical: 9),
      decoration: BoxDecoration(
        // 档案皮肤：无胶囊底，选中只靠左侧墨条；标准皮肤保留淡底 + 指示条。
        // MAGI：直角 + 选中整块反色。
        color: magi
            ? (inverted
                  ? ev.textPrimary
                  : _hovered
                  ? ev.accent.withValues(alpha: 0.12)
                  : Colors.transparent)
            : archive
            ? (_hovered
                  ? theme.textPrimary.withValues(alpha: 0.04)
                  : Colors.transparent)
            : widget.selected
            ? theme.primary.withValues(alpha: 0.10)
            : _hovered
            ? hoverFill
            : idleFill,
        borderRadius: BorderRadius.circular(
          archive || magi ? 0 : OvertoneRadius.tag,
        ),
        boxShadow: null,
      ),
      child: body,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (compact) Tooltip(message: widget.label, child: tile) else tile,
            // 选中指示条：短胶囊，收进胶囊**内侧**并离左沿 4px，两端圆角。
            // 绝对定位是为了不挤占内容宽度（旧 Border(left:3) 会让选中项
            // 标题比未选中右移 3px，观感发抖）。节点常驻、只过渡透明度，
            // 切换时才不会硬切；画在 tile 之后，免得被选中底色盖住。
            Positioned(
              left: archive ? 0 : 4,
              top: archive ? 8 : 9,
              bottom: archive ? 8 : 9,
              child: AnimatedOpacity(
                // MAGI 选中项已经整块反色，不再叠左侧指示条。
                opacity: widget.selected && !magi ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Container(
                  width: archive ? 2 : 3,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(archive ? 0 : 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
