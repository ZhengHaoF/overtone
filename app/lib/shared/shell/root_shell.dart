import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:window_manager/window_manager.dart' show windowManager;

import '../../core/theme/archive_skin.dart';
import '../../core/theme/cover_palette.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/responsive.dart';
import '../../features/player/player_controller.dart';
import '../../shared/widgets/desktop_player_bar.dart';
import '../../shared/widgets/magi_chrome.dart';
import '../../shared/widgets/mini_player_bar.dart';
import 'desktop_sidebar.dart';
import 'desktop_title_bar.dart';
import '../widgets/archive_skin_scope.dart';
import '../../core/theme/glass_tokens.dart';
import '../widgets/liquid_glass.dart';
import 'package:overtone/l10n/l10n.dart';

class _TogglePlayIntent extends Intent {
  const _TogglePlayIntent();
}

class _SeekForwardIntent extends Intent {
  const _SeekForwardIntent();
}

class _SeekBackwardIntent extends Intent {
  const _SeekBackwardIntent();
}

class _NextTrackIntent extends Intent {
  const _NextTrackIntent();
}

class _PrevTrackIntent extends Intent {
  const _PrevTrackIntent();
}

class _OpenSearchIntent extends Intent {
  const _OpenSearchIntent();
}

class _CloseOrBackIntent extends Intent {
  const _CloseOrBackIntent();
}

class _NextTabIntent extends Intent {
  const _NextTabIntent();
}

class _PrevTabIntent extends Intent {
  const _PrevTabIntent();
}

/// Bottom tabs with macOS Dock-style icon magnify/bounce and a light
/// Spaces-like content transition. Router (IndexedStack) is untouched.
/// On desktop wide screens (>= 800px), automatically switches to DesktopShell.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with TickerProviderStateMixin {
  late final AnimationController _bounce;
  late final AnimationController _navFade;
  int _prevIndex = 0;
  int _navOrder = 0;
  double _navDirection = 1;

  /// 滚动中把玻璃模糊降一档：只翻转这个 notifier（不 setState），
  /// 由 Dock / 迷你条各自的 ValueListenableBuilder 消费，避免每帧重建。
  final ValueNotifier<bool> _glassGliding = ValueNotifier<bool>(false);
  Timer? _glassGlideSettle;

  static List<(IconData, IconData, String)> get _tabs => [
    (Icons.explore_outlined, Icons.explore_rounded, l10n.faXian),
    (Icons.person_outline_rounded, Icons.person_rounded, l10n.woDe),
  ];

  int _indexOf(String location) => switch (location) {
    _
        when location.startsWith('/profile') ||
            location.startsWith('/history') ||
            location.startsWith('/likes') ||
            location.startsWith('/cloud') ||
            location.startsWith('/settings') =>
      1,
    _ => 0,
  };

  /// Sidebar reading order — used for content drift direction.
  static int _sidebarOrder(String location) => switch (true) {
    _ when location.startsWith('/discovery') => 1,
    _ when location.startsWith('/daily') => 2,
    _ when location.startsWith('/ranks') || location.startsWith('/rank/') => 3,
    _ when location.startsWith('/fm') => 4,
    _ when location.startsWith('/profile') => 5,
    _ when location.startsWith('/likes') => 6,
    _ when location.startsWith('/cloud') => 7,
    _ when location.startsWith('/history') => 8,
    _ when location.startsWith('/search') => 9,
    _ when location.startsWith('/settings') => 10,
    _ => 0,
  };

  @override
  void initState() {
    super.initState();
    _prevIndex = _indexOf(widget.location);
    _navOrder = _sidebarOrder(widget.location);
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _navFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant RootShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _indexOf(widget.location);
    if (next != _indexOf(oldWidget.location)) {
      _prevIndex = _indexOf(oldWidget.location);
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glassGlideSettle?.cancel();
    _glassGliding.dispose();
    _bounce.dispose();
    _navFade.dispose();
    super.dispose();
  }

  /// 滚动开始 → 立即降级；滚停 300ms → 恢复。
  ///
  /// 只在 ScrollStart / ScrollEnd 两个边界翻转 `ValueNotifier`，
  /// 不在 ScrollUpdate 里逐帧回调，避免重建抖动。
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _glassGlideSettle?.cancel();
      if (!_glassGliding.value) _glassGliding.value = true;
    } else if (notification is ScrollEndNotification) {
      _glassGlideSettle?.cancel();
      _glassGlideSettle = Timer(const Duration(milliseconds: 300), () {
        if (mounted) _glassGliding.value = false;
      });
    }
    return false;
  }

  void _goTo(int index, String path) {
    if (_indexOf(widget.location) == index) return;
    _prevIndex = _indexOf(widget.location);
    _bounce.forward(from: 0);
    // 切 tab 与滚动同级：[_TabTransition] 的 200ms 里整页内容在玻璃
    // （Dock + 迷你条）下方平移，两块 BackdropFilter 每帧都要重采背板，
    // 模拟器/低端机上正是掉帧时段。复用滚动的降级策略：过渡期把模糊
    // 降一档、折射带收敛，过渡结束 300ms 后恢复（与 _onScrollNotification
    // 同口径）。非玻璃皮肤下翻转 notifier 只是空重建，无副作用。
    _glassGlideSettle?.cancel();
    if (!_glassGliding.value) _glassGliding.value = true;
    _glassGlideSettle = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _glassGliding.value = false;
    });
    context.go(path);
  }

  /// Desktop sidebar switch: swap the pane, then fade/drift it in.
  ///
  /// `context.go` replaces the shell branch stack (and flips IndexedStack
  /// across branches) without a [PageRoute] transition — animating here is
  /// what the user sees when clicking the rail.
  void _desktopNavigate(String path) {
    if (!mounted || path == widget.location) return;
    final nextOrder = _sidebarOrder(path);
    _navDirection = nextOrder >= _navOrder ? 1.0 : -1.0;
    _navOrder = nextOrder;
    context.go(path);
    _navFade.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild dock/scaffold colors when MaterialApp theme flips.
    final theme = OvertoneTheme.of(context);
    final isDesktop = isDesktopView(context);
    final skin = ArchiveSkinActive.skinOf(context);
    final skeuo = skin.isSkeuo;
    final magi = skin.isEva;

    // B1 自适应染色：封面主色的「来源」在 shell 侧算好再注入玻璃，
    // 避免 OvertoneTheme 反向依赖 Riverpod。没有播放（或实验皮肤）时
    // 传 null，玻璃回退纯主题底色，不残留上一首的颜色。
    // 桌面分支也要用，所以在 isDesktop 提前返回之前算。
    final playingCover = ref.watch(
      playerControllerProvider.select((s) => s.current?.coverUrl ?? ''),
    );
    final glassTint = skeuo && playingCover.isNotEmpty
        ? CoverPalette.accentFromSeed(playingCover, theme.palette)
        : null;

    if (isDesktop) {
      final glassBody = Stack(
        fit: StackFit.expand,
        children: [
          if (skeuo)
            Positioned.fill(
              child: _DesktopAmbient(theme: theme, tint: glassTint),
            ),
          Positioned.fill(
            child: Column(
              children: [
                DesktopTitleBar(
                  glass: skeuo,
                  tint: glassTint,
                  onClose: () async {
                    // 与托盘关闭同一链路：拦原生 close，交给 shell 决定。
                    await windowManager.close();
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      if (skeuo)
                        LiquidGlass(
                          tier: GlassTier.regular,
                          radius: 0,
                          tint: glassTint,
                          padding: EdgeInsets.zero,
                          specular: false,
                          shadow: const [],
                          child: DesktopSidebar(
                            glass: true,
                            location: widget.location,
                            onNavigate: _desktopNavigate,
                          ),
                        )
                      else
                        DesktopSidebar(
                          location: widget.location,
                          onNavigate: _desktopNavigate,
                        ),
                      Expanded(
                        child: _DesktopNavTransition(
                          animation: _navFade,
                          direction: _navDirection,
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
                DesktopPlayerBar(glass: skeuo, tint: glassTint),
              ],
            ),
          ),
        ],
      );
      return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.space): _TogglePlayIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): _SeekForwardIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _SeekBackwardIntent(),
          // J/K 上下首（vim 习惯）；N/P 兜底。
          SingleActivator(LogicalKeyboardKey.keyJ): _NextTrackIntent(),
          SingleActivator(LogicalKeyboardKey.keyK): _PrevTrackIntent(),
          SingleActivator(LogicalKeyboardKey.keyN): _NextTrackIntent(),
          SingleActivator(LogicalKeyboardKey.keyP): _PrevTrackIntent(),
          // / 或 Ctrl+F 聚焦搜索。
          SingleActivator(LogicalKeyboardKey.slash): _OpenSearchIntent(),
          SingleActivator(LogicalKeyboardKey.keyF, control: true):
              _OpenSearchIntent(),
          SingleActivator(LogicalKeyboardKey.escape): _CloseOrBackIntent(),
          // Ctrl+←/→ 切主 tab。
          SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
              _NextTabIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
              _PrevTabIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _TogglePlayIntent: CallbackAction<_TogglePlayIntent>(
              onInvoke: (_) {
                ref.read(playerControllerProvider.notifier).togglePlay();
                return null;
              },
            ),
            _SeekForwardIntent: CallbackAction<_SeekForwardIntent>(
              onInvoke: (_) {
                ref.read(playerControllerProvider.notifier).seekBy(5000);
                return null;
              },
            ),
            _SeekBackwardIntent: CallbackAction<_SeekBackwardIntent>(
              onInvoke: (_) {
                ref.read(playerControllerProvider.notifier).seekBy(-5000);
                return null;
              },
            ),
            _NextTrackIntent: CallbackAction<_NextTrackIntent>(
              onInvoke: (_) {
                unawaited(ref.read(playerControllerProvider.notifier).next());
                return null;
              },
            ),
            _PrevTrackIntent: CallbackAction<_PrevTrackIntent>(
              onInvoke: (_) {
                unawaited(
                  ref.read(playerControllerProvider.notifier).previous(),
                );
                return null;
              },
            ),
            _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
              onInvoke: (_) {
                if (!widget.location.startsWith('/search')) {
                  context.push('/search');
                }
                return null;
              },
            ),
            _CloseOrBackIntent: CallbackAction<_CloseOrBackIntent>(
              onInvoke: (_) {
                // 弹层/路由能 pop 就 pop；否则退回上一个主 tab 入口。
                if (context.canPop()) {
                  context.pop();
                } else if (widget.location.startsWith('/search') ||
                    widget.location.startsWith('/discovery') ||
                    widget.location.startsWith('/daily') ||
                    widget.location.startsWith('/ranks') ||
                    widget.location.startsWith('/rank/') ||
                    widget.location.startsWith('/fm')) {
                  context.go('/explore');
                } else if (widget.location.startsWith('/likes') ||
                    widget.location.startsWith('/cloud') ||
                    widget.location.startsWith('/history') ||
                    widget.location.startsWith('/settings') ||
                    widget.location.startsWith('/profile/detail')) {
                  context.go('/profile');
                }
                return null;
              },
            ),
            _NextTabIntent: CallbackAction<_NextTabIntent>(
              onInvoke: (_) {
                final next = _indexOf(widget.location) == 0
                    ? '/profile'
                    : '/explore';
                if (widget.location != next) _desktopNavigate(next);
                return null;
              },
            ),
            _PrevTabIntent: CallbackAction<_PrevTabIntent>(
              onInvoke: (_) {
                final prev = _indexOf(widget.location) == 0
                    ? '/profile'
                    : '/explore';
                if (widget.location != prev) _desktopNavigate(prev);
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              // 拟物浮光：桌面窗口铺一层「氛围底板」，顶栏 / 播放栏 /
              // 侧栏的玻璃才有东西可折射；其它皮肤保持原来的不透明底。
              backgroundColor: skeuo || magi ? Colors.transparent : theme.bg,
              body: _MagiShellBody(enabled: magi, child: glassBody),
            ),
          ),
        ),
      );
    }

    // 全屏路由（/player、/player/lyrics、/login、/netease-login）挂在 shell
    // 之外，压根不会渲染本组件；能走进来的都是两个主 branch 内的路径。
    //
    // 所以**不再按路由字面值判断**要不要播放条：二级页（歌单/专辑/歌手/榜单/
    // 历史/我喜欢/设置/个人中心/搜索…）同样要挂 MiniPlayerBar，否则在详情页
    // 起一首歌再返回，底部既看不到在播什么、也没有回播放器的入口。
    // 只有底部 Tab 栏是主 tab 专属——深页带 tab 会把层级关系画错。
    final isMainTab =
        widget.location == '/explore' || widget.location == '/profile';

    final index = _indexOf(widget.location);
    // easeOutBack — light Dock bounce without looking springy-cheap.
    final bounceT = CurvedAnimation(parent: _bounce, curve: Curves.easeOutBack);

    // 滚动降级只翻转 _glassGliding（不 setState），由这两层
    // ValueListenableBuilder 消费：Dock / 迷你条各自只重建自己。
    final dockBar = ValueListenableBuilder<bool>(
      valueListenable: _glassGliding,
      builder: (context, gliding, _) => _DockNavBar(
        index: index,
        bounce: bounceT,
        tabs: _tabs,
        tint: glassTint,
        gliding: gliding,
        onTap: (i) {
          switch (i) {
            case 0:
              _goTo(0, '/explore');
            case 1:
              _goTo(1, '/profile');
          }
        },
      ),
    );
    // 拟物浮光主 Tab：Dock 叠在内容之上，才能让半透明底真的"磨"到页面；
    // 默认皮肤与实验皮肤保持挂在 bottomNavigationBar 上的原布局。
    final overlayDock = isMainTab && skeuo;
    final miniBar = ValueListenableBuilder<bool>(
      valueListenable: _glassGliding,
      builder: (context, gliding, _) => MiniPlayerBar(
        key: ValueKey('mini-player-${theme.palette.brightness.name}'),
        glassGlide: gliding,
      ),
    );

    return Scaffold(
      backgroundColor: magi ? Colors.transparent : theme.bg,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: _MagiShellBody(
          enabled: magi,
          child: overlayDock
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: _TabTransition(
                        index: index,
                        prevIndex: _prevIndex,
                        child: widget.child,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [miniBar, dockBar],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: _TabTransition(
                        index: index,
                        prevIndex: _prevIndex,
                        child: widget.child,
                      ),
                    ),
                    miniBar,
                  ],
                ),
        ),
      ),
      bottomNavigationBar: isMainTab && !overlayDock ? dockBar : null,
    );
  }
}

/// Desktop sidebar content pane: fade-in + light horizontal drift.
///
/// Same contract as [_TabTransition]: never change the wrapper tree shape
/// around [child] — settle 时拆包装会让子树重挂，进页末尾抖一下。
/// Settled 值用 identity（opacity 1 / dx 0 / Clip.none），不叠额外 layer。
class _DesktopNavTransition extends StatelessWidget {
  const _DesktopNavTransition({
    required this.animation,
    required this.direction,
    required this.child,
  });

  /// 0 = entering, 1 = settled.
  final Animation<double> animation;

  /// +1 when moving down the rail, -1 when moving up.
  final double direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final settled = t >= 1.0;
        final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
        // Keep a floor so the pane never flashes pure background mid-switch.
        final opacity = settled ? 1.0 : (0.18 + 0.82 * eased).clamp(0.0, 1.0);
        final dx = settled ? 0.0 : direction * 14.0 * (1.0 - eased);
        // 包装树恒定：settle 时若拆掉 ClipRect/Opacity/Transform 直接 return child，
        // 子树会重挂，侧栏切页末尾抖一下。Clip.none 保留 FM 黑胶等溢出绘制。
        return ClipRect(
          clipBehavior: settled ? Clip.none : Clip.hardEdge,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(offset: Offset(dx, 0), child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// Spaces-like content transition.
///
/// Important: keep the wrapper tree shape constant around [child] and never
/// change the child's GlobalKey identity — IndexedStack must stay mounted
/// or pages end up permanently offset/clipped. Settled 用 identity 值，不拆包装。
class _TabTransition extends StatefulWidget {
  const _TabTransition({
    required this.child,
    required this.index,
    required this.prevIndex,
  });

  final Widget child;
  final int index;
  final int prevIndex;

  @override
  State<_TabTransition> createState() => _TabTransitionState();
}

class _TabTransitionState extends State<_TabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _fromIndex = 0;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.prevIndex;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant _TabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _fromIndex = oldWidget.index;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final animating = _ctrl.isAnimating && _ctrl.value < 1.0;
        final t = Curves.easeOutCubic.transform(_ctrl.value.clamp(0.0, 1.0));
        final forward = widget.index >= _fromIndex;
        final dx = animating ? (forward ? 24.0 : -24.0) * (1 - t) : 0.0;
        final opacity = animating ? (0.35 + 0.65 * t).clamp(0.0, 1.0) : 1.0;
        final scale = animating ? 0.98 + 0.02 * t : 1.0;
        // 包装树恒定（同 _DesktopNavTransition）：settle 时拆包装会重挂子树、抖一下。
        return ClipRect(
          clipBehavior: animating ? Clip.hardEdge : Clip.none,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.scale(scale: scale, child: widget.child),
            ),
          ),
        );
      },
    );
  }
}

/// Custom bottom bar: Dock magnification around the selected tab + bounce.
class _DockNavBar extends StatelessWidget {
  const _DockNavBar({
    required this.index,
    required this.bounce,
    required this.tabs,
    required this.onTap,
    this.tint,
    this.gliding = false,
  });

  final int index;
  final Animation<double> bounce;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onTap;

  /// B1：当前播放封面主色（null = 无播放 / 实验皮肤，走纯主题底色）。
  final Color? tint;

  /// 滚动中：模糊降一档（[OvertoneTheme.glassDockSigmaScrolling]）。
  final bool gliding;

  double _dockScale(int i) {
    final dist = (i - index).abs();
    final base = switch (dist) {
      0 => 1.28,
      1 => 1.08,
      _ => 1.0,
    };
    if (dist != 0) return base;
    // easeOutBack overshoots past 1 — that IS the Dock bounce.
    final t = bounce.value.clamp(0.0, 1.4);
    final overshoot = t <= 0
        ? 0.0
        : Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
    return (base + (overshoot - 1.0) * 0.35).clamp(0.95, 1.55);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final skin = ArchiveSkinActive.skinOf(context);
    final ev = context.eva;
    final skinned = skin.isArchiveStyle;
    final skeuo = skin.isSkeuo;
    final magi = skin.isEva;
    final items = AnimatedBuilder(
      animation: bounce,
      builder: (context, _) {
        return Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _DockItem(
                  icon: i == index ? tabs[i].$2 : tabs[i].$1,
                  label: tabs[i].$3,
                  selected: i == index,
                  skinned: skinned,
                  isMagi: skin.isEva,
                  scale: _dockScale(i),
                  onTap: () => onTap(i),
                ),
              ),
          ],
        );
      },
    );

    // 默认皮肤（以及拟物浮光之外的所有非硬边皮肤）：改版前的贴底不透明条，
    // 无分隔线、无浮起；选中只靠缩放回弹表达。
    if (!skeuo) {
      return Container(
        decoration: BoxDecoration(
          color: magi ? ev.bgBase : theme.bg,
          border: skinned
              ? Border(
                  top: BorderSide(
                    color: magi ? ev.textPrimary : theme.divider,
                    width: magi ? 2 : 1,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: SafeArea(top: false, child: SizedBox(height: 64, child: items)),
      );
    }

    // 拟物浮光：离底悬浮的毛玻璃圆角条。外边距走 spacing token（与迷你条
    // 同值，两条左右对齐），圆角走 bar；模糊 / 饱和度 / 内亮外暗描边收在
    // [FrostedGlass] 里，这里只负责尺寸与投影。
    // 条高取预览稿的 58；图标 24 / 文字 10 沿用现有档位（预览稿的 19/9
    // 不在字号阶梯内）。
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        OvertoneSpacing.floatingInset,
        0,
        OvertoneSpacing.floatingInset,
        OvertoneSpacing.sm,
      ),
      child: LiquidGlass(
        key: ValueKey('dock-glass-${skin.name}'),
        tier: GlassTier.regular,
        materialize: true,
        radius: OvertoneRadius.bar,
        height: 58,
        shadow: theme.shadowRaised,
        tint: tint,
        // regular：静止 3.5 / 滚动 2.2（v2 的模糊是「薄玻璃」，不是糊墙）。
        scrolling: gliding,
        pressable: true,
        padding: const EdgeInsets.symmetric(horizontal: OvertoneSpacing.sm),
        child: items,
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.skinned,
    required this.isMagi,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool skinned;
  final bool isMagi;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final skinned = ArchiveSkinActive.of(context);
    final skeuo = ArchiveSkinActive.skinOf(context).isSkeuo;
    final tabLabel = !skinned
        ? label
        : isMagi
        ? '[ $label ]'
        : label;
    return InkWell(
      onTap: onTap,
      borderRadius: skinned
          ? BorderRadius.zero
          : BorderRadius.circular(OvertoneRadius.tile),
      child: Container(
        decoration: skinned
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? theme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fixed slot so neighbors don't jump layout while scaling.
              SizedBox(
                height: 32,
                child: Center(
                  child: Transform.scale(
                    scale: scale.clamp(0.9, 1.45),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      // 拟物浮光：颜色随 150ms 过渡，与缩放回弹同拍；硬边皮肤
                      // 保持既有的过渡（观感零变化）；默认皮肤回到瞬变。
                      child: skinned || skeuo
                          ? TweenAnimationBuilder<Color?>(
                              tween: ColorTween(
                                end: selected
                                    ? theme.primary
                                    : (skeuo
                                          ? theme.textSecondary
                                          : theme.textTertiary),
                              ),
                              duration: const Duration(milliseconds: 150),
                              builder: (context, color, _) =>
                                  Icon(icon, size: 24, color: color),
                            )
                          : Icon(
                              icon,
                              size: 24,
                              color: selected
                                  ? theme.primary
                                  : (skeuo
                                        ? theme.textSecondary
                                        : theme.textTertiary),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (skinned || skeuo)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: theme.caption.copyWith(
                    fontSize: 10,
                    height: 1.1,
                    letterSpacing: skinned ? 0.6 : null,
                    fontWeight: skinned && selected ? FontWeight.w700 : null,
                    color: selected
                        ? theme.primary
                        : (skeuo ? theme.textSecondary : theme.textTertiary),
                  ),
                  child: Text(
                    tabLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Text(
                  tabLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.caption.copyWith(
                    fontSize: 10,
                    height: 1.1,
                    letterSpacing: skinned ? 0.6 : null,
                    fontWeight: skinned && selected ? FontWeight.w700 : null,
                    color: selected
                        ? theme.primary
                        : (skeuo ? theme.textSecondary : theme.textTertiary),
                  ),
                ),
              // 拟物浮光：选中指示点承接选中语义（硬边皮肤已有底线/反色表达）；
              // 默认皮肤不占这 5dp，恢复改版前的等高。
              if (skeuo)
                SizedBox(
                  height: 5,
                  child: _SpringDot(visible: selected, color: theme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// MAGI 皮肤下给整个外壳垫一层氛围底板；标准 / 瑞士皮肤保持原样。
class _MagiShellBody extends StatelessWidget {
  const _MagiShellBody({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return enabled ? MagiBackdrop(child: child) : child;
  }
}

/// 桌面「拟物浮光」的氛围底板。
///
/// Windows 上 Impeller 的 `ImageFilter.shader` 不保证可用，但 BackdropFilter
/// 一定可用：只要玻璃背后有内容，B 档（模糊 + 染色）也能成立。这里用当前
/// 封面的主色在窗口四角铺两团柔光，给顶栏 / 侧栏 / 播放栏一点低频色差可磨。
/// 只在 skeuo 桌面分支实例化，默认 / MAGI / 档案皮肤零变化。
class _DesktopAmbient extends StatelessWidget {
  const _DesktopAmbient({required this.theme, this.tint});

  final OvertoneTheme theme;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? theme.primary;
    final base = theme.bg;
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(base, accent, 0.16)!,
                  base,
                  Color.lerp(base, theme.primary, 0.10)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: -150,
            top: -190,
            child: _AmbientBlob(color: accent, size: 560, alpha: 0.30),
          ),
          // 顶部一条横向柔光：给悬浮标题栏一点可折射的亮度，
          // 否则深色氛围底板下 31px 的玻璃条几乎看不见（上一轮遗留）。
          Positioned(
            top: -320,
            left: 0,
            right: 0,
            child: Center(
              child: _AmbientBlob(color: accent, size: 900, alpha: 0.18),
            ),
          ),
          Positioned(
            right: -170,
            bottom: -230,
            child: _AmbientBlob(color: theme.primary, size: 620, alpha: 0.20),
          ),
        ],
      ),
    );
  }
}

class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({
    required this.color,
    required this.size,
    required this.alpha,
  });

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock 选中指示点：弹簧驱动（bouncy，ζ≈0.72），可从任意中间值反向。
///
/// 之所以不给整条 Dock 的缩放换弹簧：`_dockScale` 是所有皮肤共用的路径，
/// 动它会让默认/档案/MAGI 的回弹手感一起变（违反隔离纪律）。指示点是
/// 拟物浮光独有的元素，弹簧只落在这里。
class _SpringDot extends StatefulWidget {
  const _SpringDot({required this.visible, required this.color});

  final bool visible;
  final Color color;

  @override
  State<_SpringDot> createState() => _SpringDotState();
}

class _SpringDotState extends State<_SpringDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(
    vsync: this,
    value: widget.visible ? 1.0 : 0.0,
  );

  @override
  void didUpdateWidget(covariant _SpringDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;
    final mq = MediaQuery.of(context);
    if (mq.disableAnimations || mq.accessibleNavigation) {
      _c.value = widget.visible ? 1.0 : 0.0;
      return;
    }
    // animateWith 会顶替上一段模拟，且从当前值出发 → 连点/快速切 tab 不跳。
    _c.animateWith(
      SpringSimulation(
        GlassMotion.bouncy,
        _c.value,
        widget.visible ? 1.0 : 0.0,
        0,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value.clamp(0.0, 1.2);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            // 0.6 → 1.0：回弹时最多到 1.08，视觉上是一次「落定」。
            scale: 0.6 + 0.4 * t,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
