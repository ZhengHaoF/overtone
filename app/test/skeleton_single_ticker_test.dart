import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/shared/widgets/async_body.dart';

void main() {
  testWidgets('骨架屏整列只挂一个 ticker，按相位错开', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SkeletonList(itemCount: 6))),
    );
    await tester.pump(const Duration(milliseconds: 120));

    // 一个重复播放的 AnimationController = 一个 transient frame callback；
    // 旧实现每行一个 controller，这里会是 6。
    expect(tester.binding.transientCallbackCount, 1);

    // 每行仍然在呼吸：同一时刻相邻行的透明度不同（相位差）。
    final fades = tester
        .widgetList<FadeTransition>(
          find.descendant(
            of: find.byType(SkeletonList),
            matching: find.byType(FadeTransition),
          ),
        )
        .toList();
    expect(fades.length, 6);
    final opacities = fades.map((f) => f.opacity.value).toList();
    expect(opacities.toSet().length, greaterThan(1));
  });
}
