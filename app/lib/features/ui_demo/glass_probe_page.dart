import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../shared/widgets/glass_merge.dart';

/// **折射命门验证页**（技术验证，不是产品界面）。
///
/// 要回答的问题：`BackdropFilter(filter: ImageFilter.shader(...))` 里第一个
/// `sampler2D` 拿到的到底是不是「背板快照」。做法是让 shader 把采样坐标整体
/// 平移 8 物理像素：
///
/// - 玻璃里的条纹 / 文字跟着错位 8px  → **支持**，A 档成立；
/// - 玻璃里的画面纹丝不动            → 拿到的不是背板（是元素自身内容或空图层），
///   A 档不成立，改走 B 档（bounded blur + 高光 + 内阴影 + 融合 + 按压）。
///
/// 顺手验三件事：
/// 1. 第一个 uniform 必须是 vec2（引擎写纹理尺寸）——本页加载失败即说明约束被破坏；
/// 2. GLES 后端 y 轴是否翻转——打开「手动翻 y」看哪一档是正的；
/// 3. sampler 过滤质量——看斜条纹在 8px 位移下是平滑还是锯齿。
/// 4. 融合（smooth-union）—— [GlassMergeGroup] 演示：拖动胶囊看颈部
///    连续生长 / 消退（几何驱动，无帧动画，任意时刻可反向）。
///
/// 入口：`/dev/glass-probe`（仅 debug 注册，见 `app.dart`）。
/// 用法：切「位移 0 / 8」各截一张图，两张必须肉眼可辨；对比即证据。
class GlassProbePage extends StatefulWidget {
  const GlassProbePage({super.key});

  @override
  State<GlassProbePage> createState() => _GlassProbePageState();
}

class _GlassProbePageState extends State<GlassProbePage> {
  ui.FragmentShader? _shader;
  String _status = '加载中…';

  double _shift = 0;
  bool _tint = false;
  bool _flip = false;

  // 融合演示：两个胶囊的左上角位置（拖动改变）。初始间距 60 > mergeNeck(30)，
  // 拖近后颈部开始生长。
  Offset _chipA = const Offset(24, 78);
  Offset _chipB = const Offset(234, 78);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ui.ImageFilter.isShaderFilterSupported) {
      setState(() {
        _status = 'isShaderFilterSupported = false：非 Impeller，A 档不成立，直接走 B 档';
      });
      return;
    }
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/glass_probe.frag',
      );
      if (!mounted) return;
      setState(() {
        _shader = program.fragmentShader();
        _status = 'isShaderFilterSupported = true；shader 已编译';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'shader 编译失败：$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Glass · 折射命门验证'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(OvertoneSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _status,
              style: const TextStyle(color: Color(0xFF9FB3C8), fontSize: 12),
            ),
            const SizedBox(height: OvertoneSpacing.md),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _ProbeBackdrop()),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: 40,
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: shader == null
                          ? const ColoredBox(color: Color(0x33FFFFFF))
                          : BackdropFilter(
                              filter: _filter(shader),
                              child: const ColoredBox(color: Color(0x14000000)),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OvertoneSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _btn('位移 0px（A）', _shift == 0, () => setState(() => _shift = 0)),
                _btn('位移 8px（B）', _shift == 8, () => setState(() => _shift = 8)),
                _btn('整体染红', _tint, () => setState(() => _tint = !_tint)),
                _btn('手动翻 y', _flip, () => setState(() => _flip = !_flip)),
              ],
            ),
            const SizedBox(height: OvertoneSpacing.lg),
            const Text(
              '融合（smooth-union · 几何驱动）—— 拖动两个胶囊让它们靠近',
              style: TextStyle(color: Color(0xFF9FB3C8), fontSize: 12),
            ),
            const SizedBox(height: OvertoneSpacing.sm),
            Container(
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: GlassMergeGroup(
                tier: GlassTier.regular,
                blobRadius: 32,
                background: _ProbeBackdrop(),
                children: [
                  Positioned(
                    left: _chipA.dx,
                    top: _chipA.dy,
                    child: GlassMergeBlob(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) =>
                            setState(() => _chipA = _chipA + d.delta),
                        child: _mergeChip(const Color(0xFF5EE6D0), '消息'),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _chipB.dx,
                    top: _chipB.dy,
                    child: GlassMergeBlob(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) =>
                            setState(() => _chipB = _chipB + d.delta),
                        child: _mergeChip(const Color(0xFFB58CFF), '播放'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '判读：A/B 两张如果玻璃内的条纹错位 8px → 支持（采到的是背板）；'
              '如果两张完全一样 / 玻璃内是一片纯色 → 不支持。\n'
              '「整体染红」若玻璃区域整块变红且保留条纹结构 → 采到内容；'
              '整块纯红无结构 → 采样域为空。',
              style: TextStyle(color: Color(0xFF7F8FA6), fontSize: 11.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  ui.ImageFilter _filter(ui.FragmentShader shader) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    shader
      ..setFloat(0, size.width * dpr)
      ..setFloat(1, size.height * dpr)
      ..setFloat(2, _shift)
      ..setFloat(3, 0)
      ..setFloat(4, _tint ? 1 : 0)
      ..setFloat(5, _flip ? 1 : 0);
    return ui.ImageFilter.shader(shader);
  }

  Widget _btn(String label, bool on, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: on ? Colors.white : const Color(0xFF7F8FA6),
        backgroundColor: on ? const Color(0xFF2E6BFF) : const Color(0x14FFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  /// 融合演示的内容胶囊（不带玻璃底 —— 玻璃由 [GlassMergeGroup] 画）。
  Widget _mergeChip(Color dotColor, String label) {
    return Container(
      width: 150,
      height: 64,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [dotColor, dotColor.withValues(alpha: 0.6)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// 背板：斜条纹 + 大号字母 + 四色块。位移 8px 在条纹上肉眼可辨。
class _ProbeBackdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StripesPainter());
  }
}

class _StripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF203A6B),
            Color(0xFF7A3A86),
            Color(0xFF2D8C7A),
            Color(0xFFB4531F),
          ],
        ).createShader(Offset.zero & size),
    );
    final stripe = Paint()..color = const Color(0xCCFFFFFF);
    for (double x = -size.height; x < size.width; x += 24) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 10, 0)
        ..lineTo(x + 10 + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripe);
    }
    final tp = TextPainter(
      text: const TextSpan(
        text: 'OVERTONE',
        style: TextStyle(
          color: Color(0xFF101820),
          fontSize: 64,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(16, size.height * 0.55));
  }

  @override
  bool shouldRepaint(_StripesPainter old) => false;
}
