import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/core/theme/eva_palette.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:overtone/shared/widgets/magi_chrome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

bool _hasPilotArt(WidgetTester tester, String asset) => tester.any(
  find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == asset,
  ),
);

Track _mockTrack(String id) => Track(
  id: id,
  name: '残酷な天使のテーゼ',
  artist: '高桥洋子',
  album: 'NEON GENESIS EVANGELION',
  coverUrl: 'mock://$id',
  durationMs: 245000,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MAGI 战术终端皮肤：全屏播放页渲染 EVA 超算战术界面', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-01')]);
    // 暂停 demo 轮询定时器
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    // 1. 验证顶部导航战术组件
    expect(find.text('MAGI SYSTEM // 01'), findsOneWidget);
    expect(find.text('[ ESC ]'), findsOneWidget);
    expect(find.text('[ SPEC ]'), findsOneWidget);
    expect(find.text('[ QUEUE ]'), findsOneWidget);

    // 2. 验证目标锁定框：状态角标叠在封面上
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.text('TARGET // AUDIO'), findsOneWidget);
    expect(find.textContaining('CODE // '), findsOneWidget);

    // 3. 验证巨幅曲名与单行三贤者状态带
    expect(find.text('TRACK 01 / 01'), findsOneWidget);
    expect(find.text('残酷な天使のテーゼ'), findsOneWidget);
    expect(find.text('高桥洋子'), findsOneWidget);
    expect(find.byType(MagiConsensusBar), findsOneWidget);
    expect(find.text('MELCHIOR-1'), findsOneWidget);
    expect(find.text('BALTHASAR-2'), findsOneWidget);
    expect(find.text('CASPAR-3'), findsOneWidget);

    // 4. 验证倒计时读数与分段能量刻度
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.text('T-'), findsOneWidget);
    expect(find.textContaining('TOTAL '), findsOneWidget);

    // 5. 验证战术控制台
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.text('[ EXEC ]'), findsOneWidget);

    // 6. 验证右侧通信日志标头
    expect(find.text('MAGI // TRANSCRIPT LOG'), findsOneWidget);
    expect(find.text('实时通信日志'), findsOneWidget);

    // 7. 验证斜纹警戒条与边框准星标尺
    expect(find.byType(MagiHazardBar), findsWidgets);
    expect(find.byType(MagiFrameCorners), findsOneWidget);

    // 8. 减法版：装饰性假读数与等化器不再占左栏
    expect(find.byType(MagiEqualizerBar), findsNothing);
    expect(find.textContaining('PRIORITY'), findsNothing);
    expect(find.textContaining('DECODER'), findsNothing);
    expect(find.textContaining('SYNC: 100%'), findsNothing);

    // 9. 霓虹海报底板
    expect(find.byType(MagiBackdrop), findsOneWidget);
  });

  testWidgets('MAGI 战术终端皮肤：在标准笔记本分辨率（1280x720）下无溢出报错', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-02')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    // 验证核心组件在 720p 屏幕下正常渲染且无 RenderFlex 溢出
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAGI 战术终端皮肤：1080p 下封面填满左栏且无溢出', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-03')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    // 左栏 448 − 左右各 28 的内边距 = 392：封面与该宽度同宽（正方形），
    // 而不是旧版固定 340 靠左、右侧空出 80。
    final cover = tester.getSize(find.byType(MagiTargetFrame));
    expect(cover.width, 392);
    expect(cover.height, 392);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAGI 战术终端皮肤：手机窄屏下同样生效', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-03')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    final pageContext = tester.element(find.byType(FullPlayerPage));
    expect(OvertoneTheme.of(pageContext).bg, EvaPalette.unit02.palette.bg);
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAGI 战术终端皮肤：歌词页在手机窄屏下也生效', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-04')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const ArchiveSkinScope(child: PlayerLyricsPage()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EVA 蓝皮肤：亮色瓷白 + 绫波丽线稿水印，窄屏自动收起', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'evaBlue',
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

    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(playerControllerProvider.notifier)
        .playQueue([_mockTrack('eva-00')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    final pageContext = tester.element(find.byType(FullPlayerPage));
    // 蓝版是亮色皮肤：即使外观是暗色，注入的仍然是瓷白底。
    expect(OvertoneTheme.of(pageContext).isLight, isTrue);
    expect(OvertoneTheme.of(pageContext).bg, EvaPalette.unit00.palette.bg);
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);

    expect(_hasPilotArt(tester, 'assets/eva/rei_portrait.png'), isTrue,
        reason: '宽屏应叠绫波丽线稿');
    expect(tester.takeException(), isNull);

    // 窄屏收起线稿，避免压到内容。
    tester.view.physicalSize = const Size(360, 740);
    await tester.pump();
    expect(_hasPilotArt(tester, 'assets/eva/rei_portrait.png'), isFalse);
    expect(tester.takeException(), isNull);
  });
}
