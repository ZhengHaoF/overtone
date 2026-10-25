/// 实测 `TabBarView(children: ...)` 的实际挂载行为。
///
/// `children` 只代表「widget 对象一次性构造」，真正的 element / 子树由内部
/// PageView 惰性挂载。这条测试把结论钉死：首帧只挂当前页，切页时才挂新页。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Probe extends StatelessWidget {
  const _Probe({required this.index, required this.builds});

  final int index;
  final Map<int, int> builds;

  @override
  Widget build(BuildContext context) {
    builds[index] = (builds[index] ?? 0) + 1;
    return Center(child: Text('page $index'));
  }
}

void main() {
  testWidgets('首帧只构建当前页，切页才构建目标页', (tester) async {
    final builds = <int, int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: TabBarView(
              children: [
                for (var i = 0; i < 3; i++) _Probe(index: i, builds: builds),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(builds.keys, [0], reason: '首帧不应把三个页签的子树都挂上');
    expect(find.text('page 0'), findsOneWidget);
    expect(find.text('page 1'), findsNothing);

    // 切到第二页（DefaultTabController 的 TabBarView 支持 programmatic 切换）。
    final controller = DefaultTabController.of(tester.element(find.byType(TabBarView)));
    controller.animateTo(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(builds.containsKey(1), isTrue, reason: '切到第二页时才挂载它');
    expect(builds.containsKey(2), isFalse, reason: '第三页仍不应被挂载');
  });
}
