/// 实测：FM 页的两个 `repeat()` 控制器在被全屏路由盖住后是否还在驱动帧。
///
/// 结论依赖 Flutter 的 `ModalRoute` + `TickerMode`：不透明路由压栈后，下层路由
/// 会 offstage 并静音 ticker。这条测试把结论钉死——一旦将来有人换了路由类型
/// （比如改成非 opaque / 用 overlay 而不是 push），这里会红。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/features/fm/fm_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

void main() {
  testWidgets('FM 页被全屏播放页盖住后，动画 ticker 不再驱动帧', (tester) async {
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

    final router = GoRouter(
      initialLocation: '/fm',
      routes: [
        GoRoute(path: '/fm', builder: (_, _) => const FmPage()),
        GoRoute(path: '/player', builder: (_, _) => const Scaffold()),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 旋转盘 + 频谱两根控制器在跑。
    expect(tester.binding.transientCallbackCount, greaterThanOrEqualTo(2));

    router.push('/player');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester.binding.transientCallbackCount,
      0,
      reason: '下层路由被不透明全屏页覆盖后，TickerMode 应静音 FM 的循环动画',
    );
  });
}
