import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/ui_demo/liquid_glass_demo_page.dart';

void main() {
  testWidgets('液态玻璃示范页支持效果降级和播放控件交互', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildOvertoneTheme(Brightness.dark),
        home: const LiquidGlassDemoPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('液态玻璃'), findsOneWidget);
    expect(find.text('基础玻璃卡片'), findsOneWidget);
    expect(find.text('玻璃海'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNWidgets(4));
    expect(find.byType(Switch), findsNWidgets(2));
    expect(
      tester.widgetList<BackdropFilter>(find.byType(BackdropFilter)),
      everyElement(
        isA<BackdropFilter>().having((w) => w.enabled, 'enabled', isTrue),
      ),
    );

    await tester.tap(find.byTooltip('播放'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<BackdropFilter>(find.byType(BackdropFilter)),
      everyElement(
        isA<BackdropFilter>().having((w) => w.enabled, 'enabled', isFalse),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('浅色窄屏布局无溢出', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildOvertoneTheme(Brightness.light),
        home: const LiquidGlassDemoPage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('按压示范'), 120);
    await tester.pumpAndSettle();

    expect(find.text('按压示范'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
