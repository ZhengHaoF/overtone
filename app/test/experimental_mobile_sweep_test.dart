/// 实验皮肤在手机 360px 宽度下的整站布局冒烟：主要路由不能出现溢出/断言。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overtone/app.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

const _routes = [
  '/profile',
  '/profile/detail',
  '/settings',
  '/search',
  '/likes',
  '/history',
  '/cloud',
  '/daily',
  '/discovery',
  '/ranks',
  '/recommend',
  // 详情页（song/album/artist/playlist）依赖真实的取数链路，各自另有测试；
  // 这里只扫不依赖网络的主路由与设置类页面。
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final skin in ['swiss', 'magi']) {
    testWidgets('$skin：手机 360px 主要路由无布局异常', (tester) async {
      SharedPreferences.setMockInitialValues({'settings.experimentalUi': skin});
      musicSourceRegistry = MusicSourceRegistry([ScriptedFmSource()]);
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWith(
            () => PlayerController(engine: FakeAudioPlayer()),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.notifier).ensureRestored();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OvertoneApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: '/explore');

      for (final route in _routes) {
        GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
        await tester.pump();
        // 等路由/Hero 过渡结束再跳下一页，否则连续 go 会触发 GlobalKey 重挂。
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: route);
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
}
