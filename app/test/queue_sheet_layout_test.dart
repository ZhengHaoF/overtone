import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/features/player/full_player_page.dart';

void main() {
  test('队列弹层高度按行数估算，并封顶到屏高 62%', () {
    // 短队列：内容撑高的感觉，但有个下限，标题不会贴住列表。
    expect(queueSheetListHeight(rows: 0, screenHeight: 800), 120);
    expect(
      queueSheetListHeight(rows: 3, screenHeight: 800),
      closeTo(3 * 68 + 16, 0.001),
    );

    // 长队列：封顶，列表懒加载，不再 shrinkWrap 全量布局 300 行。
    expect(
      queueSheetListHeight(rows: 300, screenHeight: 800),
      closeTo(800 * 0.62, 0.001),
    );
    expect(
      queueSheetListHeight(rows: 300, screenHeight: 2000),
      closeTo(2000 * 0.62, 0.001),
    );
  });

  test('高度随行数单调不减', () {
    var previous = 0.0;
    for (var rows = 0; rows <= 12; rows++) {
      final height = queueSheetListHeight(rows: rows, screenHeight: 800);
      expect(height, greaterThanOrEqualTo(previous));
      previous = height;
    }
  });
}
