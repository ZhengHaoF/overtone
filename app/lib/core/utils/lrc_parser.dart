import 'dart:math';

import '../../core/models/track.dart';

/// Minimal LRC parser supporting [mm:ss.xx] / [mm:ss.xxx] tags.
///
/// [pairTranslations] enables the common embedded-LRC layout where the original
/// and its translation are two consecutive lines sharing (almost) the same
/// timestamp. It is opt-in: ordinary lyrics can also repeat two lines at the
/// same timestamp (echo/duet), and those must stay independent.
List<LyricLine> parseLrc(String raw, {bool pairTranslations = false}) {
  final entries = _parseEntries(raw);
  final usePairs = pairTranslations && _hasPairedLayout(entries);
  final merged = <_LrcLine>[];
  _LrcEntry? pending;

  for (final entry in entries) {
    if (usePairs && pending != null && _isPairedFollowUp(pending, entry)) {
      merged.last.translated = entry.text;
      pending = null;
      continue;
    }
    merged.add(_LrcLine(entry.timeMs, entry.text, merged.length));
    pending = entry;
  }

  merged.sort((a, b) {
    final byTime = a.timeMs.compareTo(b.timeMs);
    return byTime != 0 ? byTime : a.sequence.compareTo(b.sequence);
  });

  final deduped = <_LrcLine>[];
  for (final line in merged) {
    final previous = deduped.isEmpty ? null : deduped.last;
    if (previous != null &&
        previous.timeMs == line.timeMs &&
        previous.text == line.text) {
      previous.translated ??= line.translated;
      continue;
    }
    deduped.add(line);
  }

  final lines = <LyricLine>[];
  for (var i = 0; i < deduped.length; i++) {
    final line = deduped[i];
    final start = line.timeMs;
    final end = i + 1 < deduped.length ? deduped[i + 1].timeMs : start + 3000;
    lines.add(
      LyricLine(
        timeMs: start,
        endMs: end > start ? end : start + 1,
        text: line.text,
        translated: line.translated,
      ),
    );
  }
  return lines;
}

/// Index of the line whose timestamp is <= [positionMs], or `-1` when even the
/// first line has not started yet.
///
/// Binary search: the old linear scan ran per visible lyric row on **every**
/// position tick (O(rows × lines) per frame) and once per engine sample in the
/// controller. [lines] must be sorted by [LyricLine.timeMs] ascending — the
/// parsers sort before returning.
int findLyricIndex(List<LyricLine> lines, int positionMs) {
  var low = 0;
  var high = lines.length - 1;
  var active = -1;
  while (low <= high) {
    final mid = (low + high) >> 1;
    if (lines[mid].timeMs <= positionMs) {
      active = mid;
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }
  return active;
}

/// [findLyricIndex] clamped to `0`, i.e. the index a lyrics view highlights.
int activeLyricIndex(List<LyricLine> lines, int positionMs) {
  if (lines.isEmpty) return 0;
  final found = findLyricIndex(lines, positionMs);
  return found < 0 ? 0 : found;
}

final RegExp _timeTag = RegExp(
  r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]',
);

/// Enhanced-LRC inline word stamps, e.g. `<00:47.38>锁`. Overtone does not
/// build character timings from LRC (KRC/YRC already cover word-by-word), but
/// the tags must not leak into the displayed text.
final RegExp _enhancedTag = RegExp(
  r'<(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?>',
);

final RegExp _spaces = RegExp(r'\s+');

/// Some taggers round the translation timestamp separately; a strict equality
/// check would reject the whole file.
const int _pairedTimestampToleranceMs = 250;

/// Trust pairing only when the layout is systematic: at least two pairs and no
/// more than 30% unpaired lines (minimum 2). Sporadic same-time echo/duet lines
/// must not be turned into translations.
bool _hasPairedLayout(List<_LrcEntry> entries) {
  var pairs = 0;
  _LrcEntry? pending;
  for (final entry in entries) {
    if (pending != null && _isPairedFollowUp(pending, entry)) {
      pairs++;
      pending = null;
      continue;
    }
    pending = entry;
  }
  final unpaired = entries.length - pairs * 2;
  final allowed = max(2, (entries.length * 0.3).round());
  return pairs >= 2 && unpaired <= allowed;
}

/// The follow-up must be the next source line — a blank line, metadata or a
/// timestamp-only line in between breaks the pair. Identical text is a
/// duplicate, not a translation.
bool _isPairedFollowUp(_LrcEntry previous, _LrcEntry next) =>
    next.sourceLine == previous.sourceLine + 1 &&
    (next.timeMs - previous.timeMs).abs() <= _pairedTimestampToleranceMs &&
    _compact(next.text) != _compact(previous.text);

String _compact(String text) => text.replaceAll(_spaces, '');

List<_LrcEntry> _parseEntries(String raw) {
  final entries = <_LrcEntry>[];
  final sourceLines = raw.split(RegExp(r'\r?\n'));
  for (var i = 0; i < sourceLines.length; i++) {
    final line = sourceLines[i].trim();
    if (line.isEmpty) continue;
    final matches = _timeTag.allMatches(line).toList();
    if (matches.isEmpty) continue;
    final text = line
        .replaceAll(_timeTag, '')
        .replaceAll(_enhancedTag, '')
        .trim();
    if (text.isEmpty) continue;
    for (final match in matches) {
      entries.add(_LrcEntry(_timeMs(match), text, i));
    }
  }
  return entries;
}

int _timeMs(RegExpMatch match) {
  final minutes = int.parse(match.group(1)!);
  final seconds = int.parse(match.group(2)!);
  final fraction = match.group(3) ?? '0';
  final millis = switch (fraction.length) {
    1 => int.parse(fraction) * 100,
    2 => int.parse(fraction) * 10,
    _ => int.parse(fraction.substring(0, 3)),
  };
  return minutes * 60000 + seconds * 1000 + millis;
}

class _LrcEntry {
  const _LrcEntry(this.timeMs, this.text, this.sourceLine);

  final int timeMs;
  final String text;
  final int sourceLine;
}

class _LrcLine {
  _LrcLine(this.timeMs, this.text, this.sequence);

  final int timeMs;
  final String text;
  final int sequence;
  String? translated;
}
