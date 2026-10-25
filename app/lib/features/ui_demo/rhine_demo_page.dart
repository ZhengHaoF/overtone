import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'rhine_demo_paint.dart';

/// Rhine Lab 终端风格的**技术验证页**，不是产品界面。
///
/// 演示评估里说的第 1、2 两点：
///   1. `Matrix4` 透视 —— 40 份档案的循环阵列、选中抬起、切列偏转，全在 Widget 树里；
///   2. runtime shader —— 成片层（颗粒/暗角/扫描带/色散）与盖板自上而下的解密揭示遮罩。
///
/// 刻意不接主题与数据源：配色是这套语言自己的白底墨色，内容是本地造的假档案，
/// 免登录、免网络，方便截图对比。真要落地时这些都要收回 token 体系与真实数据。
///
/// 操作：`←/→` 切列，`↑/↓` 翻阅，`Enter` 抽取并解密，`Esc` 返回，`R` 重播开场。
class RhineDemoPage extends StatefulWidget {
  const RhineDemoPage({super.key, this.frozenReveal});

  /// 直接进详情页并把揭示进度冻在给定值，用于逐帧核对盖板 shader 的方向。
  final double? frozenReveal;

  @override
  State<RhineDemoPage> createState() => _RhineDemoPageState();
}

/// 假档案：5 类 × 8 条，对齐原作的 40 份。
class _Archive {
  const _Archive(this.code, this.title, this.en, this.dept, this.clearance);

  final String code;
  final String title;
  final String en;
  final String dept;
  final String clearance;
}

const _categories = <String>['唱片', '母带', '电台', '影像', '现场'];

/// [标题, 英文名, 科室, 权限]
const _rows = <List<List<String>>>[
  [
    ['夜航船', 'Night Ferry', '流行', 'PUBLIC'],
    ['潮汐图书馆', 'Tidal Library', '古典', 'PUBLIC'],
    ['玻璃海', 'Glass Sea', '电子', 'RESTRICTED'],
    ['荒原电台', 'Wavelength', '摇滚', 'PUBLIC'],
    ['雪线以上', 'Above Snowline', '民谣', 'PUBLIC'],
    ['铜与尘', 'Brass & Dust', '爵士', 'INTERNAL'],
    ['白噪纪元', 'White Noise Era', '氛围', 'PUBLIC'],
    ['旧月亮', 'Old Moon', '国语经典', 'PUBLIC'],
  ],
  [
    ['1978 钢片母带', 'Steel Master', '档案', 'SEALED'],
    ['现场拾音 · 大厅', 'Hall Capture', '录音', 'INTERNAL'],
    ['人声试片', 'Vocal Testpress', '录音', 'INTERNAL'],
    ['弦乐四重奏原声', 'Quartet Acoustic', '档案', 'PUBLIC'],
    ['磁带回录', 'Tape Return', '修复', 'SEALED'],
    ['动态范围样本', 'Dynamics Sample', '检测', 'INTERNAL'],
    ['底噪剖面', 'Noise Floor', '检测', 'PUBLIC'],
    ['单声道兼容', 'Mono Compat', '修复', 'RESTRICTED'],
  ],
  [
    ['凌晨四点的频率', '0400 Frequency', '夜间', 'PUBLIC'],
    ['城市朗读', 'City Reading', '谈话', 'PUBLIC'],
    ['无波段', 'Off Band', '实验', 'RESTRICTED'],
    ['短波来信', 'Shortwave Mail', '档案', 'PUBLIC'],
    ['点歌台', 'Request Desk', '互动', 'PUBLIC'],
    ['雨声值班室', 'Rain Duty Room', '氛围', 'INTERNAL'],
    ['广播剧残片', 'Radio Fragment', '档案', 'SEALED'],
    ['早间通勤', 'Morning Commute', '通勤', 'PUBLIC'],
  ],
  [
    ['访问 · 特别映像', 'The Visit', '影像', 'PUBLIC'],
    ['观测室', 'Observation Room', '纪录', 'INTERNAL'],
    ['装配线长镜头', 'Assembly Take', '工程', 'RESTRICTED'],
    ['无尘室', 'Clean Room', '工程', 'SEALED'],
    ['展台拆解', 'Booth Breakdown', '产品', 'PUBLIC'],
    ['暗房冲印', 'Darkroom', '影像', 'INTERNAL'],
    ['舞台机械', 'Stage Rig', '工程', 'PUBLIC'],
    ['空镜收集', 'Empty Frames', '影像', 'RESTRICTED'],
  ],
  [
    ['体育馆巡演', 'Arena Tour', '现场', 'PUBLIC'],
    ['地下三层', 'Level B3', '现场', 'INTERNAL'],
    ['教堂混响', 'Church Reverb', '现场', 'RESTRICTED'],
    ['雨天露天', 'Open Air Rain', '现场', 'PUBLIC'],
    ['不插电场次', 'Unplugged', '现场', 'SEALED'],
    ['声闸测试', 'Gate Test', '检测', 'INTERNAL'],
    ['返送故障记录', 'Monitor Fault', '检测', 'SEALED'],
    ['散场之后', 'After Doors', '现场', 'PUBLIC'],
  ],
];

List<_Archive> _archivesOf(int category) => [
  for (var i = 0; i < _rows[category].length; i++)
    _Archive(
      'RH-${category + 1}${(i + 1).toString().padLeft(2, '0')}',
      _rows[category][i][0],
      _rows[category][i][1],
      _rows[category][i][2],
      _rows[category][i][3],
    ),
];

const _bootLine = '> RHEINLAB ANALYSIS OS · IDENTITY ACCEPTED';

enum _Phase { array, decrypt, detail }

class _RhineDemoPageState extends State<RhineDemoPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _clock = Stopwatch();

  double _lastMs = 0;
  double _now = 0;

  /// 目标行列（整数）与阻尼后的连续位置。
  int _col = 0;
  int _row = 0;
  double _colF = 0;
  double _rowF = 0;

  _Phase _phase = _Phase.array;
  double _decryptStart = 0;
  double _reveal = 0;
  double _bootAt = 0;

  ui.FragmentProgram? _finish;
  ui.FragmentProgram? _revealProg;

  /// runtime shader 在本平台拿不到时置位，页面退回纯 Widget 近似继续跑。
  bool _shaderUnavailable = false;

  @override
  void initState() {
    super.initState();
    final frozen = widget.frozenReveal;
    if (frozen != null) {
      _phase = _Phase.detail;
      _reveal = frozen.clamp(0.0, 1.0);
      _bootAt = -10;
    }
    _ticker = createTicker(_onFrame)..start();
    _clock.start();
    _loadShaders();
  }

  Future<void> _loadShaders() async {
    try {
      final a = await ui.FragmentProgram.fromAsset(
        'shaders/rhine_finish.frag',
      );
      final b = await ui.FragmentProgram.fromAsset(
        'shaders/rhine_reveal.frag',
      );
      if (!mounted) return;
      setState(() {
        _finish = a;
        _revealProg = b;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _shaderUnavailable = true);
      debugPrint('[rhine-demo] runtime shader 不可用，已退回近似：$error');
    }
  }

  void _onFrame(Duration elapsed) {
    final ms = _clock.elapsedMilliseconds.toDouble();
    final dt = math.min((ms - _lastMs) / 1000, 1 / 20);
    _lastMs = ms;
    _now = ms / 1000;

    _colF = _damp(_colF, _col.toDouble(), 9.0, dt);
    _rowF = _damp(_rowF, _row.toDouble(), 9.0, dt);

    if (_phase == _Phase.decrypt) {
      final t = ((_now - _decryptStart) / 0.9).clamp(0.0, 1.0);
      _reveal = Curves.easeOutCubic.transform(t);
      if (t >= 1.0) {
        _phase = _Phase.detail;
        _reveal = 1;
      }
    }
    setState(() {});
  }

  /// 临界阻尼（原作 scene.ts 的 `damp()`）：指数逼近，不用固定时长补间，
  /// 所以连按方向键时是接续而不是重头播放。
  static double _damp(double current, double target, double rate, double dt) =>
      target - (target - current) * math.exp(-rate * dt);

  @override
  void dispose() {
    _ticker.dispose();
    _clock.stop();
    super.dispose();
  }

  void _move(int dc, int dr) {
    setState(() {
      _col = (_col + dc) % _categories.length;
      if (_col < 0) _col += _categories.length;
      _row = (_row + dr) % 8;
      if (_row < 0) _row += 8;
    });
  }

  void _pick(int col, int row) {
    setState(() {
      _col = col;
      _row = row;
      _colF = col.toDouble();
      _rowF = row.toDouble();
    });
  }

  void _enter() {
    if (_phase != _Phase.array) return;
    setState(() {
      _phase = _Phase.decrypt;
      _decryptStart = _now;
      _reveal = 0;
    });
  }

  void _back() => setState(() => _phase = _Phase.array);

  void _replayBoot() => setState(() => _bootAt = _now);

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final archive = _archivesOf(_col)[_row];
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.arrowLeft) {
          _move(-1, 0);
        } else if (key == LogicalKeyboardKey.arrowRight) {
          _move(1, 0);
        } else if (key == LogicalKeyboardKey.arrowUp) {
          _move(0, -1);
        } else if (key == LogicalKeyboardKey.arrowDown) {
          _move(0, 1);
        } else if (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) {
          if (_phase == _Phase.array) {
            _enter();
          } else {
            _back();
          }
        } else if (key == LogicalKeyboardKey.escape) {
          _back();
        } else if (key == LogicalKeyboardKey.keyR) {
          _replayBoot();
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Scaffold(
        backgroundColor: RhineInk.paper,
        body: LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, box.maxHeight);
            // 开场 2.6 秒：档案阵列随 boot 淡入并上浮到位。
            final boot = ((_now - _bootAt) / 2.6).clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: GridPainter(size: size)),
                Opacity(
                  opacity: 0.25 + 0.75 * boot,
                  child: _phase == _Phase.detail
                      ? _Detail(
                          archive: archive,
                          category: _categories[_col],
                          reveal: _reveal,
                          revealProg: _revealProg,
                          dpr: dpr,
                          now: _now,
                          onBack: _back,
                        )
                      : _Array(
                          colF: _colF,
                          rowF: _rowF,
                          size: size,
                          boot: boot,
                          phase: _phase,
                          reveal: _reveal,
                          now: _now,
                          onPick: _pick,
                          onEnter: _enter,
                        ),
                ),
                _Hud(
                  archive: archive,
                  category: _categories[_col],
                  boot: boot,
                  phase: _phase,
                  now: _now,
                  shaderUnavailable: _shaderUnavailable,
                  onReplayBoot: _replayBoot,
                ),
                RepaintBoundary(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: FinishPainter(
                        program: _finish,
                        time: _now,
                        size: size,
                        dpr: dpr,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ①：`Matrix4` 透视档案阵列。5 列 × 可见 4 行，横竖都无限循环。
class _Array extends StatelessWidget {
  const _Array({
    required this.colF,
    required this.rowF,
    required this.size,
    required this.boot,
    required this.phase,
    required this.reveal,
    required this.now,
    required this.onPick,
    required this.onEnter,
  });

  final double colF;
  final double rowF;
  final Size size;
  final double boot;
  final _Phase phase;
  final double reveal;
  final double now;
  final void Function(int col, int row) onPick;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final cardW = (size.width * 0.125).clamp(140.0, 196.0);
    final cardH = cardW * 1.32;
    final slotH = cardH * 1.06;
    final slotW = cardW * 1.58;
    final focusCol = colF.round();
    final focusRow = rowF.round();

    final layered = <(double, Widget)>[];
    for (var j = focusCol - 2; j <= focusCol + 2; j++) {
      final n = (j - colF).toDouble();
      final col = ((j % _categories.length) + _categories.length) %
          _categories.length;
      for (var k = focusRow - 1; k <= focusRow + 1; k++) {
        final row = ((k % 8) + 8) % 8;
        final archive = _archivesOf(col)[row];
        final isFocus = j == focusCol && k == focusRow;
        // 深度键：离焦点越远越先画，焦点卡最后画在最上层。Stack 是后画者压前画者，
        // 按列循环会把右侧列盖到焦点卡上，所以必须显式排序。
        final depth = n.abs() * 10 + (k - rowF).abs();
        layered.add((
          depth,
          Positioned(
            left: 0,
            top: 0,
            child: Transform(
              alignment: Alignment.topLeft,
              transform: _perspective(
                n: n,
                dy: (k - rowF) * slotH + (1 - boot) * 46,
                cardW: cardW,
                cardH: cardH,
                slotW: slotW,
                focus: isFocus,
                size: size,
              ),
              child: SizedBox(
                width: cardW,
                height: cardH,
                child: _Card(
                  archive: archive,
                  selected: isFocus,
                  dimmed: n.abs() > 0.6,
                  // 焦点卡带一层极淡的盖面雾感；抽走的那张在解密期间跟着进度变清晰
                  frost: isFocus && phase == _Phase.decrypt
                      ? 1 - reveal
                      : (isFocus ? 0.14 : 0.0),
                  now: now,
                  onTap: () => isFocus ? onEnter() : onPick(col, row),
                ),
              ),
            ),
          ),
        ));
      }
    }
    layered.sort((a, b) => b.$1.compareTo(a.$1));
    return Stack(children: [for (final item in layered) item.$2]);
  }

  /// 透视矩阵：相机在 z = -1/0.0007 处，列偏转用 rotateY，焦点卡抬起用 z。
  Matrix4 _perspective({
    required double n,
    required double dy,
    required double cardW,
    required double cardH,
    required double slotW,
    required bool focus,
    required Size size,
  }) {
    final cx = size.width / 2 + n * slotW - cardW / 2;
    final cy = size.height / 2 + dy - cardH / 2;
    final lift = focus ? 150.0 : 0.0;
    return Matrix4.identity()
      ..setEntry(3, 2, -0.0007)
      ..translateByDouble(cx, cy, lift - n.abs() * 260, 1.0)
      ..rotateY((n * 0.20).clamp(-0.5, 0.5))
      ..rotateX(0.03);
  }
}

/// 单张档案卡：白卡 + 发丝描边 + 刻度尺 + 编号/标题/权限 + 底部橙色强调条。
///
/// `frost > 0` 时叠一层毛玻璃（这是唯一用 BackdropFilter 的地方，且只在焦点卡上）。
class _Card extends StatelessWidget {
  const _Card({
    required this.archive,
    required this.selected,
    required this.dimmed,
    required this.frost,
    required this.now,
    required this.onTap,
  });

  final _Archive archive;
  final bool selected;
  final bool dimmed;
  final double frost;
  final double now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dimmed ? 0.42 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: RhineInk.card,
            border: Border.all(
              color: selected ? RhineInk.ink : RhineInk.hairStrong,
              width: 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: RhineInk.ink.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          // 盖面雾感叠在内容之上，frost 由解密进度驱动
          foregroundDecoration: frost <= 0
              ? null
              : BoxDecoration(
                  color: RhineInk.paper.withValues(alpha: 0.55 * frost),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7 * frost),
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RollingText(text: archive.code, style: RhineType.micro),
                  Text(archive.clearance, style: RhineType.micro),
                ],
              ),
              const SizedBox(height: 6),
              const _Ruler(),
              const Spacer(),
              Text(
                archive.title,
                style: selected ? RhineType.section : RhineType.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                archive.en,
                style: RhineType.micro,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(archive.dept, style: RhineType.micro),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: selected ? 26 : 12,
                    height: 2,
                    color: RhineInk.accent,
                  ),
                  const SizedBox(width: 4),
                  for (var i = 0; i < 5; i++)
                    Container(
                      width: 2,
                      height: 6,
                      margin: const EdgeInsets.only(right: 3),
                      color: RhineInk.hairStrong,
                    ),
                  const Spacer(),
                  // 呼吸点：证明这层一直在按帧重画，不是静态贴图
                  Container(
                    width: 4,
                    height: 4,
                    color: Color.lerp(
                      RhineInk.hairStrong,
                      RhineInk.teal,
                      (math.sin(now * 2.2) * 0.5 + 0.5),
                    ),
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

class _Ruler extends StatelessWidget {
  const _Ruler();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: CustomPaint(painter: _RulerPainter()),
    );
  }
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = RhineInk.hairStrong
      ..strokeWidth = 1;
    for (double x = 0; x < s.width; x += 6) {
      final tall = (x / 6).round() % 4 == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, tall ? 6 : 3), p);
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => false;
}

/// ②：详情页。左侧大卡在自转，盖板用 `rhine_reveal.frag` 自上而下揭开；
/// 右侧正文的黑条按进度退开。
class _Detail extends StatelessWidget {
  const _Detail({
    required this.archive,
    required this.category,
    required this.reveal,
    required this.revealProg,
    required this.dpr,
    required this.now,
    required this.onBack,
  });

  final _Archive archive;
  final String category;
  final double reveal;
  final ui.FragmentProgram? revealProg;
  final double dpr;
  final double now;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final yaw = math.sin(now * 0.5) * 0.26;
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 76, 56, 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 330,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, -0.0016)
                ..translateByDouble(0.0, 0.0, 40.0, 1.0)
                ..rotateY(yaw)
                ..rotateX(-0.10),
              child: AspectRatio(
                aspectRatio: 0.74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Card(
                      archive: archive,
                      selected: true,
                      dimmed: false,
                      frost: 0,
                      now: now,
                      onTap: () {},
                    ),
                    // 盖板：一层接近不透明的磨砂面，被揭示遮罩自上而下擦掉。
                    //
                    // 这里刻意不用 BackdropFilter —— ShaderMask 会先 saveLayer，
                    // 滤镜取到的背景是那个空图层而不是卡面，模糊等于没发生。
                    // 真折射是 3D 那一层的事，2D 侧靠不透明磨砂面表达。
                    RevealMask(
                      program: revealProg,
                      progress: reveal,
                      dpr: dpr,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xF7FFFFFF),
                              Color(0xE6E4E8E6),
                              Color(0xF2FFFFFF),
                            ],
                          ),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        child: SizedBox.expand(),
                      ),
                    ),
                    ClipRect(
                      child: CustomPaint(
                        painter: DecryptLinePainter(progress: reveal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RollingText(text: archive.title, style: RhineType.title),
                const SizedBox(height: 4),
                RollingText(text: archive.en, style: RhineType.micro),
                const SizedBox(height: 14),
                _Field(label: '编号', value: archive.code, reveal: reveal, i: 0),
                _Field(label: '分类', value: category, reveal: reveal, i: 1),
                _Field(
                  label: '科室',
                  value: archive.dept,
                  reveal: reveal,
                  i: 2,
                ),
                _Field(
                  label: '权限',
                  value: archive.clearance,
                  reveal: reveal,
                  i: 3,
                ),
                const SizedBox(height: 18),
                const _SectionLabel('研究记录'),
                for (var i = 0; i < _body.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: _Redacted(
                      text: _body[i],
                      progress: ((reveal - 0.25 - i * 0.09) / 0.5).clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Tag(label: 'SAVE ARCHIVE'),
                    const SizedBox(width: 8),
                    _Tag(label: 'EXPORT', onTap: onBack),
                    const SizedBox(width: 8),
                    _Tag(label: 'ESC · 返回阵列', onTap: onBack),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _body = <String>[
  '观测记录：盖板在揭示过程中由磨砂转清晰，双环内构与连接带封装在盖板与基板之间。',
  '声学区间：长焦镜头压缩透视，折射环组在 46 秒至 51 秒的多机位画面中可见完整轮廓。',
  '装配说明：紧固件、透明盖板、折射环组、光学核心、信息基板、背板与框架按六组展开。',
  '备注：本页为技术验证内容，正文为演示文本，不对应任何真实曲库条目。',
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 3, height: 12, color: RhineInk.accent),
          const SizedBox(width: 6),
          Text(text, style: RhineType.caption),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.reveal,
    required this.i,
  });

  final String label;
  final String value;
  final double reveal;
  final int i;

  @override
  Widget build(BuildContext context) {
    final p = ((reveal - 0.1 - i * 0.08) / 0.35).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 56, child: Text(label, style: RhineType.micro)),
          Expanded(
            child: _Redacted(text: value, progress: p),
          ),
        ],
      ),
    );
  }
}

/// 正文遮挡条：黑条随 progress 向右退出，文字从条后露出来。
///
/// 条宽按实测的文字行宽算，不是整列宽 —— 否则短行会盖住右边的空白。
class _Redacted extends StatelessWidget {
  const _Redacted({required this.text, required this.progress});

  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: RhineType.caption),
          textDirection: TextDirection.ltr,
          maxLines: 3,
          ellipsis: '…',
        )..layout(maxWidth: box.maxWidth);
        final runWidth = math.min(box.maxWidth, tp.width);
        final height = tp.height;
        return SizedBox(
          width: box.maxWidth,
          height: height,
          child: Stack(
            children: [
              Text(
                text,
                style: RhineType.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (progress < 1)
                Positioned(
                  left: runWidth * progress,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: runWidth * (1 - progress) + 2,
                    color: RhineInk.ink,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: RhineInk.hairStrong),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(label, style: RhineType.micro),
      ),
    );
  }
}

/// 终端 HUD：左上标志笔画与逐字输入，底部编号/列点/时钟/按键提示。
class _Hud extends StatelessWidget {
  const _Hud({
    required this.archive,
    required this.category,
    required this.boot,
    required this.phase,
    required this.now,
    required this.shaderUnavailable,
    required this.onReplayBoot,
  });

  final _Archive archive;
  final String category;
  final double boot;
  final _Phase phase;
  final double now;
  final bool shaderUnavailable;
  final VoidCallback onReplayBoot;

  @override
  Widget build(BuildContext context) {
    final typed = (_bootLine.length * boot).floor();
    final clock = _clockText();
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 26,
            top: 22,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onReplayBoot,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: LogoPainter(progress: boot),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 420,
                  child: RichText(
                    text: TextSpan(
                      style: RhineType.micro,
                      children: [
                        TextSpan(text: _bootLine.substring(0, typed)),
                        if (boot < 1 || _blink(now))
                          const TextSpan(text: ' ▍'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 26,
            bottom: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RollingText(text: archive.code, style: RhineType.caption),
                const SizedBox(width: 12),
                Text('/ $category', style: RhineType.micro),
                const SizedBox(width: 16),
                for (var i = 0; i < _categories.length; i++)
                  Container(
                    width: i == _categories.indexOf(category) ? 14 : 5,
                    height: 3,
                    margin: const EdgeInsets.only(right: 4),
                    color:
                        i == _categories.indexOf(category)
                            ? RhineInk.accent
                            : RhineInk.hairStrong,
                  ),
              ],
            ),
          ),
          Positioned(
            right: 26,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RollingText(text: clock, style: RhineType.caption),
                const SizedBox(height: 4),
                Text(
                  shaderUnavailable
                      ? 'SHADER OFF · ← → 切列 · ↑ ↓ 翻阅 · ENTER 抽取 · ESC 返回 · R 重播'
                      : 'FINISH SHADER ON · ← → 切列 · ↑ ↓ 翻阅 · ENTER 抽取 · ESC 返回 · R 重播',
                  style: RhineType.micro,
                ),
              ],
            ),
          ),
          if (phase == _Phase.array)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child: Text(
                  _blink(now) ? 'ENTER · ACCESS FILE' : ' ',
                  style: RhineType.caption,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _clockText() {
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  static bool _blink(double now) => (now * 2.4) % 1 < 0.6;
}
