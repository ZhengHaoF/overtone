import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/fm_mode.dart';
import 'package:overtone/core/models/playback_source.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/capabilities.dart';
import 'package:overtone/core/source/music_platform.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/fm/fm_controller.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

class _AdvanceFmSource extends ScriptedFmSource implements FmAdvanceSource {
  _AdvanceFmSource({super.serverTracks});

  /// 推进上报返回的候选（模拟服务端顺带给出的下一批）。
  List<Track> advanceTracks = const [];

  final List<Track> advanced = [];

  @override
  Future<List<Track>> reportFmAdvance(
    Track track, {
    int unplayed = 0,
    int playtimeMs = 0,
    bool isOverplay = false,
  }) async {
    advanced.add(track);
    return advanceTracks;
  }
}

Track _track(String id, {String curMark = ''}) => Track(
      id: id,
      name: id,
      artist: 'artist',
      album: 'album',
      coverUrl: 'mock://$id',
      durationMs: 10000,
      hash: 'hash-$id',
      curMark: curMark,
    );

/// 抽干微任务，让 `unawaited` 的上报/续流跑完。
Future<void> _drain([int rounds = 24]) async {
  for (var i = 0; i < rounds; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('起播与切歌带 cur_mark 上报推进，返回候选去重后并入队列', () async {
    SharedPreferences.setMockInitialValues({
      'kugo_device_dfid_registered': true,
      'kugo_device_dfid': 'test-dfid',
      'kugo_device_guid': 'test-guid',
      'auth.user.v1':
          'userId=1001&token=valid_token&nickname=t&avatarUrl=&isVip=false&isLocalDemo=false&t1=',
    });
    final a = _track('a', curMark: 'mark-a');
    final b = _track('b', curMark: 'mark-b');
    final c = _track('c', curMark: 'mark-c');
    final source = _AdvanceFmSource(serverTracks: [a, b])
      ..advanceTracks = [b, c];
    musicSourceRegistry = MusicSourceRegistry([source]);
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: FakeAudioPlayer()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(fmControllerProvider.notifier).start();
    await _drain();
    await container.read(playerControllerProvider.notifier).next();
    await _drain();

    // 首曲 a、切到 b 各上报一次，且带上了后端下发的 cur_mark。
    expect(source.advanced.map((t) => t.id).toList(), ['a', 'b']);
    expect(source.advanced.first.curMark, 'mark-a');

    // 上报返回的 b 已入队不重复，c 补进队列（续流也不重复入队）。
    final ids = container.read(playerControllerProvider).queue
        .map((t) => t.id)
        .toList();
    expect(ids.where((id) => id == 'b').length, 1);
    expect(ids, contains('c'));
  });

  test('未实现 FmAdvanceSource 的源：不推进上报，也不影响开台', () async {
    SharedPreferences.setMockInitialValues({
      'kugo_device_dfid_registered': true,
      'kugo_device_dfid': 'test-dfid',
      'kugo_device_guid': 'test-guid',
      'auth.user.v1':
          'userId=1001&token=valid_token&nickname=t&avatarUrl=&isVip=false&isLocalDemo=false&t1=',
    });
    final source = ScriptedFmSource(serverTracks: [_track('x')]);
    musicSourceRegistry = MusicSourceRegistry([source]);
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: FakeAudioPlayer()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(fmControllerProvider.notifier).start();
    await _drain();

    expect(
      container.read(playerControllerProvider).queue.map((t) => t.id),
      ['x'],
    );
  });

  test('冷启动只恢复偏好，不认领恢复出来的队列', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await fmSessionStore.save(
      const FmSession(
        active: true,
        source: MusicPlatform.kugou,
        mode: FmMode.niche,
        pool: FmSongPool.style,
        pendingMode: FmMode.niche,
        pendingPool: FmSongPool.style,
      ),
    );
    expect(prefs.getString('fm.session'), isNotNull);

    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: FakeAudioPlayer()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_track('old')]);
    await container.read(fmControllerProvider.notifier).restorePreferences();

    final fm = container.read(fmControllerProvider);
    expect(fm.active, isFalse);
    expect(fm.mode, FmMode.niche);
    expect(fm.pool, FmSongPool.style);
    // 恢复出来的队列仍归普通播放，不被 FM 会话认领。
    expect(
      container.read(playerControllerProvider).queueSource,
      isNot(PlaybackQueueSource.fm),
    );
  });
}
