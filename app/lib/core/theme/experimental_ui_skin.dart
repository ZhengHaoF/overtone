import 'package:overtone/l10n/l10n.dart';

/// 全站实验性 UI 皮肤类型。
enum ExperimentalUiSkin {
  off,
  swiss,
  magi,
  evaBlue;

  String get label => switch (this) {
        off => l10n.moRen,
        swiss => l10n.ruiShiGuoJiPaiBan,
        magi => l10n.evaHong,
        evaBlue => l10n.evaLan,
      };

  String get desc => switch (this) {
        off => l10n.biaoZhunShenQianZiShiYingYangShi,
        swiss => l10n.zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ,
        magi => l10n.evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS,
        evaBlue => l10n.evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie,
      };

  /// EVA 家族（红/蓝）共用同一套版式与组件，只换调色板。
  bool get isEva => this == ExperimentalUiSkin.magi || this == evaBlue;

  static ExperimentalUiSkin fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ExperimentalUiSkin.off;
    for (final skin in ExperimentalUiSkin.values) {
      if (skin.name == wire) return skin;
    }
    if (wire == 'default') return ExperimentalUiSkin.off;
    return ExperimentalUiSkin.off;
  }
}
