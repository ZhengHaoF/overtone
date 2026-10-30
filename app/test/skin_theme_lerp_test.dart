import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/eva_palette.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 回归：切皮肤时 ListTile / InputDecorator / PopupMenuItem 的
/// `AnimatedDefaultTextStyle` 要在新旧文字样式之间插值。
/// 皮肤注入的裸 TextStyle（inherit:true）和默认主题（本地化后 inherit:false）
/// 混在一起会抛 "Failed to interpolate TextStyles with different inherit values"。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('皮肤注入的文字样式与默认主题 inherit 一致', () {
    final base = buildOvertoneTheme(Brightness.light);
    final swiss = ArchiveSkin.theme(OvertoneAccent.teal);
    final magi = EvaPalette.unit02.theme(OvertoneAccent.teal);

    final injected = <String, TextStyle?>{
      'listTile.subtitle': swiss.listTileTheme.subtitleTextStyle,
      'input.hint': swiss.inputDecorationTheme.hintStyle,
      'input.label': swiss.inputDecorationTheme.labelStyle,
      'popupMenu.text': swiss.popupMenuTheme.textStyle,
      'chip.label': swiss.chipTheme.labelStyle,
      'chip.secondaryLabel': swiss.chipTheme.secondaryLabelStyle,
      'tab.label': swiss.tabBarTheme.labelStyle,
      'tab.unselectedLabel': swiss.tabBarTheme.unselectedLabelStyle,
      'tooltip.text': swiss.tooltipTheme.textStyle,
    };
    // 默认/MAGI 这侧由框架给样式（inherit 由本地化后的 Typography 决定）。
    final frameworkInherit = base.textTheme.bodyMedium!.inherit;
    for (final entry in injected.entries) {
      expect(entry.value, isNotNull, reason: '${entry.key} 没有注入样式');
      expect(entry.value!.inherit, isFalse, reason: '${entry.key} 必须 inherit:false');
    }
    expect(magi.listTileTheme.subtitleTextStyle, isNull);
    expect(frameworkInherit, isNotNull);
  });

  testWidgets('六向切皮肤都不抛 TextStyle 插值异常', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          builder: (context, child) => ArchiveSkinScope(child: child!),
          home: const Scaffold(body: _LerpHost()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const order = [
      ExperimentalUiSkin.swiss,
      ExperimentalUiSkin.off,
      ExperimentalUiSkin.magi,
      ExperimentalUiSkin.swiss,
      ExperimentalUiSkin.magi,
      ExperimentalUiSkin.off,
    ];
    for (final skin in order) {
      await container
          .read(settingsControllerProvider.notifier)
          .setExperimentalUi(skin);
      // 推进到插值动画中间段：断言就在这一段里抛。
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.takeException(),
        isNull,
        reason: '切到 ${skin.name} 时不该抛异常',
      );
      await tester.pumpAndSettle();
    }
  });
}

/// 三种会被框架用 AnimatedDefaultTextStyle 包住的组件：
/// ListTile（标题/副标题/尾随）、TextField（hint/label）、PopupMenuItem。
class _LerpHost extends StatelessWidget {
  const _LerpHost();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          title: Text('外观'),
          subtitle: Text('概念版默认深色'),
          trailing: Icon(Icons.check),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(hintText: '搜索歌曲', labelText: '搜索'),
          ),
        ),
        PopupMenuButton<int>(
          itemBuilder: (context) => const [
            PopupMenuItem(value: 1, child: Text('菜单项')),
          ],
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('打开菜单'),
          ),
        ),
      ],
    );
  }
}