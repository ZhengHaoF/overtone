import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/track.dart';
import '../../core/source/capabilities.dart';
import '../../core/source/features.dart';
import '../../core/source/music_platform.dart';
import '../../core/source/registry.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/cover_palette.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/responsive.dart';
import '../../data/storage/queue_store.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/likes/likes_controller.dart';
import '../../features/profile/source_account.dart';
import '../../features/profile/source_library_controller.dart';
import '../../features/rank/rank_hero.dart' show rankHeroFlightShuttle;
import '../../features/settings/settings_controller.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/cover_box.dart';
import '../../shared/widgets/settings_pickers.dart';
import '../../shared/widgets/smooth_scroll.dart';
import 'package:overtone/l10n/l10n.dart';

/// 「我的」— 乐库入口页。
///
/// 只放：紧凑用户入口（→ `/profile/detail` 个人中心）、乐库统计、歌单、设置快捷。
/// 账号身份 / 等级 / 关注粉丝 / 档案 / 会员**不在此页**，见 [ProfileDetailPage]。
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  /// Distinct tracks in local play history. `null` until the DB answers, so the
  /// tile can render a placeholder instead of a wrong `0`.
  int? _historyCount;
  int _selectedPlaylistTab = 0;
  final GlobalKey _playlistsSectionKey = GlobalKey();
  final GlobalKey _settingsSectionKey = GlobalKey();

  /// 当前页签镜像。整页已改成单层滚动、没有 TabBarView 兜底重建，
  /// 内容 sliver 靠 TabController 监听换掉。
  int _tabIndex = 0;

  /// 页签：0 = 歌单，1 = 设置。
  ///
  /// 页签栏吸顶，页签内容不再各自开视口，而是接在同一套滚动里。
  static List<String> get _tabs => [l10n.geDan, l10n.sheZhi];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).refreshProfile();
      _loadHistoryCount();
      // 资料库按当前账号源拉一次（[SourceLibraryNotifier] 也会兜底自拉）。
      final platform = ref.read(effectiveAccountSourceProvider);
      ref.read(sourceLibraryProvider(platform).notifier).loadPlaylists();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// 页签切换只换内容 sliver，不新建滚动视口，也不复位滚动位置。
  void _handleTabChange() {
    if (_tabController.index == _tabIndex) return;
    setState(() => _tabIndex = _tabController.index);
  }

  Future<void> _loadHistoryCount() async {
    try {
      final store = await QueueStore.open();
      final count = await store.historyCount();
      if (!mounted) return;
      setState(() => _historyCount = count);
    } catch (_) {
      // Leave null → renders as placeholder rather than a misleading 0.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final skeuo = ArchiveSkinActive.skinOf(context).isSkeuo;
    final isDesktop = isDesktopView(context);
    // 拟物浮光主 Tab 的 Dock 是叠层悬浮：迷你条 ≈70 + Dock 58 + 底距 8
    // ≈136，底部留白取 140 并补系统底部安全区；默认/实验皮肤的 Dock 挂在
    // bottomNavigationBar 上、不叠加，保持原 140。
    final listBottomSpacer = isDesktop
        ? 48.0
        : 140 + (skeuo ? MediaQuery.paddingOf(context).bottom : 0.0);
    ref.watch(settingsControllerProvider.select((s) => s.themeMode));
    final settings = ref.watch(settingsControllerProvider);
    final likesCount = ref.watch(likesProvider).length;

    // 账号源：页面级切换（见 source_account.dart），默认取设置里的默认源。
    final accountSources = ref.watch(accountSourcePlatformsProvider);
    final accountPlatform = ref.watch(effectiveAccountSourceProvider);
    final account = ref.watch(sourceAccountProvider(accountPlatform));
    final isKugou = accountPlatform == MusicPlatform.kugou;
    final library = ref.watch(sourceLibraryProvider(accountPlatform));
    // 云端歌单读能力（合集/收藏夹口径，B4 落地前 B 站没有）。没有它
    // 就不出「去登录」引导——登录了也没有可同步的歌单，是假入口
    // （多音源方案 §3.2）。B4 落地后 B 站自动获得引导，无需特判。
    // 注：登录路由本身的有效性由 [canLoginSource] 在个人中心页把关；
    // B3（账号）排期早于 B4（内容面），有读能力时必有登录入口。
    final canReadPlaylists =
        musicSourceRegistry?.capability<UserPlaylistReadSource>(
          accountPlatform,
        ) !=
        null;

    final realLikesCount = account.isLogged
        ? (library.likedPlaylist?.trackCount ??
              (library.likedTracks.isNotEmpty
                  ? library.likedTracks.length
                  : likesCount))
        : likesCount;

    final displayName = account.isLogged
        ? (account.nickname.isEmpty ? l10n.yongHu : account.nickname)
        : (account.restored ? l10n.youKe : '…');
    final displaySub = account.isLogged
        ? (account.isVip
              ? (isKugou ? l10n.gaiNianHuiYuan : context.l10n.heiJiaoHuiYuan)
              : context.l10n.yiDengLuChaKanGeRenZhongXin)
        : context.l10n.weiDengLuGongKaiNeiRongKeYong;
    final avatarUrl = account.avatarUrl;
    final sleepLabel = settings.sleepMinutes == 0
        ? context.l10n.guanBi
        : context.l10n.fenZhong(settings.sleepMinutes);

    final playlistStatValue = !account.isLogged
        ? '—'
        : (library.loading && !library.loaded
              ? '—'
              : '${library.totalPlaylistsCount}');
    // 歌单在第一个页签里：先切页签，切完这一帧再滚到卡片。
    void revealTabSection(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      // 页签栏是吸顶的，会盖住内容顶部这几十像素，alignment 让出一截。
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }

    void revealPlaylists() => revealTabSection(_playlistsSectionKey);

    /// 入口卡组里的「设置」：切页签并把设置卡滚到吸顶栏下方。
    void openSettingsTab() {
      if (_tabController.index == 1) {
        revealTabSection(_settingsSectionKey);
        return;
      }
      _tabController.animateTo(1);
      // 内容 sliver 是切完页签之后才建出来的，等这一帧布局完再滚。
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => revealTabSection(_settingsSectionKey),
      );
    }

    void onPlaylistStatTap() {
      if (!account.isLogged) {
        // 没有云端歌单的源（B 站 B4 落地前）不跳转，
        // 去了也是死路由。
        if (canReadPlaylists) {
          context.push(loginRouteFor(accountPlatform));
        }
        return;
      }
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
        // 内容 sliver 是切完页签之后才建出来的，等这一帧布局完再滚。
        WidgetsBinding.instance.addPostFrameCallback((_) => revealPlaylists());
        return;
      }
      revealPlaylists();
    }

    // 没有云端歌单的源（B 站，合集/收藏夹属 B4）不出「需登录」——
    // 登录了也没有可同步的歌单，摆个去登录的入口就是假入口。
    final playlistStatHint = !account.isLogged
        ? (canReadPlaylists ? l10n.xuDengLu : context.l10n.zanBuZhiChi)
        : null;

    // 页签栏：吸顶用，高度取 TabBar 自己的 preferredSize。
    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [for (final t in _tabs) Tab(text: t)],
    );

    return ArchivePageScaffold(
      // 页头对齐「探索发现」：顶部居中页面标题。
      appBar: AppBar(title: Text(context.l10n.woDe)),
      // 单层滚动：身份卡、统计卡、入口卡组、页签栏与页签内容全排在同一
      // 条 CustomScrollView 里，任何一段都不再有自己的滚动视口。
      body: SmoothCustomScrollView(
        slivers: [
          // 账号源切换条：多源启用才出（账号身份按源区分，不混排）。
          // 顶部间距由 SourceFilterBar 自带，与其它页面对齐。
          if (accountSources.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OvertoneSpacing.lg,
                ),
                child: SourceFilterBar(
                  platforms: accountSources,
                  selected: accountPlatform,
                  showAll: false,
                  horizontalPadding: 0,
                  onSelect: (p) {
                    // 切源同时改写全局默认源（「全部」不写），下个入口跟着走同一源。
                    ref
                        .read(settingsControllerProvider.notifier)
                        .syncDefaultSourceFromFilter(p);
                    if (p != null) {
                      ref.read(accountSourceProvider.notifier).state = p;
                    }
                  },
                ),
              ),
            ),
          // 身份卡常驻：切到「设置」页签也不该丢掉账号身份与乐库统计。
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                OvertoneSpacing.lg,
                OvertoneSpacing.sm,
                OvertoneSpacing.lg,
                OvertoneSpacing.md,
              ),
              child: GlassSurface(
                padding: const EdgeInsets.all(OvertoneSpacing.lg),
                child: Column(
                  children: [
                    // 紧凑用户入口 → 独立「个人中心」页（对齐 Echo 的 Profile 内容页）。
                    InkWell(
                      borderRadius: BorderRadius.circular(OvertoneRadius.tile),
                      onTap: () => context.push('/profile/detail'),
                      child: Row(
                        children: [
                          Container(
                            decoration: archive
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: theme.textTertiary,
                                    ),
                                  )
                                : null,
                            child: CoverBox(
                              seed: avatarUrl.isNotEmpty
                                  ? avatarUrl
                                  : 'avatar-guest',
                              size: 56,
                              radius: archive ? 0 : 999,
                              child: avatarUrl.isNotEmpty
                                  ? null
                                  : Icon(
                                      Icons.person_rounded,
                                      color: OvertoneTheme.of(
                                        context,
                                      ).onCoverMuted,
                                      size: 32,
                                    ),
                            ),
                          ),
                          const SizedBox(width: OvertoneSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: theme.title),
                                const SizedBox(height: 4),
                                Text(displaySub, style: theme.caption),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    // 档案/默认皮肤：统计行留在身份卡内（原结构与原样式）；
                    // 拟物浮光：统计迁出为下方三张独立浮起卡。
                    if (!skeuo) ...[
                      const SizedBox(height: OvertoneSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              label: context.l10n.woXiHuan,
                              value: '$realLikesCount',
                              onTap: () => context.push('/likes'),
                            ),
                          ),
                          const _Divider(),
                          Expanded(
                            child: _Stat(
                              label: context.l10n.zuiJinBoFang,
                              value: _historyCount == null
                                  ? '—'
                                  : '$_historyCount',
                              onTap: () => context.push('/history'),
                            ),
                          ),
                          const _Divider(),
                          Expanded(
                            child: _Stat(
                              label: context.l10n.geDan,
                              value: playlistStatValue,
                              hint: playlistStatHint,
                              onTap: onPlaylistStatTap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // 拟物浮光：三张统计卡（数据与跳转与原统计行完全一致）。
          if (skeuo)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  0,
                  OvertoneSpacing.lg,
                  OvertoneSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.favorite_rounded,
                        seed: 'stat-likes',
                        label: context.l10n.woXiHuan,
                        value: '$realLikesCount',
                        onTap: () => context.push('/likes'),
                      ),
                    ),
                    const SizedBox(width: OvertoneSpacing.md),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.history_rounded,
                        seed: 'stat-history',
                        label: context.l10n.zuiJinBoFang,
                        value: _historyCount == null ? '—' : '$_historyCount',
                        onTap: () => context.push('/history'),
                      ),
                    ),
                    const SizedBox(width: OvertoneSpacing.md),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.queue_music_rounded,
                        seed: 'stat-playlists',
                        label: context.l10n.geDan,
                        value: playlistStatValue,
                        hint: playlistStatHint,
                        onTap: onPlaylistStatTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 拟物浮光：真实入口卡组（卡片 + 彩色图标底）。
          // 只收真实可用入口：云盘按能力/开关条件展示，设置切到设置页签。
          if (skeuo)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  0,
                  OvertoneSpacing.lg,
                  OvertoneSpacing.md,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(OvertoneRadius.card),
                    boxShadow: theme.shadowRaised,
                  ),
                  child: Column(
                    children: [
                      _EntryTile(
                        icon: Icons.favorite_rounded,
                        seed: 'entry-likes',
                        title: context.l10n.woXiHuan,
                        onTap: () => context.push('/likes'),
                      ),
                      _EntryTile(
                        icon: Icons.history_rounded,
                        seed: 'entry-history',
                        title: context.l10n.boFangLiShi,
                        onTap: () => context.push('/history'),
                      ),
                      if (musicSourceRegistry?.capability<CloudDiskSource>(
                                accountPlatform,
                              ) !=
                              null &&
                          settings.isFeatureEnabled(
                            accountPlatform,
                            SourceFeature.cloud,
                          ))
                        _EntryTile(
                          icon: Icons.cloud_rounded,
                          seed: 'entry-cloud',
                          title: context.l10n.yinYueYunPan,
                          onTap: () => context.push('/cloud'),
                        ),
                      _EntryTile(
                        icon: Icons.settings_rounded,
                        seed: 'entry-settings',
                        title: context.l10n.sheZhi,
                        showDivider: false,
                        onTap: openSettingsTab,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // 与「探索发现」同一套页签样式：左对齐、可横向滚；吸顶。
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedTabBarDelegate(
              height: tabBar.preferredSize.height,
              background: theme.bg,
              child: tabBar,
            ),
          ),
          // 页签内容直接接在同一套滚动里（旧结构的 TabBarView 已移除）。
          if (_tabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  OvertoneSpacing.md,
                  OvertoneSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 入口已上移到统计卡下方的圆角卡组（只收真实入口）：
                    // 「本地音乐 / 下载管理」这类无真实能力的占位入口不再复活。
                    // 云盘是账号资产：当前账号源具备该能力才显示（酷狗/网易都有）；
                    // 再 AND 功能子开关（设置里关掉「音乐云盘」即隐藏）。
                    // 默认/实验皮肤保留原云盘入口卡；拟物浮光已收进上方入口卡组。
                    if (!skeuo &&
                        musicSourceRegistry?.capability<CloudDiskSource>(
                              accountPlatform,
                            ) !=
                            null &&
                        settings.isFeatureEnabled(
                          accountPlatform,
                          SourceFeature.cloud,
                        )) ...[
                      GlassSurface(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _LinkTile(
                          icon: Icons.cloud_rounded,
                          title: context.l10n.yinYueYunPan,
                          subtitle: account.isLogged
                              ? context.l10n.yunDuanSiYouWenJianKu
                              : context.l10n.dengLuHouChaKanYunPan,
                          onTap: () => context.push('/cloud'),
                        ),
                      ),
                      const SizedBox(height: OvertoneSpacing.md),
                    ],
                    GlassSurface(
                      key: _playlistsSectionKey,
                      padding: const EdgeInsets.all(OvertoneSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                context.l10n.woDeGeDan,
                                style: theme.section.copyWith(fontSize: 15),
                              ),
                              const Spacer(),
                              if (account.isLogged)
                                IconButton(
                                  icon: library.loading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                        ),
                                  tooltip: context.l10n.shuaXinGeDan,
                                  onPressed: library.loading
                                      ? null
                                      : () => ref
                                            .read(
                                              sourceLibraryProvider(
                                                accountPlatform,
                                              ).notifier,
                                            )
                                            .loadPlaylists(force: true),
                                ),
                            ],
                          ),
                          const SizedBox(height: OvertoneSpacing.md),
                          if (!account.isLogged) ...[
                            _playlistPlaceholder(
                              theme: theme,
                              message: canReadPlaylists
                                  ? context.l10n
                                        .dengLuZhangHaoHouJiKeTongBuZiJianYuShouCangG(
                                          accountPlatform.label,
                                        )
                                  : context.l10n.zanWuYunDuanGeDan(
                                      accountPlatform.label,
                                    ),
                              loginRoute: canReadPlaylists
                                  ? loginRouteFor(accountPlatform)
                                  : null,
                            ),
                          ] else ...[
                            Center(
                              child: SegmentedButton<int>(
                                segments: [
                                  ButtonSegment<int>(
                                    value: 0,
                                    label: Text(
                                      context.l10n.ziJian(
                                        library.createdPlaylists.length,
                                      ),
                                    ),
                                  ),
                                  ButtonSegment<int>(
                                    value: 1,
                                    label: Text(
                                      context.l10n.shouCang_2(
                                        library.collectedPlaylists.length,
                                      ),
                                    ),
                                  ),
                                ],
                                selected: {_selectedPlaylistTab},
                                onSelectionChanged: (set) => setState(
                                  () => _selectedPlaylistTab = set.first,
                                ),
                              ),
                            ),
                            const SizedBox(height: OvertoneSpacing.md),
                            ..._buildPlaylistList(
                              _selectedPlaylistTab == 0
                                  ? library.createdPlaylists
                                  : library.collectedPlaylists,
                              isCreatedTab: _selectedPlaylistTab == 0,
                              isLoading: library.loading && !library.loaded,
                              error: library.error,
                              theme: theme,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  OvertoneSpacing.md,
                  OvertoneSpacing.lg,
                  0,
                ),
                child: GlassSurface(
                  key: _settingsSectionKey,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _LinkTile(
                        icon: Icons.settings_outlined,
                        title: context.l10n.gengDuoSheZhi,
                        onTap: () => context.push('/settings'),
                      ),
                      // Theme-colored tiles must not be const — Flutter skips
                      // rebuild when the const instance is identical after a
                      // theme switch.
                      _LinkTile(
                        icon: Icons.timer_rounded,
                        title: context.l10n.dingShiTingZhi,
                        subtitle: sleepLabel,
                        onTap: () => _showSleepSheet(context),
                      ),
                      _LinkTile(
                        icon: Icons.music_note_rounded,
                        title: context.l10n.yinZhiSheZhi,
                        subtitle: settings.qualityLabel,
                        onTap: () => _showQualitySheet(context),
                      ),
                      _LinkTile(
                        icon: Icons.palette_outlined,
                        title: context.l10n.zhuTiWaiGuan,
                        subtitle: settings.themeModeLabel,
                        onTap: () => _showThemeSheet(context),
                      ),
                      _LinkTile(
                        icon: Icons.info_outline_rounded,
                        title: context.l10n.guanYu,
                        onTap: () => _showAboutSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // 底部留白全页只算一次：内容 sliver 自己不再带底距，
          // 避免与这层叠加成双份、或被悬浮 Dock 压住。
          SliverToBoxAdapter(child: SizedBox(height: listBottomSpacer)),
        ],
      ),
    );
  }

  /// 「我的歌单」未登录占位卡：有登录入口时引导去登录；没有时
  /// （B 站 B3/B4 落地前）只说明该源没有云端歌单——**不摆去登录的
  /// 假入口**（多音源方案 §3.2 口径）。
  Widget _playlistPlaceholder({
    required OvertoneTheme theme,
    required String message,
    required String? loginRoute,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: OvertoneSpacing.md,
        vertical: OvertoneSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceElevated.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(OvertoneRadius.tile),
      ),
      child: Column(
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 32,
            color: theme.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: OvertoneSpacing.sm),
          Text(message, style: theme.caption, textAlign: TextAlign.center),
          if (loginRoute != null) ...[
            const SizedBox(height: OvertoneSpacing.md),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              onPressed: () => context.push(loginRoute),
              child: Text(context.l10n.liJiDengLu),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPlaylistList(
    List<PlaylistBrief> playlists, {
    required bool isCreatedTab,
    required bool isLoading,
    required String error,
    required OvertoneTheme theme,
  }) {
    if (isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: OvertoneSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (playlists.isEmpty) {
      final emptyHint = error.isNotEmpty
          ? error
          : (isCreatedTab
                ? context.l10n.zanWuZiJianGeDan
                : context.l10n.zanWuShouCangGeDan);
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: OvertoneSpacing.xl),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.music_note_rounded,
                  size: 32,
                  color: theme.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(emptyHint, style: theme.caption),
              ],
            ),
          ),
        ),
      ];
    }

    return playlists.map((p) {
      final sub = context.l10n.shou_6(
        p.trackCount,
        p.creator.isNotEmpty ? ' · ${p.creator}' : '',
      );
      // 非酷狗歌单详情必须带 src，否则会落到酷狗口径的详情页取空数据。
      final src = p.platform == MusicPlatform.kugou
          ? ''
          : '?src=${p.platform.wireName}';
      return InkWell(
        borderRadius: BorderRadius.circular(OvertoneRadius.tile),
        onTap: () => context.push('/playlist/${p.id}$src', extra: p),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              _PlaylistTileCover(playlist: p, size: 48),
              const SizedBox(width: OvertoneSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: theme.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: theme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textSecondary),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// 定时停止 / 音质设置 / 关于 reuse the exact pickers the Settings page
  /// uses, so a change made here is reflected there and vice versa.
  void _showSleepSheet(BuildContext context) => showSleepPicker(context, ref);

  void _showQualitySheet(BuildContext context) =>
      showQualityPicker(context, ref);

  void _showAboutSheet(BuildContext context) => showAboutSheet(context);

  void _showThemeSheet(BuildContext context) {
    showOvertoneBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = OvertoneTheme.of(context);
            final current = ref.watch(settingsControllerProvider).themeMode;
            Widget tile(
              AppThemeMode value,
              IconData icon,
              String title,
              String sub,
            ) {
              final selected = current == value;
              return ListTile(
                leading: Icon(
                  icon,
                  color: selected ? theme.primary : theme.textSecondary,
                ),
                title: Text(title, style: theme.body),
                subtitle: Text(sub, style: theme.caption),
                trailing: selected
                    ? Icon(Icons.check_rounded, color: theme.primary)
                    : null,
                onTap: () async {
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(value);
                  if (sheetContext.mounted) {
                    setSheetState(() {});
                    Navigator.of(sheetContext).pop();
                  }
                },
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(context.l10n.zhuTiWaiGuan, style: theme.section),
                const SizedBox(height: 8),
                tile(
                  AppThemeMode.dark,
                  Icons.dark_mode_rounded,
                  context.l10n.shenSe,
                  context.l10n.gaiNianBanMoRenShenSe,
                ),
                tile(
                  AppThemeMode.light,
                  Icons.light_mode_rounded,
                  context.l10n.qianSe,
                  context.l10n.qianSeWanZhengShiPei,
                ),
                tile(
                  AppThemeMode.system,
                  Icons.brightness_auto_rounded,
                  context.l10n.genSuiXiTong,
                  context.l10n.suiXiTongShenQianSeQieHuan,
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
  });

  final String label;
  final String value;

  /// Optional secondary line under the value (e.g. why a value is missing).
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    // Fixed height so a placeholder (`—`) and a real number don't shift the
    // row when the async values land. Sized for label + value + hint.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OvertoneRadius.tile),
      child: SizedBox(
        // 有 hint 时再撑高给「需登录」副标题留位，三个统计格高度保持一致。
        height: hint != null ? 76 : 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(label, style: theme.caption),
            const SizedBox(height: 4),
            Text(value, style: theme.section.copyWith(fontSize: 22)),
            if (hint != null) ...[
              const SizedBox(height: 3),
              Text(
                hint!,
                style: theme.caption.copyWith(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: OvertoneTheme.of(context).divider,
    );
  }
}

/// 默认皮肤「我的」入口行：彩色渐变图标底 + 圆角卡组内的一条。
class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.icon,
    required this.seed,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String seed;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final colors = CoverPalette.fromSeed(seed, theme.palette).take(2).toList();
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OvertoneRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OvertoneSpacing.lg,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(OvertoneRadius.tag),
                  ),
                  child: Icon(icon, size: 16, color: theme.onCover),
                ),
                const SizedBox(width: OvertoneSpacing.md),
                Expanded(child: Text(title, style: theme.body)),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: theme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: OvertoneSpacing.lg + 28 + OvertoneSpacing.md,
            endIndent: OvertoneSpacing.lg,
            color: theme.divider,
          ),
      ],
    );
  }
}

/// 默认皮肤的统计卡：种子渐变图标底 + 数值/标签，独立于身份卡浮起。
///
/// 数据与跳转与原卡内统计行（[_Stat]）完全一致，只是承载形式从
/// 「卡内分隔行」换成「三张浮起卡」（方向 A 的统计卡语汇）。
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.seed,
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
  });

  final IconData icon;
  final String seed;
  final String label;
  final String value;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(OvertoneRadius.card),
        boxShadow: theme.shadowRaised,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OvertoneRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(OvertoneSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(OvertoneRadius.tag),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: CoverPalette.fromSeed(
                        seed,
                        theme.palette,
                      ).take(2).toList(),
                    ),
                  ),
                  child: Icon(icon, size: 16, color: theme.onCover),
                ),
                const SizedBox(height: OvertoneSpacing.sm),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.section.copyWith(
                    fontSize: 18,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.caption,
                ),
                if (hint != null)
                  Text(
                    hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.caption.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;

  /// Shown as a secondary line, and as the trailing value when short enough
  /// to read as a status (e.g. 「15 分钟」/「HQ」/「深色」).
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Prefer Material onSurface so titles stay readable even if static
    // Overtone tokens are briefly stale during a theme switch.
    final scheme = Theme.of(context).colorScheme;
    final theme = OvertoneTheme.of(context);
    final body = theme.body.copyWith(color: scheme.onSurface);
    final sub = subtitle;
    return ListTile(
      leading: Icon(icon, color: scheme.onSurfaceVariant),
      title: Text(title, style: body),
      subtitle: sub == null || sub.isEmpty
          ? null
          : Text(sub, style: theme.caption),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: scheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _PlaylistTileCover extends ConsumerWidget {
  const _PlaylistTileCover({required this.playlist, this.size = 48});

  final PlaylistBrief playlist;
  final double size;

  static bool _isNetwork(String? url) {
    if (url == null) return false;
    final s = url.trim();
    return (s.startsWith('http://') || s.startsWith('https://')) &&
        !s.contains('mock://');
  }

  /// Matches [PlaylistDetailPage]'s non-rank header Hero so the tile flies.
  Widget _withHero(Widget cover) {
    final id = playlist.id;
    if (id.isEmpty) return cover;
    return Hero(
      tag: OvertoneHeroTags.playlistCover(id),
      flightShuttleBuilder: rankHeroFlightShuttle,
      child: cover,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = playlist;
    final theme = OvertoneTheme.of(context);
    final library = ref.watch(sourceLibraryProvider(p.platform));

    final isLiked =
        p.isDefault &&
        (p.name == '我喜欢' ||
            p.name.contains('喜欢') ||
            p.name.toLowerCase().contains('like'));
    final isDefaultCollect =
        p.isDefault && (p.name == '默认收藏' || p.name.contains('收藏'));

    // Check if we have a direct valid cover URL
    String targetCover = _isNetwork(p.coverUrl) ? p.coverUrl : '';

    // If it's "我喜欢" and direct cover is empty, check if first song in likedTracks has cover
    if (isLiked && targetCover.isEmpty) {
      final firstSongCover = library.likedTracks
          .where((t) => _isNetwork(t.coverUrl))
          .firstOrNull
          ?.coverUrl;
      if (firstSongCover != null && firstSongCover.isNotEmpty) {
        targetCover = firstSongCover;
      }
    }

    // 1. If we have a valid network cover, show CoverBox with real image!
    if (targetCover.isNotEmpty) {
      final coverWidget = _withHero(
        CoverBox(
          seed: targetCover,
          size: size,
          radius: OvertoneRadius.cover,
          child: isLiked
              ? Icon(
                  Icons.favorite_rounded,
                  color: OvertoneTheme.of(context).onCoverMuted,
                  size: 24,
                )
              : (isDefaultCollect
                    ? Icon(
                        Icons.bookmark_rounded,
                        color: OvertoneTheme.of(context).onCoverMuted,
                        size: 24,
                      )
                    : Icon(
                        Icons.queue_music_rounded,
                        color: OvertoneTheme.of(context).onCoverMuted,
                        size: 24,
                      )),
        ),
      );

      // If it's "我喜欢", add a subtle corner heart badge on top of the first song's cover
      if (isLiked) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              coverWidget,
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: theme.favorite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return coverWidget;
    }

    // 2. No network cover available: render brand-solid iconic cover.
    if (isLiked) {
      return _withHero(
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OvertoneRadius.card),
            color: theme.favorite,
          ),
          child: const Center(
            child: Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    if (isDefaultCollect) {
      return _withHero(
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OvertoneRadius.card),
            color: theme.primary,
          ),
          child: const Center(
            child: Icon(Icons.bookmark_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    // 3. Generic playlist fallback
    return _withHero(
      CoverBox(
        seed: p.id,
        size: size,
        radius: OvertoneRadius.cover,
        child: Icon(
          Icons.queue_music_rounded,
          color: OvertoneTheme.of(context).onCoverMuted,
          size: 24,
        ),
      ),
    );
  }
}

/// 「我的」页吸顶页签栏。
///
/// 整页改成单层滚动后，页签栏钉在顶部（[SliverPersistentHeader.pinned]），
/// 背景必须不透明——内容会从下面滚过去，透明底会和正文糊在一起。
class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({
    required this.height,
    required this.background,
    required this.child,
  });

  /// 取 [TabBar.preferredSize] 的高度（含指示条），不写死数字。
  final double height;
  final Color background;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: background, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.background != background ||
        oldDelegate.child != child;
  }
}
