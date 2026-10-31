import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _mockTrack(String id) => Track(
      id: id,
      name: '测试歌曲',
      artist: '测试歌手',
      album: '测试专辑',
      coverUrl: 'mock://$id',
      durationMs: 210000,
    );

void main() {
  Future<ProviderContainer> rig() async {
    SharedPreferences.setMockInitialValues({
      'kugo_device_dfid_registered': true,
      'kugo_device_dfid': 'test-dfid',
      'kugo_device_guid': 'test-guid',
    });
    musicSourceRegistry = MusicSourceRegistry([ScriptedFmSource()]);
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
        .playQueue([_mockTrack('t1')]);
    container.read(playerControllerProvider.notifier).togglePlay();
    return container;
  }

  Future<void> pumpPage(WidgetTester tester, ProviderContainer container) async {
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
  }

  testWidgets('桌面歌词头有全屏按钮，点击切换图标，ESC 退出', (tester) async {
    await pumpPage(tester, await rig());

    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.fullscreen_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_rounded), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
  });
}
