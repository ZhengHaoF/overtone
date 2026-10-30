import 'package:flutter/material.dart';

import '../../shared/widgets/archive_chrome.dart';
import 'rank_boards_grid.dart';
import 'package:overtone/l10n/l10n.dart';
export 'rank_hero.dart';

/// 全部榜单页（`/ranks`）。
///
/// 内容就是 [RankBoardsGrid]——探索发现「排行榜」Tab 用的也是它，
/// 两边不再各写一份取数 / 源解析 / 网格。
class RankListPage extends StatelessWidget {
  const RankListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArchivePageScaffold(
      appBar: AppBar(title:  Text(context.l10n.paiHangBang)),
      body: RankBoardsGrid(showSourceFilter: true),
    );
  }
}
