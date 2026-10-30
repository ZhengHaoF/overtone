/// 全站实验性 UI 皮肤类型。
enum ExperimentalUiSkin {
  off('默认', '标准深浅自适应样式'),
  swiss('瑞士国际排版', '纸白墨黑无衬线排版，选中后全站切换为浅色'),
  magi('EVA红', 'EVA 战术超算红黑终端，明日香暗色警戒风格'),
  evaBlue('EVA蓝', 'EVA 零号机瓷白冰蓝，绫波丽亮色档案界面');

  const ExperimentalUiSkin(this.label, this.desc);
  final String label;
  final String desc;

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
