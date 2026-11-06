import 'package:overtone/l10n/l10n.dart';

/// 全站实验性 UI 皮肤类型。
enum ExperimentalUiSkin {
  off,
  swiss,
  magi,
  evaBlue,
  glass;

  String get label => switch (this) {
    off => l10n.moRen,
    swiss => l10n.ruiShiGuoJiPaiBan,
    magi => l10n.evaHong,
    evaBlue => l10n.evaLan,
    // 新皮肤不新增 l10n 词条：名称与说明用中文常量。
    glass => '液态玻璃',
  };

  String get desc => switch (this) {
    off => l10n.biaoZhunShenQianZiShiYingYangShi,
    swiss => l10n.zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ,
    magi => l10n.evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS,
    evaBlue => l10n.evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie,
    glass => '全站液态玻璃材质：有界背板模糊 + 染色 + 描边高光，不启用折射',
  };

  /// EVA 家族（红/蓝）共用同一套版式与组件，只换调色板。
  bool get isEva => this == ExperimentalUiSkin.magi || this == evaBlue;

  /// 液态玻璃是独立皮肤：圆角、浮层、阴影都保留，**不是**硬边档案语汇。
  bool get isGlass => this == ExperimentalUiSkin.glass;

  /// 是否走「档案终端」那套硬边皮肤（瑞士排版与 EVA 家族）。
  ///
  /// 玻璃皮肤必须显式排除：否则全站的 `isArchiveStyle` 分支会把它当档案画成
  /// 硬边零圆角，玻璃观感直接崩掉。
  bool get isArchiveStyle =>
      this != ExperimentalUiSkin.off && !isGlass;

  static ExperimentalUiSkin fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ExperimentalUiSkin.off;
    for (final skin in ExperimentalUiSkin.values) {
      if (skin.name == wire) return skin;
    }
    if (wire == 'default') return ExperimentalUiSkin.off;
    // 已下线的皮肤（历史值 'skeuo' 等）一律回落到默认皮肤。
    return ExperimentalUiSkin.off;
  }
}
