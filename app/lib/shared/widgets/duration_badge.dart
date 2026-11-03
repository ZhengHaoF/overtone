import 'package:flutter/material.dart';

import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';

/// 覆盖在封面/视频角上的时长角标。
///
/// 替代各页面手写的「`Colors.black54` 底 + 白字」：底色走 [OvertoneTheme.onCover]
/// 语义色（封面上的浅色），文字用恒定深色，圆角统一 [OvertoneRadius.tag]。
/// 在 MAGI/浅色等皮肤下随主题语义取色，不再是固定黑底。
class DurationBadge extends StatelessWidget {
  const DurationBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.onCover.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(OvertoneRadius.tag),
      ),
      child: Text(
        label,
        style: const TextStyle(
          // 与浅色主题 textPrimary 同值的恒定深色：角标底恒为浅色，
          // 文字必须随之保持深，不能跟随主题翻转。
          color: Color(0xFF12141A),
          fontSize: OvertoneFontSize.micro,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
