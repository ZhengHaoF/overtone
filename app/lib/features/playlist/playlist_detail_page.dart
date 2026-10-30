import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/comment.dart';
import '../../core/models/track.dart';
import '../../core/source/capabilities.dart';
import '../../core/source/music_platform.dart';
import '../../core/source/registry.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/player/player_controller.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/overtone_h_scroll.dart';
import '../../shared/widgets/resource_comment_section.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/playlist_sort.dart';
import '../../features/rank/rank_list_page.dart'
    show rankCoverHeroTag, RankDetailHeaderSurface, rankHeroFlightShuttle;
import '../../shared/widgets/smooth_scroll.dart';
import 'package:overtone/l10n/l10n.dart';

/// 排序弹层的选项。
///
/// **不能用 `TrackSortField?` 直接传值**：「默认顺序」对应 null，与「用户点
/// 遮罩取消」撞值，`showOvertoneBottomSheet` 返回 null 时分不清两者。
enum _SortChoice {
  defaultOrder,
  title,
  artist,
  album,
  duration;

  String get label => switch (this) {
        defaultOrder => l10n.moRenShunXu,
        title => l10n.geMing,
        artist => l10n.geShou,
        album => l10n.zhuanJi,
        duration => l10n.shiChang,
      };

  /// 对应的排序维度；[defaultOrder] = 不排序（歌单/榜单原序）。
  TrackSortField? get field => switch (this) {
    _SortChoice.defaultOrder => null,
    _SortChoice.title => TrackSortField.title,
    _SortChoice.artist => TrackSortField.artist,
    _SortChoice.album => TrackSortField.album,
    _SortChoice.duration => TrackSortField.duration,
  };
}

class PlaylistDetailPage extends ConsumerStatefulWidget {
  const PlaylistDetailPage({
    super.key,
    required this.id,
    this.initialBrief,
    this.isRank,
    this.platform = MusicPlatform.kugou,
  });

  final String id;
  final PlaylistBrief? initialBrief;
  final bool? isRank;

  /// 深链平台：网易歌单/榜单共用歌单详情（G10），路由 `?src=` 分发。
  final MusicPlatform platform;

  @override
  ConsumerState<PlaylistDetailPage> createState() =>
      _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
  PlaylistBrief? _brief;
  List<Track> _tracks = const [];
  bool _loading = true;
  String _error = '';

  /// 页内换榜后的当前 id；空 = 用路由 [PlaylistDetailPage.id]。
  String? _activeRankId;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// 当前排序维度；null = 保持歌单/榜单原序。
  TrackSortField? _sortField;

  /// 当前排序方向；true = 降序（时长维度下即「长的在前」）。
  bool _sortDescending = false;

  List<PlaylistBrief> _allRanks = const [];
  bool _rankPickerLoading = false;
  String _rankPickerGroup = '';

  bool get _isRankView => widget.isRank ?? widget.initialBrief?.isRank ?? false;
  String get _effectiveId => _activeRankId ?? widget.id;

  @override
  void initState() {
    super.initState();
    _brief = widget.initialBrief;
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    // 页面只认契约：歌单/榜单详情、用户自建/收藏路径全在 Source 内。
    final source = musicSourceRegistry
        ?.capability<PlaylistDetailSource>(widget.platform);
    if (source == null) {
      setState(() {
        _loading = false;
        _error = l10n.jiaZaiShiBaiYinYuanBuKeYong(
          _isRankView ? l10n.bangDan : l10n.geDan,
          widget.platform.label,
        );
      });
      return;
    }
    try {
      final detail = await source.fetchPlaylistDetail(
        _effectiveId,
        briefHint: widget.initialBrief ?? _brief,
        preferRank: _isRankView,
      );
      if (!mounted) return;
      // null = 无数据；非 null 且 tracks 为空 = 合法的空用户歌单。
      if (detail == null) {
        setState(() {
          _loading = false;
          _error =
              context.l10n.jiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongKaiS(_isRankView ? "榜单" : "歌单");
        });
        return;
      }
      _applyLoaded(
        detail.brief,
        detail.tracks,
        isRank: detail.brief.isRank || _isRankView,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.jiaZaiShiBai_2(e.toString().split('\n').first);
      });
    }
  }

  void _applyLoaded(
    PlaylistBrief loadedBrief,
    List<Track> loadedTracks, {
    required bool isRank,
  }) {
    final existingCover = _brief?.coverUrl ?? '';
    final remoteCover = loadedBrief.coverUrl;
    var cover = (remoteCover.isNotEmpty &&
            !remoteCover.contains('mock://') &&
            !remoteCover.endsWith('/$_effectiveId'))
        ? remoteCover
        : (existingCover.isNotEmpty && !existingCover.contains('mock://')
            ? existingCover
            : '');

    if (cover.isEmpty && loadedTracks.isNotEmpty) {
      for (final t in loadedTracks) {
        if (t.coverUrl.isNotEmpty &&
            !t.coverUrl.contains('mock://') &&
            (t.coverUrl.startsWith('http://') ||
                t.coverUrl.startsWith('https://'))) {
          cover = t.coverUrl;
          break;
        }
      }
    }

    final genericName = isRank ? context.l10n.bangDan : context.l10n.geDan;
    final name = (loadedBrief.name.isNotEmpty && loadedBrief.name != genericName)
        ? loadedBrief.name
        : (_brief?.name ?? loadedBrief.name);

    setState(() {
      _brief = PlaylistBrief(
        id: loadedBrief.id.isNotEmpty ? loadedBrief.id : _effectiveId,
        name: name,
        coverUrl: cover,
        description: loadedBrief.description.isNotEmpty
            ? loadedBrief.description
            : (_brief?.description ?? ''),
        creator: loadedBrief.creator.isNotEmpty
            ? loadedBrief.creator
            : (_brief?.creator ?? ''),
        trackCount: loadedTracks.isNotEmpty
            ? loadedTracks.length
            : loadedBrief.trackCount,
        playCountLabel: loadedBrief.playCountLabel.isNotEmpty
            ? loadedBrief.playCountLabel
            : (_brief?.playCountLabel ?? ''),
        isRank: isRank,
        listKind: loadedBrief.listKind,
        userId: loadedBrief.userId,
        isDefault: loadedBrief.isDefault,
        rankTypeName: loadedBrief.rankTypeName.isNotEmpty
            ? loadedBrief.rankTypeName
            : (_brief?.rankTypeName ?? ''),
        updateFrequency: loadedBrief.updateFrequency.isNotEmpty
            ? loadedBrief.updateFrequency
            : (_brief?.updateFrequency ?? ''),
      );
      _tracks = loadedTracks;
      _loading = false;
    });
  }

  /// 榜单名次 = 在原始榜单中的位置，搜索/排序后仍显示原名次。
  Map<String, int> get _rankIndexOf {
    final map = <String, int>{};
    for (var i = 0; i < _tracks.length; i++) {
      final key = _tracks[i].id.isNotEmpty ? _tracks[i].id : _tracks[i].hash;
      if (key.isNotEmpty) map[key] = i + 1;
    }
    return map;
  }

  /// 关弹窗并换榜。必须用弹窗自己的 [dialogContext] pop：
  /// `showDialog` 默认挂在 root navigator，用页面 context pop 会把
  /// 详情路由弹回榜单列表，弹窗反而留在上层。
  Future<void> _switchRank(BuildContext dialogContext, PlaylistBrief rank) async {
    Navigator.of(dialogContext).pop();
    if (rank.id == _effectiveId) return;
    if (!mounted) return;
    setState(() {
      _activeRankId = rank.id;
      _brief = rank.copyWith(isRank: true);
      _tracks = const [];
      _searchQuery = '';
      _searchController.clear();
      _sortField = null;
      _sortDescending = false;
      _error = '';
    });
    await _load();
  }

  Map<String, List<PlaylistBrief>> get _rankGroups {
    final groups = <String, List<PlaylistBrief>>{};
    for (final rank in _allRanks) {
      final key = rank.rankTypeName.trim().isEmpty
          ? context.l10n.tuiJian
          : rank.rankTypeName.trim();
      groups.putIfAbsent(key, () => []).add(rank);
    }
    return groups;
  }

  Future<void> _openRankPicker() async {
    setState(() => _rankPickerLoading = true);
    if (_allRanks.isEmpty) {
      try {
        // 两源均实现 RankSource：酷狗=榜单列表接口，网易=G11 榜单列表按白名单过滤。
        final rankSource =
            musicSourceRegistry?.capability<RankSource>(widget.platform);
        _allRanks =
            rankSource != null ? await rankSource.rankBoards() : const [];
      } catch (_) {
        _allRanks = const [];
      }
    }
    final groups = _rankGroups;
    if (_rankPickerGroup.isEmpty || !groups.containsKey(_rankPickerGroup)) {
      _rankPickerGroup = _brief?.rankTypeName.trim().isNotEmpty == true
          ? _brief!.rankTypeName.trim()
          : (groups.isNotEmpty ? groups.keys.first : '');
    }
    setState(() => _rankPickerLoading = false);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      // 与详情页同一 navigator，返回手势/ESC 只关弹窗。
      useRootNavigator: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final theme = OvertoneTheme.of(dialogContext);
            final groupKeys = groups.keys.toList();
            final activeGroup = _rankPickerGroup.isNotEmpty &&
                    groups.containsKey(_rankPickerGroup)
                ? _rankPickerGroup
                : (groupKeys.isNotEmpty ? groupKeys.first : '');
            final ranks = groups[activeGroup] ?? const <PlaylistBrief>[];
            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
                child: Padding(
                  padding: const EdgeInsets.all(OvertoneSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(context.l10n.qieHuanBangDan, style: theme.section),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            tooltip: context.l10n.guanBi,
                          ),
                        ],
                      ),
                      if (_rankPickerLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_allRanks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(context.l10n.zanWuBangDan, style: theme.caption),
                          ),
                        )
                      else ...[
                        if (groupKeys.length > 1) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 36,
                            child: OvertoneHScroll(
                              fadeEdges: false,
                              builder: (context, controller, _) =>
                                  ListView.separated(
                                controller: controller,
                                scrollDirection: Axis.horizontal,
                                itemCount: groupKeys.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final key = groupKeys[index];
                                  final selected = key == activeGroup;
                                  return ChoiceChip(
                                    label: Text(key),
                                    selected: selected,
                                    onSelected: (_) {
                                      setDialogState(
                                        () => _rankPickerGroup = key,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: ranks.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final rank = ranks[index];
                              final selected = rank.id == _effectiveId;
                              return ListTile(
                                dense: true,
                                selected: selected,
                                title: Text(rank.name),
                                subtitle: [
                                  if (rank.updateFrequency.isNotEmpty)
                                    rank.updateFrequency,
                                  if (rank.playCountLabel.isNotEmpty)
                                    rank.playCountLabel,
                                ].join(' · ').isEmpty
                                    ? null
                                    : Text(
                                        [
                                          if (rank.updateFrequency.isNotEmpty)
                                            rank.updateFrequency,
                                          if (rank.playCountLabel.isNotEmpty)
                                            rank.playCountLabel,
                                        ].join(' · '),
                                        style: theme.caption,
                                      ),
                                trailing: selected
                                    ? Icon(Icons.check_rounded,
                                        color: theme.primary, size: 20)
                                    : null,
                                onTap: () => _switchRank(dialogContext, rank),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  void _playAll(List<Track> queue) {
    if (queue.isEmpty) return;
    ref.read(playerControllerProvider.notifier).playQueue(queue, startIndex: 0);
    context.push('/player');
  }

  /// 打开排序弹层：选维度 + 切方向。
  ///
  /// 移动端是底部弹层，桌面端是右侧抽屉（`showOvertoneBottomSheet` 按视口
  /// 宽度自动选形态），全平台一条代码路径。
  ///
  /// 弹层内改选择**不立即生效**，点「完成」才应用；点遮罩或「取消」= 放弃。
  Future<void> _openSortPicker() async {
    final theme = OvertoneTheme.of(context);
    var field = _sortField;
    var descending = _sortDescending;
    final picked = await showOvertoneBottomSheet<
        ({TrackSortField? field, bool descending})>(
      context: context,
      // 默认（isScrollControlled: false）会把弹层高度卡在屏幕的 9/16，
      // 5 行选项 + 按钮行约 344dp，在小屏手机上会被裁掉。
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Widget? trailingFor(_SortChoice choice) {
            final isActive = choice.field == field;
            if (isActive && field != null) {
              // 方向按钮只对已选中的维度显示：点了就地翻转方向，不关弹层。
              return IconButton(
                tooltip: descending
                    ? context.l10n.gaiWeiShengXu
                    : context.l10n.gaiWeiJiangXu,
                icon: Icon(
                  descending
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 20,
                  color: theme.primary,
                ),
                onPressed: () => setSheetState(() => descending = !descending),
              );
            }
            if (isActive) {
              return Icon(Icons.check_rounded, color: theme.primary, size: 20);
            }
            return null;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              for (final choice in _SortChoice.values)
                ListTile(
                  title: Text(choice.label, style: theme.body),
                  trailing: trailingFor(choice),
                  onTap: () => setSheetState(() => field = choice.field),
                ),
              const SizedBox(height: OvertoneSpacing.sm),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child:  Text(context.l10n.quXiao),
                  ),
                  const SizedBox(width: OvertoneSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(
                      (field: field, descending: descending),
                    ),
                    child:  Text(context.l10n.wanCheng),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _sortField = picked.field;
      _sortDescending = picked.descending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerControllerProvider);
    final brief = _brief;
    final isRankView = _isRankView;
    final tracks = _tracks;
    // 普通歌单和榜单都走同一套过滤 + 排序（排序是纯客户端的，不写回云端）。
    final displayed = filterAndSortTracks(
      tracks,
      query: _searchQuery,
      field: _sortField,
      descending: _sortDescending,
    );
    final rankIndexOf = _rankIndexOf;
    final desktop = isDesktopView(context);
    final sortTooltip = _sortField == null
        ? context.l10n.paiXuFangShi
        : context.l10n.paiXuFangShi_2(
          _sortField!.label,
          _sortDescending ? context.l10n.jiangXu : context.l10n.shengXu,
        );

    return Scaffold(
      // 浏览型详情页：铺满侧栏之外的全部宽度，与发现/探索/榜单一致。
      body: SmoothCustomScrollView(
        slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: context.l10n.fanHui,
              ),
              actions: [
                if (isRankView)
                  IconButton(
                    onPressed: _openRankPicker,
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: context.l10n.qieHuanBangDan,
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: isRankView
                      ? rankCoverHeroTag(_effectiveId)
                      : OvertoneHeroTags.playlistCover(_effectiveId),
                  flightShuttleBuilder: rankHeroFlightShuttle,
                  child: RankDetailHeaderSurface(
                    brief: brief,
                    platform: widget.platform,
                    tracksCount: tracks.isNotEmpty
                        ? tracks.length
                        : (brief?.trackCount ??
                            widget.initialBrief?.trackCount ??
                            0),
                    fallbackId: _effectiveId,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  OvertoneSpacing.lg,
                  OvertoneSpacing.lg,
                  OvertoneSpacing.sm,
                ),
                child: Row(
                  children: [
                    FilledButton.icon(
                      onPressed: displayed.isEmpty
                          ? null
                          : () => _playAll(displayed),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label:  Text(context.l10n.boFangQuanBu),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _load,
                      child:  Text(context.l10n.chongXinJiaZai),
                    ),
                  ],
                ),
              ),
            ),
            if (!_loading && tracks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OvertoneSpacing.lg,
                    0,
                    OvertoneSpacing.lg,
                    OvertoneSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: OvertoneTheme.of(context).body,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: context.l10n.souSuoGeMingGeShouZhuanJi_2,
                            hintStyle: OvertoneTheme.of(context).caption,
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    tooltip: context.l10n.qingKong,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(OvertoneRadius.tile),
                              borderSide: BorderSide(
                                color: OvertoneTheme.of(context).divider,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(OvertoneRadius.tile),
                              borderSide: BorderSide(
                                color: OvertoneTheme.of(context).divider,
                              ),
                            ),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.sort_rounded,
                          size: 20,
                          color: _sortField == null
                              ? null
                              : OvertoneTheme.of(context).primary,
                        ),
                        tooltip: sortTooltip,
                        onPressed: _openSortPicker,
                      ),
                      if (desktop) ...[
                        const SizedBox(width: 4),
                        Text(
                          _searchQuery.isEmpty
                              ? context.l10n.shou_2(displayed.length)
                              : context.l10n.shou_5(displayed.length, tracks.length),
                          style: OvertoneTheme.of(context).caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (_loading)
              const SliverFillRemaining(
                // SkeletonList is a ListView (a viewport), so the sliver must
                // treat it as a scrolling body or intrinsic layout asserts.
                child: SkeletonList(),
              )
            else if (tracks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AsyncBody(
                  loading: false,
                  hasError: _error.isNotEmpty,
                  isEmpty: true,
                  errorMessage: _error,
                  emptyMessage: context.l10n.zanWuGeQu,
                  onRetry: _load,
                  child: const SizedBox.shrink(),
                ),
              )
            else if (displayed.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AsyncBody(
                  loading: false,
                  hasError: false,
                  isEmpty: true,
                  emptyMessage: context.l10n.meiYouPiPeiDeGeQu,
                  onRetry: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: const SizedBox.shrink(),
                ),
              )
            else
              SliverList.builder(
                itemCount: displayed.length,
                itemBuilder: (context, index) {
                  final track = displayed[index];
                  final key = track.id.isNotEmpty ? track.id : track.hash;
                  final rankNo = isRankView ? (rankIndexOf[key] ?? index + 1) : index + 1;
                  return TrackTile(
                    track: track,
                    index: rankNo,
                    isPlaying:
                        player.current?.id == track.id && player.isPlaying,
                    onArtistTap: artistTapFor(context, track),
                    onTap: () {
                      ref
                          .read(playerControllerProvider.notifier)
                          .playQueue(displayed, startIndex: index);
                      context.push('/player');
                    },
                  );
                },
              ),
            // 歌单评论：搜索态下不显示（列表被过滤，插在中间会误导）。
            // 榜单也跳过 —— 榜单是另一个入口，评论池走 specialid 不合适。
            if (!_loading &&
                tracks.isNotEmpty &&
                _searchQuery.isEmpty &&
                musicSourceRegistry?.capability<ResourceCommentSource>(
                  widget.platform) != null &&
                !isRankView)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OvertoneSpacing.lg,
                    OvertoneSpacing.xl,
                    OvertoneSpacing.lg,
                    0,
                  ),
                  child: ResourceCommentSection(
                    platform: widget.platform,
                    kind: CommentResourceKind.playlist,
                    resourceId: widget.id,
                    resourceName: _brief?.name ?? '',
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
      ),
    );
  }
}
