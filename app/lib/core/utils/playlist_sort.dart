import 'package:pinyin/pinyin.dart';

import '../models/track.dart';

/// 歌曲列表可用的排序维度。
enum TrackSortField {
  title('歌名'),
  artist('歌手'),
  album('专辑'),
  duration('时长');

  const TrackSortField(this.label);
  final String label;
}

/// 拼音排序键缓存（LRU）。
///
/// 排序在每次 setState（搜索输入、换维度、换方向）都会重跑：300 首 ×
/// 3 个文本字段 ≈ 900 次拼音转换 ≈ 40ms，键盘输入时肉眼可见地掉帧。
/// 缓存后重复的歌名/歌手名/专辑名零成本。
///
/// Dart 的 Map 保持插入顺序，读命中把键挪到队尾，超容量从队首淘汰
/// （同 `features/player/lyric_cache.dart` 的 LRU 写法）。
final Map<String, String> _sortKeyCache = {};

/// 缓存上限。歌名/歌手/专辑名高度重复，几千条足够覆盖整个曲库。
const int _sortKeyCacheCapacity = 2000;

/// 排序键：中文转拼音，整体小写。
///
/// Dart 的 `String.compareTo` 按 UTF-16 码位比，汉字落在 Unicode CJK 区，
/// **不是拼音序**——码位序里"起"(U+8D77) 排在"爱"(U+7231) 之后，跟读音
/// 毫无关系。统一转成拼音再比，行为对齐 EchoMusic 的
/// `localeCompare(a, b, 'zh-Hans-CN')`。
///
/// 纯拉丁/数字标题原样透传（`getPinyinE` 对非汉字逐字写出，不加分隔符）。
String _sortKey(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return '';
  final cached = _sortKeyCache.remove(text);
  if (cached != null) {
    // 读命中：挪到队尾（LRU）。
    _sortKeyCache[text] = cached;
    return cached;
  }
  // `getPinyinE` 对字典外的生僻汉字会往 stdout 打一行日志（包内实现的
  // 遗留行为）。实测其 Unihan 词库覆盖到 CJK 扩展区，正常歌名不会触发。
  final key = PinyinHelper.getPinyinE(
    text,
    separator: ' ',
    defPinyin: ' ',
  ).toLowerCase();
  _sortKeyCache[text] = key;
  while (_sortKeyCache.length > _sortKeyCacheCapacity) {
    _sortKeyCache.remove(_sortKeyCache.keys.first);
  }
  return key;
}

/// 文本比较：先比拼音键，拼音相同再比原字。
///
/// 拼音相同但原字不同（同名不同写法）时退回原字比较，保证是**全序**——
/// 否则这些歌之间的相对顺序取决于 [List.sort] 的实现细节，会"乱跳"。
int _compareText(String left, String right) {
  final cmp = _sortKey(left).compareTo(_sortKey(right));
  if (cmp != 0) return cmp;
  return left.toLowerCase().compareTo(right.toLowerCase());
}

/// 单曲比较。
int _compareTracks(Track a, Track b, TrackSortField field) => switch (field) {
  TrackSortField.title => _compareText(a.name, b.name),
  TrackSortField.artist => _compareText(a.artist, b.artist),
  TrackSortField.album => _compareText(a.album, b.album),
  TrackSortField.duration => a.durationMs.compareTo(b.durationMs),
};

/// 按 [field] 排序；[field] 为 null = 保持原序。
///
/// [descending] 为 true 时取反（时长维度下即「长的在前」）。
///
/// **同键保持原序**：Dart 的 [List.sort] **不保证稳定**——300 首按歌名排时，
/// 同名歌曲（不同专辑/歌手）的相对顺序会跳动。必须用原下标兜底。
/// 降序时也保原相对顺序（靠比较器取反，而不是把升序结果整个倒过来）。
///
/// 返回新列表，不改动入参。
List<Track> sortTracks(
  List<Track> source,
  TrackSortField? field, {
  bool descending = false,
}) {
  if (field == null) return List.of(source);
  final indexed = List.generate(source.length, (i) => (i, source[i]));
  indexed.sort((a, b) {
    final cmp = _compareTracks(a.$2, b.$2, field);
    if (cmp != 0) return descending ? -cmp : cmp;
    // 稳定性：同键按原下标排，两个方向都保持原相对顺序。
    return a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

/// 过滤 + 排序歌曲列表（歌单详情 / 榜单详情共用）。
///
/// 过滤在前、排序在后：搜索命中后按当前维度排，命中项的相对顺序不会因为
/// 排序而变得不可预期。
List<Track> filterAndSortTracks(
  List<Track> source, {
  String query = '',
  TrackSortField? field,
  bool descending = false,
}) {
  final q = query.trim().toLowerCase();
  final filtered = q.isEmpty
      ? source
      : source.where((t) {
          return t.name.toLowerCase().contains(q) ||
              t.artist.toLowerCase().contains(q) ||
              t.album.toLowerCase().contains(q);
        }).toList();
  return sortTracks(filtered, field, descending: descending);
}
