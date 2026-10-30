import 'package:overtone/l10n/l10n.dart';

/// 私人 FM「电台」模式（红心 / 小众 / 速览）。
///
/// 三个档位都走酷狗真实私人 FM 接口 `/v2/personal_recommend`
/// （KuGouMusicApi `module/personal_fm.js`），只是请求参数不同：
/// [modeParam] → 接口 `mode`（normal/small/peak）。
///
/// 注意：接口的 `song_pool_id`（口味/风格/探索）属于**另一条轴**，
/// 见 [FmSongPool.poolId]，不要塞到这里来。
enum FmMode { heart, niche, peek }

extension FmModeX on FmMode {
  /// 分段按钮 / chip 上的短标签。
  String get label => switch (this) {
        FmMode.heart => l10n.hongXin,
        FmMode.niche => l10n.xiaoZhong,
        FmMode.peek => l10n.suLan,
      };

  /// 电台标题，如「红心电台」。
  String get stationTitle => switch (this) {
        FmMode.heart => l10n.hongXinDianTai,
        FmMode.niche => l10n.xiaoZhongDianTai,
        FmMode.peek => l10n.suLanDianTai,
      };

  /// 副标题（一句话描述这个电台的口味）。
  String get subtitle => switch (this) {
        FmMode.heart => l10n.caiNiXiHuan,
        FmMode.niche => l10n.xiaoZhongJingXuan,
        FmMode.peek => l10n.duanQuSuLan,
      };

  /// 真实接口的 `mode` 参数。
  String get modeParam => switch (this) {
        FmMode.heart => 'normal',
        FmMode.niche => 'small',
        FmMode.peek => 'peak',
      };

  /// 是否偏好短曲（用于本地时长过滤：peek 速览只留短歌）。
  bool get preferShort => this == FmMode.peek;
}

/// 私人 FM 的「口味池」维度，与 [FmMode] **正交**。
///
/// - 真实接口：本轴就是接口的 `song_pool_id`，上游代号
///   0=Alpha / 1=Beta / 2=Gamma（KuGouMusicApi 文档原文：
///   "0：Alpha 根据口味推荐相似歌曲, 1：Beta 根据风格推荐相似歌曲, 2：Gamma"）。
///   UI 直接用这三个代号，见 [label]。
/// - 兜底（关键词池）模式：没有服务端含义，只是一组搜索关键词，以及
///   「为什么是这首歌」那一行的诚实文案。
enum FmSongPool { taste, style, explore }

extension FmSongPoolX on FmSongPool {
  /// 上游原文代号，直接用原名，不做二次翻译。
  String get label => switch (this) {
        FmSongPool.taste => 'Alpha',
        FmSongPool.style => 'Beta',
        FmSongPool.explore => 'Gamma',
      };

  /// 上游对这三个码的说明（Gamma 上游未给语义，如实留空）。
  String get semantic => switch (this) {
        FmSongPool.taste => l10n.genJuKouWeiTuiJianXiangSiGeQu,
        FmSongPool.style => l10n.genJuFengGeTuiJianXiangSiGeQu,
        FmSongPool.explore => '',
      };

  /// 真实接口的 `song_pool_id`。
  int get poolId => switch (this) {
        FmSongPool.taste => 0,
        FmSongPool.style => 1,
        FmSongPool.explore => 2,
      };

  /// 并入本池候选集的关键词束。
  List<String> get keywords => switch (this) {
        FmSongPool.taste =>  [l10n.reMen, l10n.huaYuLiuXing, l10n.jingDian],
        FmSongPool.style =>  [l10n.minYao, l10n.dianZi, l10n.qingYinYue],
        FmSongPool.explore =>  [l10n.duLi, l10n.lengMen, l10n.jueShi],
      };

  /// 「为什么是这首歌」的诚实一行说明（与旧 personal_fm_page.dart 一致）。
  String get reasonLabel => switch (this) {
        FmSongPool.taste => l10n.laiZiReMenHuaYuLiuXing,
        FmSongPool.style => l10n.laiZiMinYaoDianZi,
        FmSongPool.explore => l10n.laiZiDuLiJueShi,
      };

  /// 按电台档位微调关键词：小众档换成更“小众”的词，速览/红心用原词。
  List<String> keywordsFor(FmMode mode) => switch (mode) {
        FmMode.heart => keywords,
        FmMode.niche =>  [l10n.xiaoZhong, l10n.duLi, l10n.lengMen, l10n.diXia, l10n.baoZang],
        FmMode.peek => keywords,
      };
}
