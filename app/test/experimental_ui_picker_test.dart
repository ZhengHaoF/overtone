import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/features/settings/settings_page.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
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

  testWidgets('抽屉打开期间切皮肤，抽屉自身配色跟着变', (tester) async {
    // 回归：showOvertoneBottomSheet 曾把调用处的 Theme 拍成快照钉在弹层上，
    // 结果切皮肤时只有抽屉外壳和页面变了，抽屉里的标题/卡片还是旧调色板
    // （MAGI 的奶白标题压在瑞士纸白底上几乎看不见）。
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();
    await container
        .read(settingsControllerProvider.notifier)
        .setExperimentalUi(ExperimentalUiSkin.magi);

    late BuildContext targetContext;
    late WidgetRef targetRef;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          // 与 app.dart 一致：皮肤作用域挂在根上。
          builder: (context, child) => ArchiveSkinScope(child: child!),
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
    await tester.pumpAndSettle();

    showExperimentalUiPicker(targetContext, targetRef);
    await tester.pumpAndSettle();

    final subtitle = find.text('体验探索性设计风格与排版系统');
    Color? subtitleColor() =>
        tester.widget<Text>(subtitle).style?.color;
    Color? badgeColor() =>
        tester.widget<Text>(find.text('当前使用')).style?.color;

    final magiCaption = subtitleColor();
    final magiPrimary = badgeColor();

    await tester.tap(find.text('瑞士国际排版'));
    await tester.pumpAndSettle();

    expect(subtitleColor(), isNot(magiCaption));
    expect(badgeColor(), isNot(magiPrimary));
    // 瑞士调色板：正文次级色 + 主色（青绿）。
    expect(subtitleColor(), ArchiveSkin.palette.textSecondary);
    expect(badgeColor(), ArchiveSkin.palette.primary);
  });
}
