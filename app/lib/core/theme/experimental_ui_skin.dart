import 'package:overtone/l10n/l10n.dart';

/// 全站实验性 UI 皮肤类型。
enum ExperimentalUiSkin {
  off,
  swiss,
  magi,
  evaBlue,
  skeuo;

  String get label => switch (this) {
        off => l10n.moRen,
        swiss => l10n.ruiShiGuoJiPaiBan,
        magi => l10n.evaHong,
        evaBlue => l10n.evaLan,
        // 新增皮肤没有对应 l10n 词条：按约定直接写中文常量，避免动生成文件。
        skeuo => '拟物浮光',
      };

  String get desc => switch (this) {
        off => l10n.biaoZhunShenQianZiShiYingYangShi,
        swiss => l10n.zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ,
        magi => l10n.evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS,
        evaBlue => l10n.evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie,
        skeuo => '浮起的卡片、毛玻璃播放条与 Dock、封面光晕，纯装饰分支',
      };

  /// EVA 家族（红/蓝）共用同一套版式与组件，只换调色板。
  bool get isEva => this == ExperimentalUiSkin.magi || this == evaBlue;

  /// 拟物浮光：在默认皮肤的排版与配色之上，只叠加浮起/毛玻璃/光晕装饰。
  bool get isSkeuo => this == ExperimentalUiSkin.skeuo;

  /// 是否走「档案终端」那套硬边皮肤（瑞士排版与 EVA 家族）。
  /// 拟物浮光刻意排除在外：它沿用默认皮肤骨架，不接管硬边版式。
  bool get isArchiveStyle =>
      this != ExperimentalUiSkin.off && this != ExperimentalUiSkin.skeuo;

  static ExperimentalUiSkin fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ExperimentalUiSkin.off;
    for (final skin in ExperimentalUiSkin.values) {
      if (skin.name == wire) return skin;
    }
    if (wire == 'default') return ExperimentalUiSkin.off;
    return ExperimentalUiSkin.off;
  }
}
