import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';
import '../../core/diagnostics/crash_log.dart';
import '../../core/platform.dart';
import '../../core/source/features.dart';
import '../../core/source/music_platform.dart';
import '../../core/source/registry.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/netease_login_controller.dart';
import '../../features/auth/bili_login_controller.dart';
import '../../features/debug/crash_log_dialog.dart';
import '../../features/debug/network_log_dialog.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/responsive.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../../shared/widgets/settings_pickers.dart';
import '../../shared/widgets/desktop_lyric_style_sheet.dart';
import '../../shared/widgets/smooth_scroll.dart';
import '../desktop_lyric/android_overlay/android_overlay_bridge.dart';
import '../desktop_lyric/android_overlay/android_overlay_host.dart';
import '../desktop_lyric/desktop_lyric_bridge.dart';
import '../profile/source_account.dart';
import 'settings_controller.dart';
import 'package:overtone/l10n/l10n.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = OvertoneTheme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final netease = ref.watch(neteaseLoginControllerProvider);
    final bili = ref.watch(biliLoginControllerProvider);

    return ArchivePageScaffold(
      appBar: AppBar(title:  Text(context.l10n.sheZhi)),
      body: DesktopContentConstraint.form(
        // 桌面滚轮平滑：与发现页 / 我的 / 历史等页同源（SilkyScroll）。
        // 原来是裸 ListView，桌面滚轮会显得「一格一格跳」。
        child: SmoothListView(
          padding: const EdgeInsets.fromLTRB(
            OvertoneSpacing.lg,
            OvertoneSpacing.lg,
            OvertoneSpacing.lg,
            40,
          ),
          children: [
            _Section(
              title: context.l10n.waiGuan,
              children: [
                _ThemeModeTile(
                  mode: AppThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: context.l10n.shenSe,
                  subtitle: context.l10n.gaiNianBanMoRenShenSe,
                  selected: settings.themeMode == AppThemeMode.dark,
                  onTap: () => controller.setThemeMode(AppThemeMode.dark),
                ),
                _ThemeModeTile(
                  mode: AppThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: context.l10n.qianSe,
                  subtitle: context.l10n.qianSeWanZhengShiPei,
                  selected: settings.themeMode == AppThemeMode.light,
                  onTap: () => controller.setThemeMode(AppThemeMode.light),
                ),
                _ThemeModeTile(
                  mode: AppThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  title: context.l10n.genSuiXiTong,
                  subtitle: context.l10n.suiXiTongShenQianSeQieHuan,
                  selected: settings.themeMode == AppThemeMode.system,
                  onTap: () => controller.setThemeMode(AppThemeMode.system),
                ),
                _AccentTile(
                  accent: settings.accent,
                  onChanged: controller.setAccent,
                ),
                ListTile(
                  title: Text(context.l10n.shiYanUi, style: theme.body),
                  subtitle: Text(
                    settings.experimentalUi.label,
                    style: theme.caption,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (settings.experimentalUi != ExperimentalUiSkin.off) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            settings.experimentalUi.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () => showExperimentalUiPicker(context, ref),
                ),
              ],
            ),
            if (isDesktopPlatform)
              _Section(
                title: context.l10n.chuangKou,
                children: [
                  ListTile(
                    title: Text(context.l10n.guanBiZhuChuangKouShi, style: theme.body),
                    subtitle: Text(
                      settings.closeBehavior.closeHint,
                      style: theme.caption,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showCloseBehaviorPicker(context, ref),
                  ),
                  if (isWindowsPlatform)
                    SwitchListTile(
                      title: Text(context.l10n.renWuLanBoFangJinDu, style: theme.body),
                      subtitle: Text(
                        context.l10n.zaiRenWuLanAnNiuShangXianShiBoFangJinDuBoFangLvZ,
                        style: theme.caption,
                      ),
                      value: settings.taskbarProgress,
                      onChanged: controller.setTaskbarProgress,
                    ),
                  if (isWindowsPlatform)
                    SwitchListTile(
                      title: Text(context.l10n.renWuLanFengMianYuLan, style: theme.body),
                      subtitle: Text(
                        context.l10n.xuanTingHeChuangKouQieHuanXianShiFengMianXinXiKa,
                        style: theme.caption,
                      ),
                      value: settings.taskbarCoverPreview,
                      onChanged: controller.setTaskbarCoverPreview,
                    ),
                  if (isWindowsPlatform)
                    SwitchListTile(
                      title: Text(context.l10n.duLiBoKongHengTiao, style: theme.body),
                      subtitle: Text(
                        context.l10n.renWuLanShangFangFuTiaoKeTuoDongTuoJinDuHeDiaoYi,
                        style: theme.caption,
                      ),
                      value: settings.taskbarMediaBar,
                      onChanged: controller.setTaskbarMediaBar,
                    ),
                ],
              ),
            if (supportsDesktopLyrics || isAndroidPlatform)
              _Section(
                title: context.l10n.zhuoMianGeCi,
                children: [
                  SwitchListTile(
                    title: Text(
                      isAndroidPlatform
                          ? context.l10n.xianShiXuanFuGeCi
                          : context.l10n.xianShiZhuoMianGeCi,
                      style: theme.body,
                    ),
                    subtitle: Text(
                      isAndroidPlatform
                          ? context.l10n.xuanFuChuangXianShiDangQianGeCiKeTuoDongSuoDingD
                          : isLinuxPlatform
                          ? context.l10n.x11DuLiGeCiChuangKeTuoDongHeSuoDingChuanTouWuHeC
                          : (kAutoRestoreDesktopLyric
                                ? context.l10n.duLiXuanFuChuangXianShiDangQianGeCiKeZhiDingSuoD
                                : context.l10n.duLiXuanFuChuangXianShiDangQianGeCiShiYanGon),
                      style: theme.caption,
                    ),
                    value: settings.desktopLyricEnabled,
                    onChanged: (v) async {
                      // 经 Bridge 真正开/关窗口；成功后 Bridge 回写设置。
                      if (isAndroidPlatform) {
                        final bridge = ref.read(androidLyricBridgeProvider);
                        if (v) {
                          final ok = await bridge.open();
                          if (!ok && context.mounted) {
                            final granted = await _requestOverlayPermission(
                              context,
                              bridge,
                            );
                            if (!granted && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                  content: Text(context.l10n.xuYaoXianShiZaiQiTaYingYongShangCengQuanXianCaiN),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else if (granted) {
                              await bridge.open();
                            }
                          }
                        } else {
                          await bridge.close();
                        }
                      } else {
                        final bridge = ref.read(desktopLyricBridgeProvider);
                        if (v) {
                          bridge.open();
                        } else {
                          bridge.close();
                        }
                      }
                    },
                  ),
                  SwitchListTile(
                    title: Text(context.l10n.suoDingGeCiChuang, style: theme.body),
                    subtitle: Text(
                      isAndroidPlatform
                          ? context.l10n.suoDingHouDianJiChuanTouDaoXiaCengYingYongBiMian
                          : context.l10n.dianJiChuanTouDaoXiaCengYingYongBiMianDangZhuCao,
                      style: theme.caption,
                    ),
                    value: settings.desktopLyricLocked,
                    onChanged: settings.desktopLyricEnabled
                        ? controller.setDesktopLyricLocked
                        : null,
                  ),
                  ListTile(
                    title: Text(context.l10n.geCiYangShi, style: theme.body),
                    subtitle: Text(
                      settings.desktopLyricStyle.matchingPreset?.name ?? context.l10n.ziDingYi,
                      style: theme.caption,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showDesktopLyricStyleSheet(context, ref),
                  ),
                  ListTile(
                    title: Text(context.l10n.geCiPianYiQuanJu, style: theme.body),
                    subtitle: Text(
                      settings.lyricOffsetMs == 0
                          ? context.l10n.yuXiTongShiJianDuiQiBoFangYeGeCiXianShiLiKeAnDan
                          : context.l10n.sQuanJuAnGeQuDeWeiTiaoHuiZaiDieJia(settings.lyricOffsetMs > 0 ? '+' : '', (settings.lyricOffsetMs / 1000).toStringAsFixed(1)),
                      style: theme.caption,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: context.l10n.tiQian05s,
                          icon: const Icon(Icons.remove_rounded, size: 20),
                          onPressed: () => controller.setLyricOffsetMs(
                            settings.lyricOffsetMs - 500,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.yanHou05s,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          onPressed: () => controller.setLyricOffsetMs(
                            settings.lyricOffsetMs + 500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => controller.setLyricOffsetMs(0),
                  ),
                  ListTile(
                    title: Text(context.l10n.chongZhiGeCiWeiZhi, style: theme.body),
                    subtitle: Text(
                      isAndroidPlatform
                          ? context.l10n.huiDaoPingMuDingBuJuZhongSimple
                          : context.l10n.huiDaoPingMuDingBuJuZhongLiDingDuan12px,
                      style: theme.caption,
                    ),
                    trailing: const Icon(Icons.my_location_rounded),
                    onTap: () async {
                      if (isAndroidPlatform) {
                        await ref
                            .read(androidLyricBridgeProvider)
                            .resetPosition();
                      } else {
                        ref.read(desktopLyricBridgeProvider).resetPosition();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text(context.l10n.geCiWeiZhiYiChongZhiWeiDingBuJuZhong),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            _Section(
              title: context.l10n.boFang,
              children: [
                ListTile(
                  title: Text(context.l10n.moRenYinZhi, style: theme.body),
                  subtitle: Text(
                    context.l10n.xinGeMoRenAnCiJieXiBoFangZhongKeQieHuan(settings.qualityLabel),
                    style: theme.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showQualityPicker(context, ref),
                ),
                ListTile(
                  title: Text(context.l10n.dingShiTingZhi, style: theme.body),
                  subtitle: Text(
                    settings.sleepMinutes == 0
                        ? context.l10n.guanBi
                        : context.l10n.fenZhong(settings.sleepMinutes),
                    style: theme.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showSleepPicker(context, ref),
                ),
                SwitchListTile(
                  title: Text(context.l10n.shiBaiShiChangShiMvYinPin, style: theme.body),
                  subtitle: Text(
                    context.l10n.yinYuanBuKeYongShiJieYongGeQuGuanLianQuKuMvDeYin,
                    style: theme.caption,
                  ),
                  value: settings.mvAudioFallbackEnabled,
                  onChanged: controller.setMvAudioFallbackEnabled,
                ),
              ],
            ),
            _Section(
              title: context.l10n.geCiYuFengMian,
              children: [
                // 翻译 / 罗马音：播放页 VIP/HQ 旁「歌词显示」入口（lyric_display_sheet）。
                SwitchListTile(
                  title: Text(context.l10n.suoPingLanYaXianShiGeCi, style: theme.body),
                  subtitle: Text(context.l10n.xiTongMeiTiFuBiaoTiXianShiGeShouDangQianGeCi, style: theme.caption),
                  value: settings.mediaLyricSubtitle,
                  onChanged: controller.setMediaLyricSubtitle,
                ),
                SwitchListTile(
                  title: Text(context.l10n.jinWiFiJiaZaiFengMian, style: theme.body),
                  value: settings.wifiCoverOnly,
                  onChanged: controller.setWifiCoverOnly,
                ),
              ],
            ),
            _Section(
              title: context.l10n.zhangHaoGuanLi,
              children: [
                ListTile(
                  leading: Icon(Icons.hub_outlined, color: theme.textSecondary),
                  title: Text(context.l10n.moRenYinYuan, style: theme.body),
                  subtitle: Text(
                    context.l10n.souSuoYuWoXiHuanDeChuShiYinYuan(settings.defaultSourceLabel),
                    style: theme.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showDefaultSourcePicker(context, ref),
                ),
                // 两级开关：整源（父）→ 该源的入口功能（子）。只列已注册的源；
                // 最后一个源不可关（至少保留一个）；网易云需登录才可启用（未登录
                // 置灰）。关掉父开关时子项置灰但**保留取值**，重新开启即恢复。
                for (final p in _enabledPlatformRows(
                  settings,
                  netease.isLogged,
                ))
                  ..._sourceSwitchTiles(
                    settings: settings,
                    controller: controller,
                    theme: theme,
                    platform: p.$1,
                    canToggle: p.$2,
                    locked: p.$3,
                  ),
                // 酷狗 / 网易云各一行。两个源的登录态互不影响（可只登其一），
                // 但同一源只保留一个当前账号——再登即顶替，故按钮是「切换账号」。
                _AccountTile(
                  icon: Icons.headset_rounded,
                  platform: MusicPlatform.kugou.label,
                  nickname: auth.isLogged ? (auth.user?.nickname ?? '') : '',
                  guestHint: context.l10n.youKeMoShiShuJuJinCunBenJi,
                  onLogin: () => context.push('/login'),
                  // 已登录才给退出口；二次确认与退出动作为公共 helper
                  // （与「个人中心」页尾入口同一口径，见 source_account.dart）。
                  onLogout: auth.isLogged
                      ? () => confirmAndLogoutSource(
                          context,
                          ref,
                          MusicPlatform.kugou,
                        )
                      : null,
                ),
                _AccountTile(
                  icon: Icons.cloud_rounded,
                  platform: MusicPlatform.netease.label,
                  nickname: netease.isLogged ? netease.account!.nickname : '',
                  guestHint: context.l10n.saoMaDengLuHouKeTongBuGeDanYuBoFangQuanXian,
                  // 已登录时带 relogin，进页直接出新码顶替旧账号。
                  onLogin: () => context.push(
                    netease.isLogged
                        ? '/netease-login?relogin=1'
                        : '/netease-login',
                  ),
                  onLogout: netease.isLogged
                      ? () => confirmAndLogoutSource(
                          context,
                          ref,
                          MusicPlatform.netease,
                        )
                      : null,
                ),
                _AccountTile(
                  icon: Icons.video_library_rounded,
                  platform: MusicPlatform.bili.label,
                  nickname: bili.account?.nickname ?? '',
                  guestHint: context.l10n.youKeKeBoFangDengLuHouDuQuShouCangJia,
                  onLogin: () => context.push(
                    bili.isLogged ? '/bili-login?relogin=1' : '/bili-login',
                  ),
                  onLogout: bili.isLogged
                      ? () => confirmAndLogoutSource(
                          context,
                          ref,
                          MusicPlatform.bili,
                        )
                      : null,
                ),
              ],
            ),
            _Section(
              title: context.l10n.tiaoShi,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.bug_report_outlined,
                    color: theme.textSecondary,
                  ),
                  title: Text(context.l10n.wangLuoQingQiuRiZhi, style: theme.body),
                  subtitle: Text(
                    context.l10n.qingQiuXiangYingCuoWuCeShiWangLuoShiShiTanCeFuZh,
                    style: theme.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showNetworkLogDialog(context),
                ),
                const _CrashLogEntry(),
              ],
            ),
            _Section(
              title: context.l10n.huanCun,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.cleaning_services_outlined,
                    color: theme.textSecondary,
                  ),
                  title: Text(context.l10n.qingLiTuPianHuanCunYuBoFangSouSuoLiShi, style: theme.body),
                  subtitle: Text(context.l10n.buYingXiangDengLuYuWoXiHuanDuiLieBenDiFuBenHuiYi, style: theme.caption),
                  onTap: () async {
                    final msg = await controller.clearImageAndHistoryCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  },
                ),
              ],
            ),
            _Section(
              title: context.l10n.yuYan,
              children: [
                ListTile(
                  leading: Icon(Icons.translate_rounded,
                      color: theme.textSecondary),
                  title: Text(context.l10n.jieMianYuYan, style: theme.body),
                  subtitle: Text(settings.language.label, style: theme.caption),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLanguagePicker(context, ref),
                ),
              ],
            ),
            _Section(
              title: context.l10n.guanYu,
              children: [
                ListTile(
                  title: Text(context.l10n.fanYin, style: theme.body),
                  subtitle: Text(
                    context.l10n.xueXiYanJiuXiangDiSanFangKeHuDuanBuTiGongYin(AppInfo.versionLabel),
                    style: theme.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 整源开关的行数据：`(平台, 是否可关闭, 是否被登录门槛锁住)`。
  ///
  /// 只列 registry 里已注册的源（没注册的源开关无意义）；enabledSources
  /// 里只剩它自己时禁止关闭——空集合会让 App 没有任何可用音源。
  /// 网易云需登录才可启用：未登录时该行置灰（见 [SettingsController.setNeteaseAccess]）。
  List<(MusicPlatform, bool, bool)> _enabledPlatformRows(
    AppSettings settings,
    bool neteaseLogged,
  ) {
    final registered =
        musicSourceRegistry?.platforms.toList() ?? const [MusicPlatform.kugou];
    return [
      for (final p in registered)
        (
          p,
          settings.enabledSources.length > 1 ||
              !settings.enabledSources.contains(p),
          p == MusicPlatform.netease && !neteaseLogged,
        ),
    ];
  }
}

/// 一个源的两级开关：父（整源）+ 子（该源支持的入口功能）。
///
/// 子项只列该源**真的具备能力**的功能——列了也只能点出空态，是假入口。
/// 父开关关闭时子项传 `onChanged: null`，由 Flutter 自带置灰效果；取值
/// **不重置**（`disabledFeatures` 保持原样），重新开启父开关即恢复原配置。
///
/// [locked]：该源被登录门槛锁住（当前只有网易云）。未登录时父开关显示为关、
/// 置灰、副标题提示登录，即便 `enabledSources` 里还残留它也不显示为开。
List<Widget> _sourceSwitchTiles({
  required AppSettings settings,
  required SettingsController controller,
  required OvertoneTheme theme,
  required MusicPlatform platform,
  required bool canToggle,
  required bool locked,
}) {
  final enabled = settings.enabledSources.contains(platform) && !locked;
  final registry = musicSourceRegistry;
  return [
    SwitchListTile(
      secondary: Icon(
        Icons.power_settings_new_rounded,
        color: theme.textSecondary,
      ),
      title: Text(l10n.qiYongYinYuan(platform.label), style: theme.body),
      subtitle: Text(
        locked
            ? l10n.dengLuHouKeQiYong(platform.label)
            : (canToggle
                ? l10n.guanBiHouSouSuoYuGongNengYeBuZaiShiYongGaiYuan
                : l10n.zuiHouYiGeYinYuanZhiShaoBaoLiuYiGe),
        style: theme.caption,
      ),
      value: enabled,
      onChanged: (canToggle && !locked)
          ? (v) => controller.setEnabledSources(
              v
                  ? {...settings.enabledSources, platform}
                  // 级联会绑定整个条件表达式
                  //（`a ? b : c..d` = `(a ? b : c)..d`），
                  // 必须括起来，否则启用分支加了源又被
                  // remove 抵消（关闭后无法再启用）。
                  : ({...settings.enabledSources}..remove(platform)),
            )
          : null,
    ),
    for (final f in SourceFeature.values)
      if (f.supportedBy(registry, platform))
        SwitchListTile(
          key: ValueKey('feature_switch_${platform.wireName}_${f.id}'),
          dense: true,
          contentPadding: const EdgeInsets.only(left: 44, right: 16),
          title: Text(f.label, style: theme.body),
          subtitle: Text(
            locked
                ? l10n.dengLuHouKeQiYong(platform.label)
                : (enabled
                      ? (f == SourceFeature.cloud
                            // 云盘页本身就是入口，「不再出现在入口」读不通。
                            ? l10n.guanBiHouYinCangYinYueYunPanRuKouYuGaiYuanYunPan
                            : l10n.guanBiHouGaiYuanBuZaiChuXianZaiRuKou(f.label))
                      : l10n.yinYuanYiGuanBiCiXiangZanShiBuShengXiao(platform.label)),
            style: theme.caption,
          ),
          value: settings.isFeatureOn(platform, f),
          onChanged: enabled
              ? (v) => controller.setFeatureEnabled(platform, f, v)
              : null,
        ),
  ];
}

/// 「账号管理」里的一行：平台名 + 当前状态 + 行内显式按钮。
///
/// 旧版酷狗是「点整行即退出」的隐式交互，容易误触（退出会掉云端数据），
/// 故统一改为显式按钮，并与网易云保持同构。
class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.platform,
    required this.nickname,
    required this.guestHint,
    required this.onLogin,
    this.onLogout,
  });

  final IconData icon;
  final String platform;

  /// 非空即已登录，直接显示昵称。
  final String nickname;

  /// 未登录时的状态说明。
  final String guestHint;

  /// 「去登录」；已登录时同一按钮变成「切换账号」。
  final VoidCallback onLogin;

  /// 「退出登录」；未登录为 null（不显示该按钮）。
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final logged = nickname.isNotEmpty;
    final logout = onLogout;
    return ListTile(
      leading: Icon(icon, color: theme.textSecondary),
      title: Text(platform, style: theme.body),
      subtitle: Text(
        logged ? l10n.yiDengLuWithName(nickname) : guestHint,
        style: theme.caption,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onLogin,
            style: _tileActionStyle,
            child: Text(logged ? context.l10n.qieHuanZhangHao : context.l10n.quDengLu),
          ),
          if (logout != null)
            TextButton(
              onPressed: logout,
              style: _tileActionStyle,
              child:  Text(context.l10n.tuiChuDengLu),
            ),
        ],
      ),
    );
  }
}

/// 两个按钮要挤进一个 ListTile，收紧内边距与点击热区免得撑破标题。
final ButtonStyle _tileActionStyle = TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  minimumSize: const Size(0, 32),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

/// 跳系统「显示在其他应用上层」授权页，返回后轮询一次是否已授权。
Future<bool> _requestOverlayPermission(
  BuildContext context,
  AndroidLyricBridge bridge,
) async {
  final granted = await bridge.requestPermission();
  if (granted) return true;
  // 从系统设置返回后给一拍再查（部分 ROM 回调不是同步的）。
  await Future<void>.delayed(const Duration(milliseconds: 400));
  return AndroidOverlayHost.canDrawOverlays();
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    if (archive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              4,
              OvertoneSpacing.lg,
              0,
              OvertoneSpacing.sm,
            ),
            child: ArchiveSectionLabel(title),
          ),
          Material(
            color: theme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: ArchiveChrome.lineStrong(theme)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 1,
                      color: ArchiveChrome.lineStrong(theme),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            OvertoneSpacing.lg,
            0,
            OvertoneSpacing.sm,
          ),
          child: Text(title, style: theme.section.copyWith(fontSize: 15)),
        ),
        // Material so the ListTiles inside keep their ink splashes.
        Material(
          color: theme.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(OvertoneRadius.card),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// 主题色（强调色）选择：四个色卡，选中态加描边 + 勾。
class _AccentTile extends StatelessWidget {
  const _AccentTile({required this.accent, required this.onChanged});

  final OvertoneAccent accent;
  final ValueChanged<OvertoneAccent> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(Icons.palette_rounded, color: theme.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.zhuTiSe, style: theme.body),
                Text(accent.label, style: theme.caption),
              ],
            ),
          ),
          for (final option in OvertoneAccent.values)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _AccentSwatch(
                option: option,
                selected: option == accent,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final OvertoneAccent option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final color = option.primaryFor(theme.palette.brightness);
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: archive ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: archive ? BorderRadius.circular(2) : null,
            border: selected
                ? Border.all(color: theme.textPrimary, width: 2)
                : null,
          ),
          child: selected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// Theme row shared with profile's 「主题外观」 sheet — same modes, same copy.
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? theme.primary : theme.textSecondary,
      ),
      title: Text(title, style: theme.body),
      subtitle: Text(subtitle, style: theme.caption),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.primary)
          : null,
      onTap: onTap,
    );
  }
}

/// 崩溃日志入口：摘要（条数 + 最近时间）要读文件，做成独立 State 免得整页重建。
class _CrashLogEntry extends StatefulWidget {
  const _CrashLogEntry();

  @override
  State<_CrashLogEntry> createState() => _CrashLogEntryState();
}

class _CrashLogEntryState extends State<_CrashLogEntry> {
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await CrashLog.summary() ?? l10n.wu;
    if (!mounted) return;
    setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return ListTile(
      leading: Icon(Icons.error_outline, color: theme.textSecondary),
      title: Text(context.l10n.bengKuiRiZhi, style: theme.body),
      subtitle: Text(context.l10n.kuangJiaYuanShengWeiBuHuoCuoWu(_summary), style: theme.caption),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => showCrashLogDialog(context),
    );
  }
}
