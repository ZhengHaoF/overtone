import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/app.dart';
import 'package:overtone/data/sources/sources.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/shared/shell/desktop_sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';

/// 英文界面下的布局冒烟：英文比中文长 30–40%，窄容器最容易溢出。
///
/// 只断言「没有异常」——包含 RenderFlex overflow（框架会当异常抛出）。
void main() {
  Future<void> pumpEnglishApp(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(() {
      tester.platformDispatcher.clearLocaleTestValue();
      tester.platformDispatcher.clearLocalesTestValue();
    });
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});
    registerDefaultMusicSources();
    final container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(
          () => PlayerController(engine: FakeAudioPlayer()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OvertoneApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> openFromSidebar(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(DesktopSidebar),
        matching: find.text(label).first,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: '切到「$label」时布局异常');
  }

  testWidgets('英文桌面外壳各入口不溢出', (tester) async {
    await pumpEnglishApp(tester);
    expect(tester.takeException(), isNull, reason: '首页在英文下布局异常');
    await openFromSidebar(tester, 'Mine');
    await openFromSidebar(tester, 'Liked');
    await openFromSidebar(tester, 'Settings');
    await openFromSidebar(tester, 'Explore');
  });
}
