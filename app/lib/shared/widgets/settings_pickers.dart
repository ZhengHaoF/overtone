import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/desktop_capabilities.dart';
import '../../core/source/music_platform.dart';
import '../../core/source/registry.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/player/player_controller.dart';
import '../../features/settings/settings_controller.dart';
import '../../l10n/app_language.dart';
import 'common.dart';
import 'package:overtone/l10n/l10n.dart';

/// Bottom-sheet pickers shared by the Settings page and the Profile shortcuts.
///
/// Kept in one place so「定时停止」/「音质设置」behave identically no matter
/// which entry the user came from — including the side effect of pushing the
/// sleep timer into the live player.

/// Pick the default audio quality. Persists to settings; takes effect on the
/// next resolve (playing tracks can still switch from the player page).
Future<void> showQualityPicker(BuildContext context, WidgetRef ref) async {
  final theme = OvertoneTheme.of(context);
  final controller = ref.read(settingsControllerProvider.notifier);
  final current = ref.read(settingsControllerProvider).quality;
  final selected = await showOvertoneBottomSheet<AppQuality>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        for (final q in AppQuality.values)
          ListTile(
            title: Text(q.label, style: theme.body),
            trailing: q == current
                ? Icon(Icons.check_rounded, color: theme.primary)
                : null,
            onTap: () => Navigator.pop(sheetContext, q),
          ),
        const SizedBox(height: 8),
      ],
    ),
  );
  if (selected != null) {
    await controller.setQuality(selected);
  }
}

/// Pick the default music source. It seeds the search page's source filter and
/// the 「我喜欢」page's source filter — both stay switchable per session.
Future<void> showDefaultSourcePicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final theme = OvertoneTheme.of(context);
  final controller = ref.read(settingsControllerProvider.notifier);
  final settings = ref.read(settingsControllerProvider);
  final current = settings.defaultSource;
  // 只列已注册且启用的源（停用的源选了也不会生效）。
  final enabled = settings.enabledSources;
  final platforms =
      musicSourceRegistry?.platforms.where(enabled.contains).toList() ??
      const [MusicPlatform.kugou];
  final selected = await showOvertoneBottomSheet<MusicPlatform>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        for (final p in platforms)
          ListTile(
            title: Text(p.label, style: theme.body),
            trailing: p == current
                ? Icon(Icons.check_rounded, color: theme.primary)
                : null,
            onTap: () => Navigator.pop(sheetContext, p),
          ),
        const SizedBox(height: 8),
      ],
    ),
  );
  if (selected != null) {
    await controller.setDefaultSource(selected);
  }
}

/// Pick the interface language. Applies immediately and persists.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) async {
  final theme = OvertoneTheme.of(context);
  final controller = ref.read(settingsControllerProvider.notifier);
  final current = ref.read(settingsControllerProvider).language;
  final selected = await showOvertoneBottomSheet<AppLanguage>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        for (final lang in AppLanguage.values)
          ListTile(
            title: Text(lang.label, style: theme.body),
            trailing: lang == current
                ? Icon(Icons.check_rounded, color: theme.primary)
                : null,
            onTap: () => Navigator.pop(sheetContext, lang),
          ),
        const SizedBox(height: 8),
      ],
    ),
  );
  if (selected != null) {
    await controller.setLanguage(selected);
  }
}

/// Pick the sleep timer. Persists the choice *and* arms the live player.
Future<void> showSleepPicker(BuildContext context, WidgetRef ref) async {
  final theme = OvertoneTheme.of(context);
  final controller = ref.read(settingsControllerProvider.notifier);
  final selected = await showOvertoneBottomSheet<SleepTimerMode>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        ListTile(
          title: Text(context.l10n.guanBi, style: theme.body),
          onTap: () => Navigator.pop(sheetContext, SleepTimerMode.off),
        ),
        ListTile(
          title: Text(context.l10n.n15FenZhong, style: theme.body),
          onTap: () => Navigator.pop(sheetContext, SleepTimerMode.m15),
        ),
        ListTile(
          title: Text(context.l10n.n30FenZhong, style: theme.body),
          onTap: () => Navigator.pop(sheetContext, SleepTimerMode.m30),
        ),
        ListTile(
          title: Text(context.l10n.n60FenZhong, style: theme.body),
          onTap: () => Navigator.pop(sheetContext, SleepTimerMode.m60),
        ),
        ListTile(
          title: Text(context.l10n.ziDingYi45FenZhong, style: theme.body),
          onTap: () => Navigator.pop(sheetContext, SleepTimerMode.custom),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
  if (selected != null) {
    await controller.setSleep(selected);
    final minutes = ref.read(settingsControllerProvider).sleepMinutes;
    ref.read(playerControllerProvider.notifier).setSleepTimer(minutes);
  }
}

/// Pick what the desktop window close button does (每次询问 / 最小化到托盘 / 退出应用).
Future<void> showCloseBehaviorPicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final theme = OvertoneTheme.of(context);
  final controller = ref.read(settingsControllerProvider.notifier);
  final current = ref.read(settingsControllerProvider).closeBehavior;
  final trayAvailable = ref.read(desktopTrayAvailableProvider);
  final selected = await showOvertoneBottomSheet<CloseBehavior>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        for (final behavior in CloseBehavior.values)
          if (behavior != CloseBehavior.tray || trayAvailable)
            ListTile(
              title: Text(behavior.label, style: theme.body),
              subtitle: Text(behavior.closeHint, style: theme.caption),
              trailing: behavior == current
                  ? Icon(Icons.check_rounded, color: theme.primary)
                  : null,
              onTap: () => Navigator.pop(sheetContext, behavior),
            ),
        const SizedBox(height: 8),
      ],
    ),
  );
  if (selected != null) {
    await controller.setCloseBehavior(selected);
  }
}

/// About sheet: version, project scope and the compliance disclaimer.
Future<void> showAboutSheet(BuildContext context) {
  return showOvertoneBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final theme = OvertoneTheme.of(sheetContext);
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          OvertoneSpacing.lg,
          12,
          OvertoneSpacing.lg,
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(context.l10n.guanYu, style: theme.section)),
            const SizedBox(height: OvertoneSpacing.md),
            _AboutRow(label: context.l10n.banBen, value: AppInfo.versionLabel),
            _AboutRow(label: context.l10n.xingTai, value: 'Android · Windows · Linux'),
            _AboutRow(label: context.l10n.dingWei, value: context.l10n.duoYinYuanDiSanFangKeHuDuan),
            const SizedBox(height: OvertoneSpacing.md),
            Text(
              context.l10n.geRenXueXiYanJiuXiangXiangMuShuJuJingGongKai,
              style: theme.caption,
            ),
            const SizedBox(height: OvertoneSpacing.md),
            Text(
              context.l10n.qingZunShouDangDiFaLvYuMuBiaoPingTaiFuWuTiaoKuan,
              style: theme.caption,
            ),
          ],
        ),
      );
    },
  );
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64, child: Text(label, style: theme.caption)),
          Expanded(child: Text(value, style: theme.body)),
        ],
      ),
    );
  }
}


/// Pick experimental UI skins (默认 / 瑞士国际排版 / ...).
Future<void> showExperimentalUiPicker(
  BuildContext context,
  WidgetRef ref,
) async {
  await showOvertoneBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _ExperimentalUiPickerSheet(),
  );
}

class _ExperimentalUiPickerSheet extends ConsumerWidget {
  const _ExperimentalUiPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = OvertoneTheme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final current = settings.experimentalUi;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          OvertoneSpacing.lg,
          16,
          OvertoneSpacing.lg,
          16 + bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.shiYanUi, style: theme.section),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.tiYanTanSuoXingSheJiFengGeYuPaiBanXiTong,
                    style: theme.caption,
                  ),
                ],
              ),
              const SizedBox(height: OvertoneSpacing.md),
              for (final skin in ExperimentalUiSkin.values)
                _ExperimentalSkinCard(
                  skin: skin,
                  isSelected: current == skin,
                  onTap: () => controller.setExperimentalUi(skin),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperimentalSkinCard extends StatelessWidget {
  const _ExperimentalSkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  final ExperimentalUiSkin skin;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final borderColor = isSelected ? theme.primary : theme.divider;
    final bgColor = isSelected
        ? theme.primary.withValues(alpha: 0.06)
        : theme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OvertoneRadius.card),
          side: BorderSide(
            color: borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: isSelected
                        ? theme.primary
                        : theme.caption.color?.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            skin.label,
                            style: theme.body.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.l10n.dangQianShiYong,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skin.desc,
                        style: theme.caption.copyWith(
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
