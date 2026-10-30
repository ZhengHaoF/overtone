import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/app.dart';
import 'package:overtone/data/sources/sources.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/l10n/app_language.dart';
import 'package:overtone/shared/shell/desktop_sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';

/// 运行时切语言：设置里改语言后，当前页面要立刻换文案（不能等下次重建）。
void main() {
  testWidgets('切到英文后外壳文案立即生效，并落盘', (tester) async {
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

    Finder nav(String text) => find.descendant(
      of: find.byType(DesktopSidebar),
      matching: find.text(text),
    );
    expect(nav('发现'), findsOneWidget);

    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.en);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(nav('Discover'), findsOneWidget, reason: '英文文案应立即生效');
    expect(nav('发现'), findsNothing, reason: '不应残留中文');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.language'), 'en');

    // 已打开的页面（设置页）也要立刻换文案，而不只是侧栏。
    await tester.tap(nav('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Appearance'), findsOneWidget);
    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.ja);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('外観'), findsOneWidget, reason: '当前页要跟着换');

    // 切回中文同样立即生效。
    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.zh);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(nav('发现'), findsOneWidget);
  });
}
