import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/catalog_models.dart';
import '../../core/models/comment.dart';
import '../../core/models/track.dart';
import '../../core/source/capabilities.dart';
import '../../core/source/music_platform.dart';
import '../../core/source/registry.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/player/player_controller.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/cover_box.dart';
import '../../shared/widgets/resource_comment_section.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/overtone_theme.dart';
import '../../shared/widgets/smooth_scroll.dart';
import 'package:overtone/l10n/l10n.dart';

class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({
    super.key,
    required this.id,
    this.platform = MusicPlatform.kugou,
  });

  final String id;

  /// 深链平台（路由 `?src=` 分发）：网易专辑 id 是纯数字，酷狗专辑 id
  /// 不保证，两侧接口不同，必须按源取数。
  final MusicPlatform platform;

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage> {
  AlbumDetail? _album;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    // 页面只认契约：专辑详情按 `widget.platform` 分发到对应 Source。
    final source = musicSourceRegistry?.capability<AlbumDetailSource>(
      widget.platform,
    );
    if (source == null) {
      setState(() {
        _loading = false;
        _error = context.l10n.zhuanJiJiaZaiShiBaiYinYuanBuKeYong(widget.platform.label);
      });
      return;
    }
    try {
      final remote = await source.fetchAlbumDetail(widget.id);
      if (!mounted) return;
      setState(() {
        _album = (remote != null && remote.songs.isNotEmpty) ? remote : null;
        _loading = false;
        _error = remote == null || remote.songs.isEmpty
            ? context.l10n.zhuanJiJiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongK
            : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.zhuanJiJiaZaiShiBai(e.toString().split('\n').first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final player = ref.watch(playerControllerProvider);
    final album = _album;
    final songs = album?.songs ?? const <Track>[];

    return Scaffold(
      body: SmoothCustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: archive ? 210 : 260,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: context.l10n.fanHui,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: archive
                  ? Container(
                      color: theme.bg,
                      padding: const EdgeInsets.fromLTRB(24, 64, 24, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ArchiveChrome.lineStrong(theme),
                              ),
                            ),
                            child: CoverHero(
                              tag: OvertoneHeroTags.albumCover(widget.id),
                              seed: album?.coverUrl ?? widget.id,
                              size: 120,
                              radius: 0,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArchiveKicker(
                                  left: context.l10n.zhuanJiDangAn(widget.platform.label),
                                  right: context.l10n.shou_2(songs.length),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  album?.name ?? context.l10n.zhuanJi,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.greeting.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  [
                                    if (album?.artist.isNotEmpty == true)
                                      album!.artist,
                                    if (album?.publishTime.isNotEmpty == true)
                                      album!.publishTime,
                                    context.l10n.laiYuan_3(widget.platform.label),
                                  ].join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.caption.copyWith(
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CoverHero(
                          tag: OvertoneHeroTags.albumCover(widget.id),
                          seed: album?.coverUrl ?? widget.id,
                          size: 0,
                          radius: 0,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                theme.bg.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: OvertoneSpacing.lg,
                          right: OvertoneSpacing.lg,
                          bottom: OvertoneSpacing.lg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(album?.name ?? context.l10n.zhuanJi, style: theme.title),
                              const SizedBox(height: 6),
                              Text(
                                [
                                  if (album?.artist.isNotEmpty == true)
                                    album!.artist,
                                  if (album?.publishTime.isNotEmpty == true)
                                    album!.publishTime,
                                  if (album != null) context.l10n.shou_2(songs.length),
                                  context.l10n.laiYuan_3(widget.platform.label),
                                ].join(' · '),
                                style: theme.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    onPressed: songs.isEmpty
                        ? null
                        : () {
                            ref
                                .read(playerControllerProvider.notifier)
                                .playQueue(songs, startIndex: 0);
                            context.push('/player');
                          },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label:  Text(context.l10n.boFangQuanBu),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _load, child:  Text(context.l10n.chongXinJiaZai)),
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
          else if (songs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody(
                loading: false,
                hasError: true,
                isEmpty: false,
                errorMessage: _error,
                onRetry: _load,
                child: const SizedBox.shrink(),
              ),
            )
          else
            SliverList.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final track = songs[index];
                return TrackTile(
                  track: track,
                  index: index + 1,
                  isPlaying: player.current?.id == track.id && player.isPlaying,
                  onArtistTap: artistTapFor(context, track),
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .playQueue(songs, startIndex: index);
                    context.push('/player');
                  },
                );
              },
            ),
          // 专辑评论：只在歌曲列表加载出来后才有意义（评论区块自己管 loading）。
          if (!_loading && songs.isNotEmpty)
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
                  kind: CommentResourceKind.album,
                  resourceId: widget.id,
                  resourceName: album?.name ?? '',
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
