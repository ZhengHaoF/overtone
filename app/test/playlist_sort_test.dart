// 歌单 / 榜单详情的排序纯函数测试。
//
// 重点守两件容易回归的事：
//   1. **稳定性**——Dart 的 `List.sort` 不保证稳定，同名歌曲的相对顺序不能跳；
//   2. **中文按拼音序**——不是 UTF-16 码位序（码位序下中文顺序在用户看来是乱的）。

import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/utils/playlist_sort.dart';

Track _track(
  String name, {
  String artist = '',
  String album = '',
  int durationMs = 0,
}) =>
    Track(
      id: '$name-$artist',
      name: name,
      artist: artist,
      album: album,
      coverUrl: '',
      durationMs: durationMs,
    );

List<String> _names(List<Track> tracks) =>
    tracks.map((t) => t.name).toList(growable: false);

List<String> _artists(List<Track> tracks) =>
    tracks.map((t) => t.artist).toList(growable: false);

void main() {
  group('sortTracks', () {
    test('维度为 null：保持原序，且返回的是副本', () {
      final source = [_track('C'), _track('A'), _track('B')];

      final sorted = sortTracks(source, null);

      expect(_names(sorted), ['C', 'A', 'B']);
      expect(identical(sorted, source), isFalse);
    });

    test('同名歌曲保持原相对顺序（Dart 的 List.sort 不稳定，必须显式兜底）', () {
      final source = [
        _track('Same', artist: 'A'),
        _track('Same', artist: 'B'),
        _track('Same', artist: 'C'),
        _track('Same', artist: 'D'),
      ];

      final asc = sortTracks(source, TrackSortField.title);
      expect(_artists(asc), ['A', 'B', 'C', 'D']);

      // 降序靠比较器取反实现，不是把升序结果整个倒过来——
      // 否则同键歌曲的相对顺序会跟着倒过来。
      final desc = sortTracks(source, TrackSortField.title, descending: true);
      expect(_artists(desc), ['A', 'B', 'C', 'D']);
    });

    test('中文按拼音序排，不是码位序', () {
      // 码位序：U+4ECE 从 < U+6CE2 波 < U+7231 爱
      // 拼音序：ai 爱 < bo 波 < cong 从
      final source = [_track('波'), _track('爱'), _track('从')];

      final sorted = sortTracks(source, TrackSortField.title);

      expect(_names(sorted), ['爱', '波', '从']);
    });

    test('英文标题按字母序，大小写不敏感', () {
      final source = [_track('banana'), _track('Apple'), _track('cherry')];

      final sorted = sortTracks(source, TrackSortField.title);

      expect(_names(sorted), ['Apple', 'banana', 'cherry']);
    });

    test('歌手维度', () {
      final source = [
        _track('s1', artist: '周杰伦'),
        _track('s2', artist: 'Ado'),
        _track('s3', artist: '陈奕迅'),
      ];

      final sorted = sortTracks(source, TrackSortField.artist);

      // 拼音序：Ado < chen yi xun < zhou jie lun
      expect(_artists(sorted), ['Ado', '陈奕迅', '周杰伦']);
    });

    test('专辑维度：空专辑排在前面且不崩', () {
      final source = [
        _track('s1', album: 'Yellow'),
        _track('s2', album: ''),
        _track('s3', album: 'Abbey'),
      ];

      final sorted = sortTracks(source, TrackSortField.album);

      expect(sorted.map((t) => t.album).toList(), ['', 'Abbey', 'Yellow']);
    });

    test('时长维度：升序短→长，降序长→短', () {
      final source = [
        _track('s1', durationMs: 200),
        _track('s2', durationMs: 100),
        _track('s3', durationMs: 300),
      ];

      final asc = sortTracks(source, TrackSortField.duration);
      expect(_names(asc), ['s2', 's1', 's3']);

      final desc = sortTracks(source, TrackSortField.duration, descending: true);
      expect(_names(desc), ['s3', 's1', 's2']);
    });

    test('不改动入参列表', () {
      final source = [_track('b'), _track('a')];

      sortTracks(source, TrackSortField.title);

      expect(_names(source), ['b', 'a']);
    });
  });

  group('filterAndSortTracks', () {
    test('关键字命中歌名 / 歌手 / 专辑', () {
      final source = [
        _track('起风了', artist: '买辣椒也用券', album: '起风了'),
        _track('告白气球', artist: '周杰伦', album: '告白气球'),
        _track('Lemon', artist: '米津玄师', album: 'BOOTLEG'),
      ];

      final byName = filterAndSortTracks(source, query: '气球');
      expect(_names(byName), ['告白气球']);

      final byArtist = filterAndSortTracks(source, query: '周杰伦');
      expect(_names(byArtist), ['告白气球']);

      final byAlbum = filterAndSortTracks(source, query: 'bootleg');
      expect(_names(byAlbum), ['Lemon']);
    });

    test('空关键字 = 不过滤', () {
      final source = [_track('a'), _track('b')];

      final all = filterAndSortTracks(source);

      expect(_names(all), ['a', 'b']);
    });

    test('过滤后仍按当前维度排', () {
      final source = [
        _track('波', artist: 'x'),
        _track('爱', artist: 'x'),
        _track('从', artist: 'x'),
        _track('别的歌', artist: 'y'),
      ];

      final sorted = filterAndSortTracks(
        source,
        query: 'x',
        field: TrackSortField.title,
      );

      expect(_names(sorted), ['爱', '波', '从']);
    });

    test('过滤 + 排序 + 降序组合', () {
      final source = [
        _track('s1', durationMs: 100),
        _track('s2', durationMs: 300),
        _track('s3', durationMs: 200),
      ];

      final sorted = filterAndSortTracks(
        source,
        field: TrackSortField.duration,
        descending: true,
      );

      expect(_names(sorted), ['s2', 's3', 's1']);
    });
  });
}
