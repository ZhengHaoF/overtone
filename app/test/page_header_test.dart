import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/experimental_ui_skin.dart';
import 'package:overtone/core/theme/eva_palette.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';
import 'package:overtone/shared/widgets/page_header.dart';

/// 页头只对「位置」和「字号继承」负责：几何必须和直接写 `AppBar` 的页面
/// （每日推荐 / 探索 / 我喜欢…）完全重合，否则又回到各页自绘那套。
class _HeaderPage extends StatelessWidget {
  const _HeaderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: overtonePageHeader(context, title: Text(title)));
  }
}

void main() {
  Widget app(ThemeData theme, Widget page) {
    return MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) => ArchiveSkinActive(
          active: true,
          skin: ExperimentalUiSkin.magi,
          child: page,
        ),
      ),
    );
  }

  testWidgets('MAGI：标题位置与字号和裸 AppBar 完全一致', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final theme = EvaPalette.unit02.theme(OvertoneAccent.coral);

    await tester.pumpWidget(
      app(theme, Scaffold(appBar: AppBar(title: const Text('每日推荐')))),
    );
    final daily = tester.getRect(find.text('每日推荐'));

    await tester.pumpWidget(app(theme, const _HeaderPage(title: '个人中心')));
    await tester.pumpAndSettle();
    final account = tester.getRect(find.text('个人中心'));

    expect(account.left, daily.left);
    expect(account.top, daily.top);

    final paragraph = tester.renderObject<RenderParagraph>(find.text('个人中心'));
    expect(
      paragraph.text.style?.fontSize,
      theme.appBarTheme.titleTextStyle?.fontSize,
    );
    expect(
      paragraph.text.style?.fontWeight,
      theme.appBarTheme.titleTextStyle?.fontWeight,
    );
  });

  testWidgets('桌面端不出返回键，窄屏 push 进来才出', (tester) async {
    final theme = EvaPalette.unit02.theme(OvertoneAccent.coral);

    Widget host() => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) => ArchiveSkinActive(
          active: true,
          skin: ExperimentalUiSkin.magi,
          child: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const _HeaderPage(title: '音乐云盘'),
                  ),
                ),
                child: const Text('进入'),
              ),
            ),
          ),
        ),
      ),
    );

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host());
    await tester.tap(find.text('进入'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);

    tester.view.physicalSize = const Size(390, 800);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host());
    await tester.tap(find.text('进入'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
  });
}
