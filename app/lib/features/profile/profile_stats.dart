/// Formatting helpers for the profile identity card (EchoMusic `profileStats.ts`).
library;

import 'package:overtone/l10n/l10n.dart';

int? _nonNegativeNum(Object? value) {
  if (value == null || value == '' || value is bool) return null;
  final n = value is num ? value : num.tryParse(value.toString());
  if (n == null || !n.isFinite || n < 0) return null;
  return n.floor();
}

/// 累计听歌：优先秒（`d_sec`），否则分钟（`duration`）×60。
String formatListeningDuration(Object? seconds, [Object? minutes]) {
  final value =
      _nonNegativeNum(seconds) ?? (_nonNegativeNum(minutes) ?? 0) * 60;
  final total = value;
  if (total < 60) return l10n.miao(total);
  final days = total ~/ 86400;
  final hours = (total % 86400) ~/ 3600;
  final remainingMinutes = (total % 3600) ~/ 60;
  final parts = <String>[
    if (days > 0) l10n.tian(days),
    if (hours > 0) l10n.xiaoShi(hours),
    if (remainingMinutes > 0) l10n.fenZhong(remainingMinutes),
  ];
  return parts.isEmpty ? l10n.buZu1FenZhong : parts.join(' ');
}

/// 注册时间 Unix 秒 → 乐龄。按本地日历算完整月份，月末对齐到目标月最后一天。
String formatAccountAge(Object? timestamp, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final seconds = _nonNegativeNum(timestamp);
  if (seconds == null || seconds <= 0) return l10n.weiZhi;
  final start = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  if (start.isAfter(clock)) return l10n.weiZhi;

  // 投影到 UTC 日历日，避免夏令时导致一天不足 24 小时。
  DateTime utcDate(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day);
  final today = utcDate(clock);
  final startUtc = utcDate(start);

  DateTime anniversary(int months) {
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month + months,
      1,
    );
    final lastDay = DateTime.utc(
      first.year,
      first.month + 1,
      0,
    ).day;
    return DateTime.utc(
      first.year,
      first.month,
      startUtc.day < lastDay ? startUtc.day : lastDay,
    );
  }

  var months =
      (clock.year - start.year) * 12 + clock.month - start.month;
  if (anniversary(months).isAfter(today)) months -= 1;
  if (months < 0) months = 0;

  final years = months ~/ 12;
  final days = today.difference(anniversary(months)).inDays.round();
  final parts = <String>[
    if (years > 0) l10n.nian(years),
    if (months % 12 > 0) l10n.geYue(months % 12),
    if (days > 0) l10n.tian(days),
  ];
  return parts.isEmpty ? l10n.buZu1Tian : parts.join(' ');
}

class GradeProgress {
  const GradeProgress({
    this.grade,
    this.current,
    this.nextGrade,
    this.target,
    this.available = false,
    this.remaining,
    this.percent = 0,
  });

  final int? grade;
  final int? current;
  final int? nextGrade;
  final int? target;
  final bool available;
  final int? remaining;
  final double percent;

  String get gradeLabel => grade == null ? '—' : 'Lv.$grade';
}

GradeProgress getGradeProgress(Map<String, Object?> detail) {
  final grade = _nonNegativeNum(detail['p_grade']);
  final current = _nonNegativeNum(detail['p_current_point']);
  final nextGrade = _nonNegativeNum(detail['p_next_grade']);
  final target = _nonNegativeNum(detail['p_next_grade_point']);

  int? remaining;
  double percent = 0;
  var available = false;
  if (grade != null &&
      current != null &&
      nextGrade != null &&
      nextGrade > grade &&
      target != null &&
      target > 0) {
    available = true;
    remaining = (target - current).clamp(0, target);
    percent = ((current / target) * 100).clamp(0, 100).toDouble();
  }

  return GradeProgress(
    grade: grade,
    current: current,
    nextGrade: nextGrade,
    target: target,
    available: available,
    remaining: remaining,
    percent: percent,
  );
}

/// 「男 / 女 / 保密」— 与 Echo `gender` computed 一致。
String formatGender(Object? value) {
  final g = value is num ? value.toInt() : int.tryParse('${value ?? ''}');
  if (g == 1) return l10n.nan;
  if (g == 0) return l10n.nv;
  return l10n.baoMi;
}

/// KuGou VIP timestamps are `yyyy-MM-dd HH:mm:ss` (space, not `T`).
DateTime? parseKugouDateTime(Object? value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty || raw == '0') return null;
  final asInt = int.tryParse(raw);
  if (asInt != null) {
    return DateTime.fromMillisecondsSinceEpoch(
      raw.length <= 10 ? asInt * 1000 : asInt,
    );
  }
  return DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

/// VIP 到期提示（Echo `getVipExpireText`）。
String? formatVipExpireText(Object? vipEndTime, {DateTime? now}) {
  if (vipEndTime == null) return null;
  final raw = vipEndTime.toString().trim();
  if (raw.isEmpty || raw == '0') return null;
  final clock = now ?? DateTime.now();
  final expire = parseKugouDateTime(raw);
  if (expire == null) return null;
  final diff = expire.difference(clock);
  if (diff.isNegative) return l10n.yiGuoQi;
  final totalMinutes = diff.inMinutes;
  final totalHours = diff.inHours;
  final days = diff.inDays;
  if (days > 365) return l10n.nianHouDaoQi(days ~/ 365);
  if (days > 30) return l10n.geYueHouDaoQi(days ~/ 30);
  if (days > 0) return l10n.tianHouDaoQi(days);
  if (totalHours > 0) return l10n.xiaoShiHouDaoQi(totalHours);
  if (totalMinutes > 0) return l10n.fenZhongHouDaoQi(totalMinutes);
  return l10n.jiJiangDaoQi;
}

String formatVipDate(Object? value) {
  if (value == null) return '--';
  final raw = value.toString().trim();
  if (raw.isEmpty || raw == '0') return '--';
  final d = parseKugouDateTime(raw);
  if (d == null) return raw;
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${pad(d.month)}-${pad(d.day)} ${pad(d.hour)}:${pad(d.minute)}';
}
