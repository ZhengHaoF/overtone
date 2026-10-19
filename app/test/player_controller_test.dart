import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overtone/core/models/playback_source.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/music_source.dart';
import 'package:overtone/data/storage/overtone_db.dart';
import 'package:overtone/data/storage/queue_store.dart';
import 'package:overtone/data/storage/shuffle_order_store.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/player/shuffle_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _t(String id) => Track(
      id: id,
      name: id,
      artist: 'artist',
      album: 'album',
      coverUrl: 'mock://$id',
      durationMs: 10000,
    );

/// 非 demo 曲目（http 封面）：冷启动恢复的过滤器只放行这类。
Track _http(String id) => Track(
      id: id,
      name: id,
      artist: 'artist',
      album: 'album',
      coverUrl: 'https://example.invalid/$id.jpg',
      durationMs: 10000,
    );

List<String> _idsOf(PlayerState s) =>
    [for (final t in s.queue) t.id];

ProviderContainer _containerWithFake() {
  final engine = FakeAudioPlayer();
  final container = ProviderContainer(
    overrides: [
      playerControllerProvider.overrideWith(() => PlayerController(engine: engine)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('queue advance and wrap by listLoop', () async {
    final container = _containerWithFake();
    final controller = container.read(playerControllerProvider.notifier);

    await controller.playQueue([_t('a'), _t('b')], startIndex: 0);
    expect(container.read(playerControllerProvider).current?.id, 'a');

    controller.seekTo(3000);
    expect(container.read(playerControllerProvider).positionMs, 3000);

    await controller.next();
    final afterNext = container.read(playerControllerProvider);
    expect(afterNext.current?.id, 'b');
    expect(afterNext.positionMs, 0);

    await controller.next();
    expect(container.read(playerControllerProvider).current?.id, 'a');
  });

  test('seek clamps to duration', () async {
    final container = _containerWithFake();
    final controller = container.read(playerControllerProvider.notifier);

    await controller.playQueue([_t('a')]);
    controller.seekTo(999999);
    expect(container.read(playerControllerProvider).positionMs, 10000);

    controller.seekTo(-100);
    expect(container.read(playerControllerProvider).positionMs, 0);
  });

  test('toggle play pauses timer state', () async {
    final container = _containerWithFake();
    final controller = container.read(playerControllerProvider.notifier);

    await controller.playQueue([_t('a')]);
    expect(container.read(playerControllerProvider).isPlaying, isTrue);
    controller.togglePlay();
    expect(container.read(playerControllerProvider).isPlaying, isFalse);
  });

  test('user pause wins over late engine playing=true', () async {
    final engine = FakeAudioPlayer();
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider
            .overrideWith(() => PlayerController(engine: engine)),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(playerControllerProvider.notifier);

    await controller.playQueue([_t('a')]);
    controller.togglePlay();
    expect(container.read(playerControllerProvider).display,
        PlayerDisplayState.paused);

    // Late engine event must not flip the icon against explicit pause.
    await engine.play();
    expect(container.read(playerControllerProvider).display,
        PlayerDisplayState.paused);
    expect(container.read(playerControllerProvider).isPlaying, isFalse);
  });

  test('demo track toggle after pause resumes without resolve', () async {
    final engine = FakeAudioPlayer();
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider
            .overrideWith(() => PlayerController(engine: engine)),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(playerControllerProvider.notifier);

    await controller.playQueue([_t('a')]);
    controller.togglePlay();
    expect(container.read(playerControllerProvider).isPlaying, isFalse);
    controller.togglePlay();
    expect(container.read(playerControllerProvider).isPlaying, isTrue);
  });

  test('hash track fails resolve cleanly without inventing play', () async {
    final engine = FakeAudioPlayer();
    final source = FakeMusicSource()
      ..nextPlayUrl = null
      ..playError = const NotFound('offline');
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: engine, source: source),
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(playerControllerProvider.notifier);

    final hashed = Track(
      id: 'h1',
      name: 'h1',
      artist: 'a',
      album: 'b',
      coverUrl: 'https://example.com/h1.jpg',
      durationMs: 10000,
      hash: 'hash_h1',
    );
    await controller.playQueue([hashed]);
    final state = container.read(playerControllerProvider);
    // Offline / blocked network → error, must not fake-playing forever.
    expect(state.isPlaying, isFalse);
    expect(engine.lastUrl, isNull);
    expect(
      state.display == PlayerDisplayState.error ||
          state.display == PlayerDisplayState.loading,
      isTrue,
    );
  });

  group('shuffle', () {
    setUp(() => debugShuffleRandom = Random(20240517));
    tearDown(() => debugShuffleRandom = null);

    test('entering shuffle pins the current track and permutes the rest',
        () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      final ids = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      await controller.playQueue(ids.map(_t).toList(), startIndex: 3);
      expect(controller.snapshot.current?.id, 'd');

      controller.setMode(PlayerLoopMode.shuffle);
      final s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.shuffle);
      // 不跳歌：当前曲目与游标都留在原位。
      expect(s.currentIndex, 3);
      expect(s.current?.id, 'd');
      // 同一批曲目的一个排列（固定种子下确实重排了）。
      expect(_idsOf(s), unorderedEquals(ids));
      expect(_idsOf(s), isNot(equals(ids)));
    });

    test('next() walks the whole shuffled queue once, then re-shuffles',
        () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      final ids = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      await controller.playQueue(ids.map(_t).toList());
      controller.setMode(PlayerLoopMode.shuffle);

      final played = <String>[controller.snapshot.current!.id];
      for (var i = 0; i < ids.length - 1; i++) {
        await controller.next();
        played.add(controller.snapshot.current!.id);
      }
      // 一整轮随机播放：每首恰好一次——不重复、不遗漏。
      expect(played, hasLength(ids.length));
      expect(played.toSet(), ids.toSet());

      // 环绕：重洗后从 0 开始，且不会立即重播刚播完那首。
      final last = controller.snapshot.current!.id;
      await controller.next();
      final s = controller.snapshot;
      expect(s.currentIndex, 0);
      expect(s.current?.id, isNot(last));
      expect(_idsOf(s).toSet(), ids.toSet());
    });

    test('previous() returns to the track played before in shuffle order',
        () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      await controller.playQueue(['a', 'b', 'c', 'd'].map(_t).toList());
      controller.setMode(PlayerLoopMode.shuffle);
      final first = controller.snapshot.current!.id;
      await controller.next();
      final second = controller.snapshot.current!.id;
      expect(second, isNot(first));

      await controller.previous();
      expect(controller.snapshot.current?.id, first);
    });

    test('FM queue refuses shuffle and never reorders', () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      await controller.playQueue(
        ['a', 'b', 'c'].map(_t).toList(),
        source: PlaybackQueueSource.fm,
      );
      controller.setMode(PlayerLoopMode.shuffle);
      var s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.listLoop);
      expect(_idsOf(s), ['a', 'b', 'c']);

      // 随机模式下进来的 FM 队列也保持推荐序。
      controller.setMode(PlayerLoopMode.shuffle); // 仍然进不去
      controller.setMode(PlayerLoopMode.listLoop);
      await controller.playQueue(
        ['x', 'y', 'z'].map(_t).toList(),
        source: PlaybackQueueSource.fm,
      );
      s = controller.snapshot;
      expect(_idsOf(s), ['x', 'y', 'z']);
    });

    test('leaving shuffle restores the original order without switching track',
        () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      final ids = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      await controller.playQueue(ids.map(_t).toList(), startIndex: 3);
      controller.setMode(PlayerLoopMode.shuffle);
      expect(_idsOf(controller.snapshot), isNot(equals(ids)));

      await controller.next();
      await controller.next();
      final cur = controller.snapshot.current!.id;

      // 回归：切出随机曾经只是保留打乱后的队列，用户看到的是永远乱序。
      controller.setMode(PlayerLoopMode.listLoop);
      final s = controller.snapshot;
      expect(_idsOf(s), equals(ids));
      expect(s.current?.id, cur); // 不跳歌
      expect(s.currentIndex, ids.indexOf(cur));
    });

    test('shuffle base order is persisted for a later restart', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      final ids = ['a', 'b', 'c', 'd'];
      await controller.playQueue(ids.map(_t).toList(), startIndex: 1);
      controller.setMode(PlayerLoopMode.shuffle);
      await pumpEventQueue();

      // 留底存的是 identityKey（`platform:id`），不是裸 id。
      expect(
        await ShuffleOrderStore.load(),
        equals([for (final id in ids) _t(id).identityKey]),
      );

      controller.setMode(PlayerLoopMode.listLoop);
      await pumpEventQueue();
      expect(await ShuffleOrderStore.load(), isNull);
    });

    test('appendToQueue under shuffle interleaves after the cursor', () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      final ids = ['a', 'b', 'c', 'd', 'e', 'f'];
      await controller.playQueue(ids.map(_t).toList(), startIndex: 2);
      controller.setMode(PlayerLoopMode.shuffle);
      final before = controller.snapshot;
      final cursorTrack = before.current!.id;

      await controller.appendToQueue(['x', 'y', 'z'].map(_t).toList());
      final s = controller.snapshot;
      // 游标不动，新曲也不会插到它前面把它顶掉。
      expect(s.current?.id, cursorTrack);
      expect(s.currentIndex, before.currentIndex);
      expect(_idsOf(s).toSet(), {...ids, 'x', 'y', 'z'});
      for (final id in ['x', 'y', 'z']) {
        expect(_idsOf(s).indexOf(id), greaterThan(s.currentIndex));
      }

      // 回归：追加曾经一律排队尾，随机模式下等于「播到底再顺序播完尾部」。
      // 多次追加里至少要有一次落在中间。
      var middleHit = false;
      for (var i = 0; i < 20 && !middleHit; i++) {
        final len = controller.snapshot.queue.length;
        await controller.appendToQueue([_t('n$i')]);
        if (_idsOf(controller.snapshot).indexOf('n$i') < len) middleHit = true;
      }
      expect(middleHit, isTrue);
    });

    test('playQueue under shuffle pins the picked track', () async {
      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);

      await controller.playQueue(['a', 'b', 'c'].map(_t).toList());
      controller.setMode(PlayerLoopMode.shuffle);

      final ids = ['w', 'x', 'y', 'z'];
      await controller.playQueue(ids.map(_t).toList(), startIndex: 2);
      final s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.shuffle); // 模式跨队列保留
      expect(s.currentIndex, 2);
      expect(s.current?.id, 'y'); // 点中的那首钉在起点
      expect(_idsOf(s), unorderedEquals(ids));
    });

    test('restore re-shuffles a persisted shuffle queue; FM claim rolls back',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final db = OvertoneDb.forTesting(NativeDatabase.memory());
      QueueStore.setDbForTesting(db);
      addTearDown(() async {
        QueueStore.setDbForTesting(null);
        await db.close();
      });

      final ids = ['a', 'b', 'c', 'd', 'e', 'f'];
      await db.writeQueue(ids.map(_http).toList(), 2, 'shuffle');

      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);
      await controller.restoreOrSeed();
      // 恢复路径里挂着未await的歌词/落盘，排空再断言。
      await pumpEventQueue();

      var s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.shuffle);
      expect(s.currentIndex, 2);
      expect(s.current?.id, 'c'); // 钉住的还是原来那首
      expect(_idsOf(s), unorderedEquals(ids));
      expect(_idsOf(s), isNot(equals(ids))); // 旧数据也被洗了

      // FM 认领：回滚原顺序 + mode 降级，会话（游标/当前曲目）无损。
      controller.markQueueSource(PlaybackQueueSource.fm);
      await pumpEventQueue();
      s = controller.snapshot;
      expect(s.queueSource, PlaybackQueueSource.fm);
      expect(s.mode, PlayerLoopMode.listLoop);
      expect(_idsOf(s), equals(ids));
      expect(s.currentIndex, 2);
      expect(s.current?.id, 'c');
    });

    test('restore re-shuffles on top of the saved base order', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final db = OvertoneDb.forTesting(NativeDatabase.memory());
      QueueStore.setDbForTesting(db);
      addTearDown(() async {
        QueueStore.setDbForTesting(null);
        await db.close();
      });

      final ids = ['a', 'b', 'c', 'd', 'e', 'f'];
      // 落盘的是上一轮打乱后的顺序，原始顺序另存在留底里。
      await db.writeQueue(ids.reversed.map(_http).toList(), 2, 'shuffle');
      await ShuffleOrderStore.save([for (final id in ids) _http(id).identityKey]);

      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);
      await controller.restoreOrSeed();
      await pumpEventQueue();

      var s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.shuffle);
      expect(_idsOf(s).toSet(), ids.toSet());
      // 游标跟着当前曲目（落盘第 2 位是 'd'）走，在原始顺序里是下标 3。
      expect(s.current?.id, 'd');
      expect(s.currentIndex, 3);

      // 关键：冷启动不是「在乱序上再洗一遍」，切出随机仍回到原始顺序。
      controller.setMode(PlayerLoopMode.order);
      s = controller.snapshot;
      expect(_idsOf(s), equals(ids));
    });

    test('restore keeps a non-shuffle queue untouched', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final db = OvertoneDb.forTesting(NativeDatabase.memory());
      QueueStore.setDbForTesting(db);
      addTearDown(() async {
        QueueStore.setDbForTesting(null);
        await db.close();
      });

      final ids = ['a', 'b', 'c', 'd'];
      await db.writeQueue(ids.map(_http).toList(), 1, 'listLoop');

      final container = _containerWithFake();
      final controller = container.read(playerControllerProvider.notifier);
      await controller.restoreOrSeed();
      await pumpEventQueue();

      final s = controller.snapshot;
      expect(s.mode, PlayerLoopMode.listLoop);
      expect(_idsOf(s), equals(ids));
      expect(s.currentIndex, 1);
    });
  });
}
