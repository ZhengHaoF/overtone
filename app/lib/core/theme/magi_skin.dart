/// EVA 皮肤家族共用的展示型字号阶梯。
///
/// 只服务于 EVA 海报风的主标题、编号与读数，不进入全站字号阶梯；红/蓝两套
/// 皮肤共用同一套排版，颜色一律走 `EvaPalette`。
abstract final class MagiSkin {
  // 展示型字号：只服务于 EVA 主标题与读数。
  static const double heroSize = 44;
  static const double homeHeroSize = 64;
  // 窄屏（手机 / 窄窗口）页头：巨号字会让 360px 溢出，这里收到一档。
  static const double homeHeroSizeNarrow = 34;
  static const double homeHeroDateSize = 50;
  static const double entryTitleSize = 28;
  static const double readoutSize = 40;

  // ── 海报字号阶梯（刻意不并入全站的 10/12/15/18/22）──
  // EVA 的排版靠字号对比吃饭：品牌字要压过正文，微标签要小到不抢文案。
  // 这些值只给 EVA 皮肤自己用；标准/瑞士皮肤仍受 design_tokens_policy_test 约束。
  static const double brandSize = 44;
  static const double brandSubSize = 10;
  static const double groupSize = 11;
  static const double navSize = 18;
  static const double navNumeralSize = 16;
  static const double navEnSize = 9;
  static const double numeralSize = 20;
  static const double gaugeLabelSize = 10;
  static const double tagSize = 12;
  static const double buttonSize = 16;
}
