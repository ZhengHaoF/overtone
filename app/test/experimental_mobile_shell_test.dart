/// 实验皮肤在手机外壳上的接线：Dock 导航、迷你播放条、底部弹层。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/app.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/magi_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:overtone/shared/widgets/common.dart';
import 'package:overtone/shared/widgets/cover_box.dart';
import 'package:overtone/shared/widgets/mini_player_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';

Track _mockTrack(String id) => Track(
  id: id,
  name: '测试歌曲',
  artist: '测试歌手',
  album: '测试专辑',
  coverUrl: 'mock://$id',
  durationMs: 210000,
);

Future<ProviderContainer> _pumpApp(WidgetTester tester, String skin) async {
  SharedPreferences.setMockInitialValues({'settings.experimentalUi': skin});
  tester.view.physicalSize = const Size(400, 800);
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
  await container
      .read(playerControllerProvider.notifier)
      .playQueue([_mockTrack('shell-1')]);
  container.read(playerControllerProvider.notifier).togglePlay();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const OvertoneApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('swiss 手机外壳：Dock 编号 + 纸白调色板 + 迷你条方角', (tester) async {
    await _pumpApp(tester, 'swiss');

    expect(find.text('01 / 发现'), findsOneWidget);
    expect(find.text('02 / 我的'), findsOneWidget);

    final shellContext = tester.element(find.byType(MiniPlayerBar));
    expect(OvertoneTheme.of(shellContext).bg, ArchiveSkin.palette.bg);

    final cover = tester.widget<CoverHero>(
      find.descendant(
        of: find.byType(MiniPlayerBar),
        matching: find.byType(CoverHero),
      ),
    );
    expect(cover.radius, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('magi 手机外壳：Dock 战术标签 + 碳素调色板', (tester) async {
    await _pumpApp(tester, 'magi');

    expect(find.text('[ 01 ] 发现'), findsOneWidget);
    expect(find.text('[ 02 ] 我的'), findsOneWidget);

    final shellContext = tester.element(find.byType(MiniPlayerBar));
    expect(OvertoneTheme.of(shellContext).bg, MagiSkin.palette.bg);
    expect(tester.takeException(), isNull);
  });

  testWidgets('实验皮肤下底部弹层改硬边（无 20px 圆角）', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.experimentalUi': 'swiss'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const ArchiveSkinScope(
            child: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: OvertoneSheetChrome(child: SizedBox(height: 80)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(OvertoneSheetChrome),
            matching: find.byType(Material),
          )
          .first,
    );
    final shape = material.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.zero);
  });
}
