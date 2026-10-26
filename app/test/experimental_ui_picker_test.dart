import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/features/settings/settings_page.dart';
import 'package:overtone/shared/widgets/settings_pickers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showExperimentalUiPicker 展开侧栏并支持实时切换', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();

    late BuildContext targetContext;
    late WidgetRef targetRef;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                targetContext = context;
                targetRef = ref;
                return const Center(child: Text('Home'));
              },
            ),
          ),
        ),
      ),
    );

    // 打开实验UI选择器
    showExperimentalUiPicker(targetContext, targetRef);
    await tester.pumpAndSettle();

    // 验证侧栏内容
    expect(find.text('实验UI'), findsOneWidget);
    expect(find.text('体验探索性设计风格与排版系统'), findsOneWidget);
    expect(find.text('默认'), findsOneWidget);
    expect(find.text('瑞士国际排版'), findsOneWidget);
    expect(find.text('MAGI战术终端'), findsOneWidget);

    // 初始状态下「默认」是当前使用
    expect(find.text('当前使用'), findsOneWidget);
    expect(
      container.read(settingsControllerProvider).experimentalUi,
      ExperimentalUiSkin.off,
    );

    // 点击「瑞士国际排版」
    await tester.tap(find.text('瑞士国际排版'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingsControllerProvider).experimentalUi,
      ExperimentalUiSkin.swiss,
    );
    expect(
      container.read(settingsControllerProvider).archiveSkin,
      isTrue,
    );

    // 点击「MAGI战术终端」
    await tester.tap(find.text('MAGI战术终端'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingsControllerProvider).experimentalUi,
      ExperimentalUiSkin.magi,
    );

    // 再次点击「默认」切回
    await tester.tap(find.text('默认'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingsControllerProvider).experimentalUi,
      ExperimentalUiSkin.off,
    );
    expect(
      container.read(settingsControllerProvider).archiveSkin,
      isFalse,
    );

    // 点击右上角关闭按钮
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('体验探索性设计风格与排版系统'), findsNothing);
  });

  testWidgets('SettingsPage 中的「实验UI」入口与侧栏联动', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 找到「实验UI」行
    final tile = find.widgetWithText(ListTile, '实验UI');
    expect(tile, findsOneWidget);
    expect(
      find.descendant(of: tile, matching: find.text('默认')),
      findsOneWidget,
    );

    // 点击「实验UI」打开抽屉侧栏
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.text('体验探索性设计风格与排版系统'), findsOneWidget);

    // 点击「瑞士国际排版」
    await tester.tap(find.text('瑞士国际排版'));
    await tester.pumpAndSettle();

    // 关闭侧栏
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 检查 SettingsPage 上的显示已更新为「瑞士国际排版」
    expect(
      find.descendant(of: tile, matching: find.text('瑞士国际排版')),
      findsWidgets,
    );
  });
}
