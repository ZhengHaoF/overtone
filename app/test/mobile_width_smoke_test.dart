/// 窄屏（360×740）冒烟：字号收敛后文字最密的两个页面不应出现溢出。
///
/// Flutter 的 RenderFlex 溢出在测试里会抛异常 → 用例直接红，所以这里不需要
/// 额外断言，pump 完成即视为布局通过。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/fm/fm_page.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Future<ProviderContainer> _rig({bool withQueue = false}) async {
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
  if (withQueue) {
    await container.read(playerControllerProvider.notifier).playQueue([
      const Track(
        id: 'mobile-1',
        name: '这一首歌的名字长到足以触发换行或省略号测试',
        artist: '测试歌手',
        album: '测试专辑',
        coverUrl: 'mock://mobile-1',
        durationMs: 210000,
      ),
    ]);
    // 停掉 demo 曲目的周期定时器，收尾不留 pending timer。
    container.read(playerControllerProvider.notifier).togglePlay();
  }
  return container;
}

ThemeData _themeFor(Brightness brightness) => buildOvertoneTheme(brightness);

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    testWidgets('FM 页在 360×740 下不溢出（${brightness.name}）', (tester) async {
      final container = await _rig();
      _usePhoneSize(tester);
      final router = GoRouter(
        initialLocation: '/fm',
        routes: [GoRoute(path: '/fm', builder: (_, _) => const FmPage())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: _themeFor(brightness),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('播放页在 360×740 下不溢出（${brightness.name}）', (tester) async {
      final container = await _rig(withQueue: true);
      _usePhoneSize(tester);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: _themeFor(brightness),
            home: const Scaffold(body: FullPlayerPage()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  }
}
