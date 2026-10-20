import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overtone/core/app_navigator.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/music_source.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/player/player_error_prompt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _hashed(String id) => Track(
  id: id,
  name: id,
  artist: 'artist',
  album: 'album',
  coverUrl: 'https://example.invalid/$id.jpg',
  durationMs: 10000,
  hash: 'hash_$id',
);

void main() {
  testWidgets('login-required playback failure prompts login globally', (
    tester,
  ) async {
    final engine = FakeAudioPlayer();
    final source = FakeMusicSource()
      ..playError = const LoginRequired('酷狗播放需要登录');
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: engine, source: source),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('首页')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('酷狗登录页')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          scaffoldMessengerKey: overtoneScaffoldMessengerKey,
          routerConfig: router,
          builder: (context, child) => PlayerErrorPrompt(
            router: router,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    await container.read(playerControllerProvider.notifier).playQueue([
      _hashed('a'),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('酷狗播放需要登录'), findsOneWidget);
    expect(find.text('去登录'), findsOneWidget);

    await tester.tap(find.text('去登录'));
    await tester.pumpAndSettle();
    expect(find.text('酷狗登录页'), findsOneWidget);
  });

  testWidgets('desktop player page keeps a visible login error notice', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'kugo_device_dfid_registered': true,
      'kugo_device_dfid': 'test-dfid',
      'kugo_device_guid': 'test-guid',
    });
    musicSourceRegistry = MusicSourceRegistry([FakeMusicSource()]);
    addTearDown(() => musicSourceRegistry = null);

    final engine = FakeAudioPlayer();
    final source = FakeMusicSource()
      ..playError = const LoginRequired('酷狗播放需要登录');
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: engine, source: source),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(playerControllerProvider.notifier).playQueue([
      _hashed('a'),
    ]);

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

    expect(find.text('酷狗播放需要登录'), findsOneWidget);
    expect(find.text('去登录'), findsOneWidget);
  });
}
