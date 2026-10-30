import 'package:flutter/material.dart';

import '../../core/theme/overtone_theme.dart';
import '../../features/settings/settings_controller.dart';
import 'package:overtone/l10n/l10n.dart';

/// What the user picked in the desktop close prompt, plus whether they asked us
/// to stop prompting (`记住我的选择`).
class CloseBehaviorChoice {
  const CloseBehaviorChoice(this.behavior, {this.remember = false});

  final CloseBehavior behavior;
  final bool remember;
}

CloseBehavior safeCloseBehavior(CloseBehavior requested, bool trayAvailable) =>
    requested == CloseBehavior.tray && !trayAvailable
    ? CloseBehavior.ask
    : requested;

/// Desktop close prompt: 退出应用 / 最小化到托盘, with an optional「记住我的选择」.
///
/// Returns `null` when the user cancels (or dismisses by clicking the barrier) —
/// the caller must then leave the window open. Shown from `DesktopShell`, which
/// has no `BuildContext`; it supplies the root navigator's context.
Future<CloseBehaviorChoice?> showCloseBehaviorDialog(
  BuildContext context, {
  bool trayAvailable = true,
}) {
  var remember = false;
  return showDialog<CloseBehaviorChoice>(
    context: context,
    builder: (dialogContext) {
      final theme = OvertoneTheme.of(dialogContext);
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:  Text(context.l10n.guanBiFanYin),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trayAvailable
                    ? context.l10n.tuiChuYingYongHaiShiZuiXiaoHuaDaoXiTongTuoPanJiX
                    : context.l10n.dangQianZhuoMianMeiYouKeYongDeXiTongTuoPanTuiChu,
                style: theme.body,
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                value: remember,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(() => remember = v ?? false),
                title: Text(context.l10n.jiZhuWoDeXuanZe, style: theme.body),
                subtitle: Text(context.l10n.xiaCiGuanBiBuZaiXunWenKeZaiSheZhiZhongXiuGai, style: theme.caption),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child:  Text(context.l10n.quXiao),
            ),
            if (trayAvailable)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(
                  CloseBehaviorChoice(CloseBehavior.tray, remember: remember),
                ),
                child:  Text(context.l10n.zuiXiaoHuaDaoTuoPan),
              ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                CloseBehaviorChoice(CloseBehavior.quit, remember: remember),
              ),
              child:  Text(context.l10n.tuiChuYingYong),
            ),
          ],
        ),
      );
    },
  );
}
