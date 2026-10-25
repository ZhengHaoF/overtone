/// 播放页进度条：按住拖动只做本地预览，松手才 seek（避免误触直接跳歌）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _mockTrack() => const Track(
      id: 'seek-1',
      name: '测试歌曲',
      artist: '测试歌手',
      album: '测试专辑',
      coverUrl: 'mock://seek-1',
      durationMs: 210000,
    );

void main() {
  testWidgets('拖动进度条：过程中不 seek，松手才跳转', (tester) async {
    SharedPreferences.setMockInitialValues({
      'kugo_device_dfid_registered': true,
      'kugo_device_dfid': 'test-dfid',
      'kugo_device_guid': 'test-guid',
    });
    musicSourceRegistry = MusicSourceRegistry([ScriptedFmSource()]);

    final engine = FakeAudioPlayer();
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: engine),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack()]);
    // demo 曲目会起 400ms / 4s 两个周期定时器，暂停一并停掉（收尾不留 pending timer）。
    container.read(playerControllerProvider.notifier).togglePlay();
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: FullPlayerPage())),
      ),
    );
    await tester.pump();

    // 起播位置归零，便于断言「拖动期间没有 seek」。
    engine.position = Duration.zero;

    final slider = find.byType(Slider).first;
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    expect(
      tester.widget<Slider>(slider).value,
      greaterThan(0),
      reason: '拖动中滑块应当显示预览值',
    );
    expect(
      container.read(playerControllerProvider).positionMs,
      0,
      reason: '拖动过程中不应提交 seek（旧实现按下即跳）',
    );

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(playerControllerProvider).positionMs,
      greaterThan(0),
      reason: '松手后应当 seek 到滑块位置',
    );

  });
}
