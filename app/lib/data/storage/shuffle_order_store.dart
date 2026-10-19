import 'package:shared_preferences/shared_preferences.dart';

/// 洗牌前的原始队列顺序（按 `identityKey` 序列）。
///
/// 随机模式下「队列顺序即播放顺序」，播放队列本身被重排（见
/// `shuffle_order.dart`）。切回顺序播放时就地回排需要知道原顺序，而 Drift
/// 的队列表加列要走 build_runner 重生成，这份数据又只是「切出随机时还原
/// 用」的旁路状态，因此和 [PlaybackPositionStore] 一样放 SharedPreferences。
class ShuffleOrderStore {
  ShuffleOrderStore._();

  static const _kKey = 'player.shuffle.baseKeys';
  static Future<void>? _writeTail;

  static Future<void> _write(Future<void> Function() action) {
    final next = _writeTail?.then((_) => action()) ?? action();
    _writeTail = next.catchError((Object _) {});
    return _writeTail!;
  }

  static Future<void> save(List<String> keys) => _write(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (keys.isEmpty) {
        await prefs.remove(_kKey);
      } else {
        await prefs.setStringList(_kKey, keys);
      }
    } catch (_) {}
  });

  static Future<void> clear() => _write(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kKey);
    } catch (_) {}
  });

  /// 留底的原顺序；无记录 / 已被清掉 → null。
  static Future<List<String>?> load() async {
    try {
      await _writeTail;
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList(_kKey);
      if (keys == null || keys.isEmpty) return null;
      return keys;
    } catch (_) {
      return null;
    }
  }
}
