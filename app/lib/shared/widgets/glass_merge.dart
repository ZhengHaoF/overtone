import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import 'liquid_glass.dart'
    show LiquidGlass, glassColorMatrix, glassSheenGradient;

/// 玻璃融合组 —— 对齐 iOS 26 `GlassEffectContainer` 的语义（**容器拥有
/// 玻璃**，children 只放内容）+ 对照稿 §03 的 smooth-union 颈部。
///
/// 与「两块独立玻璃靠得近」的区别：间距进入 [GlassMotion.mergeNeck] 的
/// 作用范围后，轮廓不是两个形状并排，而是按 SDF smooth-union 连续长出
/// 「颈部」并共用一条连续的边缘高光。k 由实时间距插值，逐帧跟随位置，
/// 任意时刻可反向 —— 没有帧动画，天然可打断（对照稿的 24 帧预计算 +
/// easeOutBack 回放方案被取代，见 `GlassMotion.mergeNeck` 的注释）。
///
/// 用法：
/// ```dart
/// SizedBox(
///   height: 220,
///   child: GlassMergeGroup(
///     background: _Stripes(),
///     children: [
///       Positioned(left: 20, top: 60, child: GlassMergeBlob(child: 消息胶囊)),
///       Positioned(left: 220, top: 60, child: GlassMergeBlob(child: 播放胶囊)),
///     ],
///   ),
/// )
/// ```
///
/// 约定：
/// - [GlassMergeGroup] 必须有确定尺寸（放进 SizedBox / Expanded / 固定高度
///   Container）；children 需要自行用 Positioned / Align 定位；
/// - [GlassMergeBlob] 只包内容（文字 / 图标 / 控件），**不要自带玻璃底**；
/// - 容器每帧读一次各 blob 的真实矩形（绝大多数帧无变化 → 不 setState）。
///
/// 已知取舍（v2.1）：
/// - 未融合的单 blob 走 [LiquidGlass] 全量 A 档（折射 + 色散 + 高光）；
///   融合后的整块面板走 B 档（bounded blur + 连续 rim）—— 双箱 smooth-union
///   折射需要 shader 支持多 box，留待 v2.2；
/// - 融合面板不画外投影（轮廓是动态的，随动阴影成本高）；
/// - 高对比度 / 关特效时整组退化为不透明面。
class GlassMergeGroup extends StatefulWidget {
  const GlassMergeGroup({
    super.key,
    required this.children,
    this.background,
    this.tier = GlassTier.regular,
    this.blobRadius = 22,
    this.tint,
    this.scrolling = false,
  });

  /// 内容层。每个 child 里应有一个 [GlassMergeBlob]。
  final List<Widget> children;

  /// 最底层的背板（条纹 / 封面墙等），在玻璃之下、内容之上不参与。
  final Widget? background;

  final GlassTier tier;

  /// 未融合 blob 的圆角；融合轮廓的 SDF 也用同一圆角。
  final double blobRadius;

  /// 自适应染色（封面主色），与 [LiquidGlass.tint] 同语义。
  final Color? tint;

  /// 滚动中：降模糊档 + 收敛（对齐 [LiquidGlass.scrolling]）。
  final bool scrolling;

  @override
  State<GlassMergeGroup> createState() => GlassMergeGroupState();
}

class GlassMergeGroupState extends State<GlassMergeGroup>
    with SingleTickerProviderStateMixin {
  final List<GlassMergeBlobState> _blobs = [];
  Ticker? _ticker;
  List<Rect> _rects = const [];
  List<_Cluster> _clusters = const [];

  static GlassMergeGroupState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<GlassMergeGroupState>();

  void _register(GlassMergeBlobState blob) {
    _blobs.add(blob);
    _ensureTicker();
    // blob 的 didChangeDependencies 处在 build 阶段，首帧矩形等布局完再读。
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _unregister(GlassMergeBlobState blob) {
    _blobs.remove(blob);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  void _ensureTicker() {
    if (_ticker != null) return;
    final ticker = createTicker((_) => _refresh());
    ticker.start();
    _ticker = ticker;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }

  /// 每帧读一次各 blob 的真实矩形。子项不动时零 setState。
  void _refresh() {
    if (!mounted) return;
    final groupBox = context.findRenderObject();
    if (groupBox is! RenderBox || !groupBox.hasSize || !groupBox.attached) {
      return;
    }
    final rects = <Rect>[];
    for (final blob in _blobs) {
      final ro = blob.context.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize) return; // 未 layout
      rects.add(
        groupBox.globalToLocal(ro.localToGlobal(Offset.zero)) & ro.size,
      );
    }
    if (_sameRects(rects, _rects)) return;
    setState(() {
      _rects = rects;
      _clusters = _computeClusters(rects);
    });
  }

  bool _sameRects(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 连通分量聚类：表面间距 < mergeNeck 的 blob 归为一簇，簇内逐对取
  /// 最大的 k（几何驱动：k = k1 · (1 − gap / k1)，间距归零时颈部张满）。
  List<_Cluster> _computeClusters(List<Rect> rects) {
    final n = rects.length;
    final parent = List<int>.generate(n, (i) => i);
    int find(int i) => parent[i] == i ? i : (parent[i] = find(parent[i]));

    final kOf = List<double>.filled(n, 0);
    final k1 = GlassMotion.mergeNeck;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final gap = _gap(rects[i], rects[j]);
        if (gap >= k1) continue;
        final k = k1 * (1 - gap / k1);
        final a = find(i);
        final b = find(j);
        if (a != b) parent[a] = b;
        kOf[i] = math.max(kOf[i], k);
        kOf[j] = math.max(kOf[j], k);
      }
    }
    final groups = <int, List<int>>{};
    for (var i = 0; i < n; i++) {
      groups.putIfAbsent(find(i), () => []).add(i);
    }
    return [
      for (final indices in groups.values)
        _Cluster(
          indices: indices,
          rects: [for (final i in indices) rects[i]],
          ks: [for (final i in indices) kOf[i]],
        ),
    ];
  }

  /// 两个矩形的表面间距（已重叠的方向贡献 0，取两轴间距的欧氏距离）。
  double _gap(Rect a, Rect b) {
    final dx = math.max(0.0, math.max(a.left - b.right, b.left - a.right));
    final dy = math.max(0.0, math.max(a.top - b.bottom, b.top - a.bottom));
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final spec = GlassSpec.resolve(widget.tier, isLight: theme.isLight);
    final tintedScrim = widget.tint == null
        ? spec.scrim
        : Color.lerp(spec.scrim, widget.tint, spec.tintStrength)!;
    final solid =
        !OvertoneTheme.glassEffectsEnabled || MediaQuery.of(context).highContrast;

    final panels = <Widget>[];
    for (final cluster in _clusters) {
      final rect = cluster.bounds;
      if (rect.isEmpty) continue;
      final Widget glass;
      if (cluster.rects.length == 1) {
        // 未融合：交给 LiquidGlass 全量渲染（A 档折射 + 高光 + 内阴影）。
        glass = LiquidGlass(
          key: ValueKey('merge-blob-${cluster.indices.first}'),
          tier: widget.tier,
          radius: widget.blobRadius,
          scrolling: widget.scrolling,
          tint: widget.tint,
          child: const SizedBox.shrink(),
        );
      } else {
        glass = _ClusterGlass(
          key: ValueKey('merge-cluster-${cluster.indices.join('-')}'),
          path: cluster.path(widget.blobRadius),
          spec: spec,
          scrim: solid ? tintedScrim.withValues(alpha: 1.0) : tintedScrim,
          blurSigma: spec.blurSigma,
          scrolling: widget.scrolling,
        );
      }
      panels.add(Positioned.fromRect(rect: rect, child: glass));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.background != null) widget.background!,
        ...panels,
        ...widget.children,
      ],
    );
  }
}

/// 融合组里的内容占位。玻璃底板不在这里画 —— 容器拥有玻璃；
/// 它只负责把自己的实时矩形报给 [GlassMergeGroupState]。
class GlassMergeBlob extends StatefulWidget {
  const GlassMergeBlob({super.key, required this.child});

  final Widget child;

  @override
  State<GlassMergeBlob> createState() => GlassMergeBlobState();
}

class GlassMergeBlobState extends State<GlassMergeBlob> {
  GlassMergeGroupState? _group;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final group = GlassMergeGroupState.maybeOf(context);
    if (!identical(group, _group)) {
      _group?._unregister(this);
      _group = group;
      group?._register(this);
    }
  }

  @override
  void dispose() {
    _group?._unregister(this);
    _group = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 一簇玻璃：同一连通分量（可能是已融合的多个 blob）共享一块底板。
class _Cluster {
  const _Cluster({
    required this.indices,
    required this.rects,
    required this.ks,
  });

  final List<int> indices;
  final List<Rect> rects;
  final List<double> ks;

  Rect get bounds => rects.reduce((a, b) => a.expandToInclude(b));

  /// 簇的轮廓。单矩形直接 addRRect；多矩形走 smooth-union SDF +
  /// marching squares 抽等值线（3px 网格，rim 连续、颈部圆滑）。
  Path path(double radius) {
    if (rects.length == 1) {
      return Path()
        ..addRRect(
          RRect.fromRectAndRadius(rects.first, Radius.circular(radius)),
        );
    }
    return _unionPath(rects, ks, radius);
  }
}

class _ClusterGlass extends StatelessWidget {
  const _ClusterGlass({
    super.key,
    required this.path,
    required this.spec,
    required this.scrim,
    required this.blurSigma,
    required this.scrolling,
  });

  final Path path;
  final GlassSpec spec;
  final Color scrim;
  final double blurSigma;
  final bool scrolling;

  @override
  Widget build(BuildContext context) {
    final sigma = scrolling ? spec.scrollingSigma : blurSigma;
    final body = CustomPaint(
      foregroundPainter: _ClusterRimPainter(path: path, spec: spec),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: glassSheenGradient(scrim, spec)),
        child: const SizedBox.expand(),
      ),
    );
    final useBlur = sigma > 0 && GlassQuality.backdropAllowed;
    return ClipPath(
      clipper: _PathClipper(path),
      child: useBlur
          ? BackdropFilter(
              filterConfig: ImageFilterConfig.compose(
                inner: ImageFilterConfig.blur(
                  sigmaX: sigma,
                  sigmaY: sigma,
                  bounded: true,
                ),
                outer: ImageFilterConfig(
                  ui.ColorFilter.matrix(
                    glassColorMatrix(spec.saturation, spec.contrast),
                  ),
                ),
              ),
              child: body,
            )
          : body,
    );
  }
}

/// 融合轮廓上的高光：左上柔光 + 一条连续的 1px 渐变 rim（顶亮 → 中段
/// 几乎消失 → 底收暗），与 [LiquidGlass] 的同一光源假设（左上 45°）。
class _ClusterRimPainter extends CustomPainter {
  _ClusterRimPainter({required this.path, required this.spec});

  final Path path;
  final GlassSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = path.getBounds();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          center: const Alignment(-0.6, -0.8),
          radius: 1.2,
          colors: [spec.glint, spec.glint.withValues(alpha: 0)],
        ).createShader(bounds),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            spec.rimTop,
            spec.rimTop.withValues(alpha: spec.rimTop.a * 0.08),
            spec.rimBottom,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_ClusterRimPainter old) =>
      old.path != path || old.spec != spec;
}

class _PathClipper extends CustomClipper<Path> {
  const _PathClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(_PathClipper old) => old.path != path;
}

/// 多项式 smooth-union（与对照稿同一式）：k 越大、两形越近，中段越鼓。
double _smin(double a, double b, double k) {
  if (k <= 0.001) return math.min(a, b);
  final h = math.max(k - (a - b).abs(), 0.0) / k;
  return math.min(a, b) - h * h * k * 0.25;
}

/// 有符号距离：负数在内部（与 glass_refract.frag 的 sdRoundRect 同式）。
double _sdRoundRect(Offset p, Rect r, double radius) {
  final q = Offset(
    (p.dx - r.center.dx).abs() - r.width / 2 + radius,
    (p.dy - r.center.dy).abs() - r.height / 2 + radius,
  );
  final outside = Offset(math.max(q.dx, 0), math.max(q.dy, 0)).distance;
  return outside + math.max(math.min(q.dx, q.dy), 0.0) - radius;
}

Path _unionPath(List<Rect> rects, List<double> ks, double radius) {
  final k1 = GlassMotion.mergeNeck;
  final kMax = ks.fold(0.0, math.max);
  final bounds =
      rects
          .reduce((a, b) => a.expandToInclude(b))
          .inflate(kMax + k1 * 0.25 + 4);

  double field(Offset p) {
    // 正数在内部：先算 smin（负数在内部），再整体取反。
    var v = _sdRoundRect(p, rects[0], radius);
    for (var i = 1; i < rects.length; i++) {
      v = _smin(v, _sdRoundRect(p, rects[i], radius), ks[i]);
    }
    return -v;
  }

  return _marchingSquares(field, bounds, 3);
}

/// 等值线抽取：3px 网格采样 SDF → marching squares → 邻接表串链成
/// 闭合轮廓。共享边上的插值点由同一对角点值算出，坐标逐位一致，
/// 因此用 1/8 px 量化坐标做 key 就能精确串接。
Path _marchingSquares(
  double Function(Offset p) field,
  Rect bounds,
  double cell,
) {
  final nx = (bounds.width / cell).ceil() + 1;
  final ny = (bounds.height / cell).ceil() + 1;
  final values = Float64List(nx * ny);
  for (var j = 0; j < ny; j++) {
    final y = bounds.top + j * cell;
    for (var i = 0; i < nx; i++) {
      values[j * nx + i] = field(Offset(bounds.left + i * cell, y));
    }
  }

  Offset corner(int i, int j) =>
      Offset(bounds.left + i * cell, bounds.top + j * cell);

  Offset interp(Offset a, Offset b, double va, double vb) {
    final t = va / (va - vb);
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  final points = <String, Offset>{};
  final links = <String, List<String>>{};
  String keyOf(Offset p) => '${(p.dx * 8).round()}:${(p.dy * 8).round()}';

  void addSeg(Offset a, Offset b) {
    final ka = keyOf(a);
    final kb = keyOf(b);
    points[ka] ??= a;
    points[kb] ??= b;
    (links[ka] ??= []).add(kb);
    (links[kb] ??= []).add(ka);
  }

  void removeSeg(String ka, String kb) {
    links[ka]?.remove(kb);
    links[kb]?.remove(ka);
  }

  for (var j = 0; j < ny - 1; j++) {
    for (var i = 0; i < nx - 1; i++) {
      final tl = values[j * nx + i];
      final tr = values[j * nx + i + 1];
      final bl = values[(j + 1) * nx + i];
      final br = values[(j + 1) * nx + i + 1];
      var bits = 0;
      if (tl > 0) bits |= 8;
      if (tr > 0) bits |= 4;
      if (br > 0) bits |= 2;
      if (bl > 0) bits |= 1;
      if (bits == 0 || bits == 15) continue;

      final pTL = corner(i, j);
      final pTR = corner(i + 1, j);
      final pBL = corner(i, j + 1);
      final pBR = corner(i + 1, j + 1);
      Offset? top;
      Offset? right;
      Offset? bottom;
      Offset? left;
      Offset edgeTop() => top ??= interp(pTL, pTR, tl, tr);
      Offset edgeRight() => right ??= interp(pTR, pBR, tr, br);
      Offset edgeBottom() => bottom ??= interp(pBL, pBR, bl, br);
      Offset edgeLeft() => left ??= interp(pTL, pBL, tl, bl);

      switch (bits) {
        case 1:
          addSeg(edgeLeft(), edgeBottom());
        case 2:
          addSeg(edgeBottom(), edgeRight());
        case 3:
          addSeg(edgeLeft(), edgeRight());
        case 4:
          addSeg(edgeTop(), edgeRight());
        case 5: // 鞍点：用中心值决定连通方式，保证轮廓拓扑正确
          final center = (tl + tr + br + bl) / 4;
          if (center > 0) {
            addSeg(edgeLeft(), edgeTop());
            addSeg(edgeBottom(), edgeRight());
          } else {
            addSeg(edgeTop(), edgeRight());
            addSeg(edgeLeft(), edgeBottom());
          }
        case 6:
          addSeg(edgeTop(), edgeBottom());
        case 7:
          addSeg(edgeTop(), edgeLeft());
        case 8:
          addSeg(edgeTop(), edgeLeft());
        case 9:
          addSeg(edgeTop(), edgeBottom());
        case 10: // 鞍点（对偶情形）
          final center = (tl + tr + br + bl) / 4;
          if (center > 0) {
            addSeg(edgeTop(), edgeRight());
            addSeg(edgeLeft(), edgeBottom());
          } else {
            addSeg(edgeLeft(), edgeTop());
            addSeg(edgeBottom(), edgeRight());
          }
        case 11:
          addSeg(edgeTop(), edgeRight());
        case 12:
          addSeg(edgeLeft(), edgeRight());
        case 13:
          addSeg(edgeBottom(), edgeRight());
        case 14:
          addSeg(edgeLeft(), edgeBottom());
      }
    }
  }

  final path = Path();
  for (final startKey in points.keys.toList()) {
    final startLinks = links[startKey];
    if (startLinks == null || startLinks.isEmpty) continue;
    final chain = <Offset>[points[startKey]!];
    var curKey = startLinks.removeLast();
    removeSeg(startKey, curKey);
    chain.add(points[curKey]!);
    while (curKey != startKey) {
      final next = links[curKey];
      if (next == null || next.isEmpty) break;
      final nk = next.removeLast();
      removeSeg(curKey, nk);
      curKey = nk;
      if (curKey == startKey) break;
      chain.add(points[curKey]!);
    }
    path.moveTo(chain.first.dx, chain.first.dy);
    for (var i = 1; i < chain.length; i++) {
      path.lineTo(chain[i].dx, chain[i].dy);
    }
    path.close();
  }
  return path;
}
