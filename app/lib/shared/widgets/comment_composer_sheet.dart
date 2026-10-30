import 'package:flutter/material.dart';

import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import 'common.dart';
import 'package:overtone/l10n/l10n.dart';

/// 评论输入弹层。
///
/// 返回**非空字符串** = 用户点了发送（内容已 trim）；`null` = 取消或直接关闭。
/// 只负责收集文本，不碰网络 —— 发送由调用方走 `CommentWriteSource`。
Future<String?> showCommentComposerSheet(
  BuildContext context, {
  String? hint,
  String? replyTo,
  int maxLength = 200,
}) {
  return showOvertoneBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CommentComposerBody(
      hint: hint ?? l10n.shuoShuoGuanYuZheShouGeDeGuShi,
      replyTo: replyTo,
      maxLength: maxLength,
    ),
  );
}

class _CommentComposerBody extends StatefulWidget {
  const _CommentComposerBody({
    required this.hint,
    required this.maxLength,
    this.replyTo,
  });

  final String hint;
  final int maxLength;
  final String? replyTo;

  @override
  State<_CommentComposerBody> createState() => _CommentComposerBodyState();
}

class _CommentComposerBodyState extends State<_CommentComposerBody> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    // 打开即聚焦，移动端会同时弹出键盘。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _text => _controller.text.trim();

  bool get _overLimit => _controller.text.runes.length > widget.maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    // 键盘顶起来时把内容抬上去（桌面端 viewInsets 为 0，无副作用）。
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final count = _controller.text.runes.length;
    final canSend = _text.isNotEmpty && !_overLimit;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            OvertoneSpacing.lg,
            OvertoneSpacing.sm,
            OvertoneSpacing.lg,
            OvertoneSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: OvertoneSpacing.md),
              Text(
                widget.replyTo == null
                    ? context.l10n.faBiaoPingLun
                    : context.l10n.huiFu_2(widget.replyTo ?? ''),
                style: theme.section,
              ),
              const SizedBox(height: OvertoneSpacing.sm),
              TextField(
                controller: _controller,
                focusNode: _focus,
                minLines: 3,
                maxLines: 6,
                maxLength: widget.maxLength,
                style: theme.body.copyWith(fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: theme.caption.copyWith(color: theme.textTertiary),
                  counterText: '', // 自绘计数，避免默认计数器样式与主题不一致
                  filled: true,
                  fillColor: theme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(OvertoneRadius.card),
                    borderSide: BorderSide(color: theme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(OvertoneRadius.card),
                    borderSide: BorderSide(color: theme.divider),
                  ),
                ),
              ),
              const SizedBox(height: OvertoneSpacing.sm),
              Row(
                children: [
                  Text(
                    '$count/${widget.maxLength}',
                    style: theme.caption.copyWith(
                      color: _overLimit ? theme.primary : theme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child:  Text(context.l10n.quXiao),
                  ),
                  const SizedBox(width: OvertoneSpacing.sm),
                  FilledButton(
                    onPressed: canSend
                        ? () => Navigator.of(context).pop(_text)
                        : null,
                    child:  Text(context.l10n.faSong),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
