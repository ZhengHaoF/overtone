import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/shared/widgets/magi_chrome.dart';

void main() {
  group('magiNumeral', () {
    test('single digits use Japanese forms', () {
      expect(magiNumeral(0), '零');
      expect(magiNumeral(1), '壱');
      expect(magiNumeral(5), '伍');
      expect(magiNumeral(9), '玖');
    });

    test('tens keep the 拾 tens marker', () {
      expect(magiNumeral(10), '壱拾');
      expect(magiNumeral(12), '壱拾弐');
      expect(magiNumeral(20), '弐拾');
    });

    test('past 99 falls back to decimal so the label stays short', () {
      expect(magiNumeral(100), '100');
      expect(magiNumeral(-3), '零');
    });
  });
}
