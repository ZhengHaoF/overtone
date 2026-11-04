import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';

/// 液态玻璃面板（v2，对齐 `docs/liquid-glass-v2/index.html`）。
///
/// 与「一层半透明色 + 一次模糊」的区别在五件事上，缺一件就不像玻璃：
///
/// 1. **背板几何被改变**（A 档）：`ImageFilter.shader` 在背板快照上按
///    圆角矩形 SDF 高度场做边缘向内折弯 + 局部放大，band / peak 按层级
///    取 8/14/22 与 ×0.40；开色散时 R/B 相对 G 再偏 ±4.5%。拿不到
///    shader（非 Impeller / 被开关关掉）时退回 B 档「bounded blur」；
/// 2. **模糊按层级分档**：thin 2.5 / regular 3.5 / thick 5（v1 是 12/16/26），
///    因为 v2 的目标是「背景本来就该透，只是被折弯」，不是「把背景糊死」；
/// 3. **统一光源（左上 45°）**：顶边 1px α0.86 锐线、侧边发丝、底边收暗；
///    左上柔光会跟着指针 / 触摸在 ±10px 内移动（[GlassMotion.specularTravel]）；
/// 4. **按压有厚度**：下沉 1.5px + 内阴影 α0.38，抬手用弹簧回弹；
/// 5. **层级 = 厚度**：折射带宽、模糊、染色、高光、投影一起随 [GlassTier] 变。
///
/// 硬约束（性能 / 无障碍 / 隔离）：
/// - 每个面板外包 [RepaintBoundary]，避免模糊层随内容重绘；
/// - [_GlassDepth] 记录嵌套深度，**玻璃里再套玻璃一律退化为不透明面**；
/// - `OvertoneTheme.glassEffectsEnabled == false`（排查开关）、系统
///   「高对比度」、`GlassQuality.off` 时退化为纯色面；
/// - `MediaQuery.disableAnimations` / `accessibleNavigation` 时，材料凝结、
///   按压、融合都直接落到终态（时长 0）。
class LiquidGlass extends StatefulWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.tier = GlassTier.regular,
    this.radius = OvertoneRadius.card,
    this.padding,
    this.height,
    this.shadow,
    this.scrim,
    this.tint,
    this.scrolling = false,
    this.specular = true,
    this.materialize = false,
    this.blurSigma,
    this.borderRadius,
    this.pressable = false,
    this.hoverElastic = false,
  });

  final Widget child;
  final GlassTier tier;
  final double radius;

  /// 非均匀圆角（例如底部 sheet 只有上面两个角圆）。
  final BorderRadius? borderRadius;

  /// 内容内边距；null 时取该层级的默认值。
  final EdgeInsetsGeometry? padding;

  /// 固定高度；null 时由内容撑开。
  final double? height;

  /// 外层投影；null 时取该层级默认 elevation。
  final List<BoxShadow>? shadow;

  /// 覆盖该层级的玻璃底色（例如迷你条要更实一点的 90%）。
  final Color? scrim;

  /// 自适应染色：当前封面主色（null = 不染色）。
  final Color? tint;

  /// 滚动中：模糊降一档，停手 300ms 恢复（由调用方驱动）。
  final bool scrolling;

  /// 是否画边缘高光与内阴影。极小的面板（< 40dp）可以关掉，省一次 paint。
  final bool specular;

  /// 首次挂载时用弹簧做「材料凝结」（scale 0.96→1 + fade）。
  final bool materialize;

  /// 覆盖模糊半径（调试用）；null 时按 [tier] 与 [scrolling] 取值。
  /// 传 0 = 不采背板（入口卡 / 统计卡这类同屏多层的场景）。
  final double? blurSigma;

  /// 是否响应按压（下沉 1.5px + 内阴影加深）。
  /// 只给可点的玻璃用：Dock、迷你条、sheet、入口卡、播放控制面。
  /// 大块可滚动面板不要开，否则滑动时会跟着「陷」。
  final bool pressable;

  /// 桌面指针悬停时的「弹性够向指针」：沿指针方向轻微拉伸 + 平移，
  /// 离开时回到原位（对照稿 `elasticity` / `calculateDirectionalScale`）。
  ///
  /// 只在鼠标平台上开（Windows 桌面 shell 的顶栏 / 播放栏），触屏没有
  /// hover 语义，开了也不会触发。
  final bool hoverElastic;

  static const Duration _colorDuration = GlassMotion.color;

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass>
    with TickerProviderStateMixin {
  late final AnimationController _material;
  late final AnimationController _press;
  late final AnimationController _hover;
  final ValueNotifier<Offset> _light = ValueNotifier(Offset.zero);
  final ValueNotifier<Offset> _hoverNorm = ValueNotifier(Offset.zero);

  bool _started = false;
  bool _pressed = false;

  /// 折射 shader（A 档）。加载失败 / 不支持时保持 null，自动退回 B 档。
  ui.FragmentShader? _shader;
  bool _shaderRequested = false;

  @override
  void initState() {
    super.initState();
    _material = AnimationController.unbounded(
      vsync: this,
      value: widget.materialize ? 0 : 1,
    );
    _press = AnimationController.unbounded(vsync: this, value: 0);
    _hover = AnimationController(vsync: this, duration: GlassMotion.hover);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && widget.materialize) {
      _started = true;
      if (_noMotion) {
        _material.value = 1;
      } else {
        // 弹簧从当前值出发 → 可打断：中途再次挂载/重建不会跳。
        _material.animateWith(
          SpringSimulation(GlassMotion.settle, _material.value, 1, 0),
        );
      }
    }
    _ensureShader();
  }

  MediaQueryData get _mq => MediaQuery.of(context);

  bool get _noMotion => _mq.disableAnimations || _mq.accessibleNavigation;

  /// 只在指针事件里用来换算归一化坐标。首帧/未 layout 时返回 [Size.zero]，
  /// 绝不直接读 `context.size`（未 layout 的 RenderBox 会抛 hasSize 断言）。
  Size get _boxSize {
    final ro = context.findRenderObject();
    return ro is RenderBox && ro.hasSize ? ro.size : Size.zero;
  }

  /// 面板左上角在屏幕上的位置（逻辑像素）。只给折射 shader 的
  /// `u_origin` 用，**绝不在布局阶段计算**——布局回调里祖先的
  /// `RenderTransform` 可能尚未 layout，`localToGlobal` 会直接断言失败。
  Offset _screenOrigin = Offset.zero;
  Size _screenSize = Size.zero;
  bool _originScheduled = false;

  /// 帧后量一次真实位置；只有真的动了才 `setState`（下拉刷新 / 滚动时
  /// 每帧最多一次，代价等同于一次普通 rebuild）。
  void _scheduleOriginRefresh(Size size) {
    if (!GlassQuality.refractionAllowed) return;
    if (_originScheduled) return;
    _originScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _originScheduled = false;
      if (!mounted) return;
      final ro = context.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize) return;
      final origin = ro.localToGlobal(Offset.zero);
      if (origin != _screenOrigin || size != _screenSize) {
        _screenOrigin = origin;
        _screenSize = size;
        setState(() {});
      }
    });
  }

  /// A 档只在「有可能用到」时才去加载 shader：B 档 / 非 Impeller 下是空操作。
  void _ensureShader() {
    if (_shaderRequested || _shader != null) return;
    if (!GlassQuality.refractionAllowed) return;
    if (!ui.ImageFilter.isShaderFilterSupported) return;
    _shaderRequested = true;
    // ignore: discarded_futures
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/glass_refract.frag',
      );
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (error) {
      // 不是所有平台都能编译 runtime shader（例如桌面老驱动）。
      // 失败就永远停在 B 档，不重试、不影响观感。
      debugPrint('[liquid-glass] 折射 shader 不可用，退回 B 档：$error');
    }
  }

  @override
  void dispose() {
    _material.dispose();
    _press.dispose();
    _hover.dispose();
    _light.dispose();
    _hoverNorm.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (!widget.pressable || _pressed == value) return;
    _pressed = value;
    if (_noMotion) {
      _press.value = value ? 1 : 0;
      return;
    }
    // animateWith 顶替上一段模拟，且从当前值出发 → 快速连按不跳。
    _press.animateWith(
      SpringSimulation(GlassMotion.press, _press.value, value ? 1 : 0, 0),
    );
  }

  void _moveLight(Offset local, Size box) {
    if (!widget.specular || box.isEmpty) return;
    final nx = (local.dx / box.width - 0.5) * 2;
    final ny = (local.dy / box.height - 0.5) * 2;
    _light.value = Offset(
      nx.clamp(-1.0, 1.0) * GlassMotion.specularTravel,
      ny.clamp(-1.0, 1.0) * GlassMotion.specularTravel,
    );
  }

  /// 记录指针在面板内的归一化位置，并把悬停动效推进 / 收回。
  /// 只在 [LiquidGlass.hoverElastic] 打开时生效，触屏不会走到这里。
  void _updateElastic(Offset local, Size box) {
    if (!widget.hoverElastic || box.isEmpty) return;
    final nx = ((local.dx / box.width - 0.5) * 2).clamp(-1.0, 1.0);
    final ny = ((local.dy / box.height - 0.5) * 2).clamp(-1.0, 1.0);
    _hoverNorm.value = Offset(nx, ny);
    if (_hover.value < 1 && !_hover.isAnimating) {
      _hover.animateTo(1, curve: Curves.easeOutCubic);
    }
  }

  void _endElastic() {
    if (!widget.hoverElastic) return;
    _hoverNorm.value = Offset.zero;
    _hover.animateTo(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final mq = _mq;
    final spec = GlassSpec.resolve(widget.tier, isLight: theme.isLight);

    // 嵌套保护：父级已经是玻璃时不再模糊，否则一个屏幕上会出现两层
    // BackdropFilter 互相采样，既贵又糊。
    final depth = _GlassDepth.of(context);
    final nested = depth > 0;

    // Flutter 没有「降低透明度」的直接信号；高对比度是最接近的替代。
    final reduceTransparency = mq.highContrast;

    final effectsOn =
        OvertoneTheme.glassEffectsEnabled && !nested && !reduceTransparency;

    final sigma =
        widget.blurSigma ??
        (widget.scrolling ? spec.scrollingSigma : spec.blurSigma);
    final baseScrim = widget.scrim ?? spec.scrim;
    final tintedScrim = widget.tint == null
        ? baseScrim
        : Color.lerp(baseScrim, widget.tint, spec.tintStrength)!;
    final panelScrim = effectsOn
        ? tintedScrim
        : tintedScrim.withValues(alpha: 1.0);

    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.radius);

    // 模糊开销 > 0 时才真的采样背板。调用方可以传 blurSigma: 0 表示
    // 「只要玻璃的质感（底色 + 高光 + 内阴影），不要背板采样」。
    final useBlur = effectsOn && GlassQuality.backdropAllowed && sigma > 0;

    final dpr = mq.devicePixelRatio;

    final panel = AnimatedContainer(
      duration: LiquidGlass._colorDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: _sheen(panelScrim, spec),
      ),
      child: CustomPaint(
        foregroundPainter: widget.specular
            ? _LiquidGlassPainter(
                // 非均匀圆角（sheet 只有上圆角）时按直角画 rim：四角圆弧
                // 会在底部露出两条不该存在的弧线，直线 rim 交给 ClipRRect 修剪。
                radius: widget.borderRadius == null ? widget.radius : 0,
                spec: spec,
                light: _light,
                press: _press,
                hover: _hover,
                repaint: Listenable.merge([_light, _press, _hover]),
              )
            : null,
        child: Padding(
          padding: widget.padding ?? spec.padding,
          child: widget.child,
        ),
      ),
    );

    Widget glass = panel;

    if (useBlur) {
      glass = LayoutBuilder(
        builder: (context, box) {
          // 注意：这里处在「布局回调」里，祖先的 RenderTransform 可能还没
          // layout，此时 `localToGlobal` 会读祖先 size 并触发
          // `hasSize` 断言（bottom sheet / 页面切换过渡里必现）。
          // 所以 origin 一律走「帧后刷新 + 缓存」，本帧先用上一帧的值。
          final origin = _screenOrigin;
          _scheduleOriginRefresh(box.biggest);
          final filter = _buildFilter(
            spec: spec,
            size: box.biggest,
            origin: origin,
            sigma: sigma,
            dpr: dpr,
          );
          return BackdropFilter(filter: filter, child: panel);
        },
      );
    }

    // 按压整体下沉 1.5px（对照稿 `.lg:active{translate:0 1.5px}`）。
    // 静止时不插入 Transform 图层：避免多余的 RenderTransform 参与
    // hit-test / 合成，也避免它在极早期帧里被误读尺寸。
    glass = AnimatedBuilder(
      animation: _press,
      builder: (context, child) {
        final t = _press.value.clamp(0.0, 1.0);
        if (t <= 0.001) return child!;
        return Transform.translate(
          offset: Offset(0, GlassMotion.pressOffset * t),
          child: child,
        );
      },
      child: glass,
    );

    glass = Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: widget.shadow ?? spec.shadow,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: glass),
    );

    // 桌面悬停的弹性拉伸（对照稿 `calculateDirectionalScale`）：
    // 沿指针方向拉长一点、垂直方向压一点，同时向指针平移 ≤1.6px。
    // 必须包在 Container / ClipRRect 之外：否则缩放会被裁回原尺寸。
    if (widget.hoverElastic) {
      // 尺寸取上一帧已 layout 的值（首帧为 Size.zero → 位移为 0，不报错）。
      final hoverBox = _boxSize;
      glass = AnimatedBuilder(
        animation: Listenable.merge([_hover, _hoverNorm]),
        builder: (context, child) {
          final t = _hover.value;
          if (t <= 0.001) return child!;
          final dir = _hoverNorm.value;
          final sx =
              1 +
              (dir.dx.abs() * GlassMotion.hoverStretch -
                      dir.dy.abs() * GlassMotion.hoverStretch * 0.5) *
                  t;
          final sy =
              1 +
              (dir.dy.abs() * GlassMotion.hoverStretch -
                      dir.dx.abs() * GlassMotion.hoverStretch * 0.5) *
                  t;
          final dx =
              (dir.dx * hoverBox.width * GlassMotion.hoverShift).clamp(
                -GlassMotion.hoverMaxShift,
                GlassMotion.hoverMaxShift,
              ) *
              t;
          final dy =
              (dir.dy * hoverBox.height * GlassMotion.hoverShift).clamp(
                -GlassMotion.hoverMaxShift,
                GlassMotion.hoverMaxShift,
              ) *
              t;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(sx, sy, 1)
              ..setTranslationRaw(dx, dy, 0),
            child: child,
          );
        },
        child: glass,
      );
    }

    // 指针 / 触摸追踪：只更新高光层（painter 用 repaint listenable），
    // 不触发背板重采。尺寸只在已 layout 时读，避免首帧零尺寸下取值。
    glass = Listener(
      onPointerDown: (event) {
        _setPressed(true);
        _moveLight(event.localPosition, _boxSize);
      },
      onPointerMove: (event) {
        _moveLight(event.localPosition, _boxSize);
      },
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: MouseRegion(
        onHover: (event) {
          _moveLight(event.localPosition, _boxSize);
          _updateElastic(event.localPosition, _boxSize);
        },
        onExit: (_) {
          _light.value = Offset.zero;
          _endElastic();
        },
        child: glass,
      ),
    );

    // 材料凝结：scale + fade 一起走，读起来是「一层材料长出来」，
    // 而不是一张图片淡入。到位后不再保留 Transform/Opacity 图层。
    if (widget.materialize) {
      glass = AnimatedBuilder(
        animation: _material,
        builder: (context, child) {
          final t = _material.value.clamp(0.0, 1.2);
          if ((t - 1).abs() < 0.004) return child!;
          final scale =
              GlassMotion.materializeScale +
              (1 - GlassMotion.materializeScale) * t;
          return Opacity(
            opacity: (0.82 + 0.18 * t).clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: glass,
      );
    }

    return _GlassDepth(
      depth: depth + 1,
      child: RepaintBoundary(child: glass),
    );
  }

  /// 组装 filter 链：折射 → 模糊 → 饱和度/对比度（与对照稿
  /// `url(#svg) blur() saturate() contrast()` 同一顺序）。
  ui.ImageFilter _buildFilter({
    required GlassSpec spec,
    required Size size,
    required Offset origin,
    required double sigma,
    required double dpr,
  }) {
    final matrix = ui.ColorFilter.matrix(
      glassColorMatrix(spec.saturation, spec.contrast),
    );
    final blur = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

    final shader = _shader;
    final refraction =
        shader != null &&
        GlassQuality.refractionAllowed &&
        ui.ImageFilter.isShaderFilterSupported &&
        size.width > 2 &&
        size.height > 2;

    if (!refraction) {
      return ui.ImageFilter.compose(inner: blur, outer: matrix);
    }

    final box = Size(size.width * dpr, size.height * dpr);
    final radius =
        math.min(
          widget.borderRadius == null ? widget.radius : 0,
          math.min(size.width, size.height) / 2,
        ) *
        dpr;
    final bandMin = math.min(size.width, size.height) * 0.42;

    shader
      ..setFloat(0, box.width)
      ..setFloat(1, box.height)
      ..setFloat(2, box.width)
      ..setFloat(3, box.height)
      ..setFloat(4, radius)
      ..setFloat(5, math.min(spec.band, bandMin) * dpr)
      ..setFloat(6, GlassQuality.dispersionAllowed ? spec.dispersion : 0)
      ..setFloat(7, math.min(spec.band, bandMin) * GlassMotion.peakRatio * dpr)
      ..setFloat(8, origin.dx * dpr)
      ..setFloat(9, origin.dy * dpr)
      ..setImageSampler(0, _backdropPlaceholder);

    final refract = ui.ImageFilter.shader(shader);
    return ui.ImageFilter.compose(
      inner: ui.ImageFilter.compose(inner: refract, outer: blur),
      outer: matrix,
    );
  }
}

/// `ImageFilter.shader` 要求「至少一个 sampler2D，第一个由引擎绑定为
/// filter input」。Dart 侧仍要传一个占位 texture 让 uniform 合法，
/// 引擎会在滤镜执行时替换成背板快照。
final ui.Image _backdropPlaceholder = _placeholderImage();

ui.Image _placeholderImage() {
  final recorder = ui.PictureRecorder();
  Canvas(
    recorder,
  ).drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.black);
  // 只需要「一个合法的 1×1 image」。用 toImageSync 避免把首帧卡在异步等图上。
  return recorder.endRecording().toImageSync(1, 1);
}

/// 底色内的明暗渐变：顶部白涂层（对照稿 `.lg` 的第一层 gradient）
/// + 玻璃底色（`--tintA`）。
LinearGradient _sheen(Color scrim, GlassSpec spec) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.alphaBlend(spec.sheenTop, scrim),
      Color.alphaBlend(
        spec.sheenTop.withValues(alpha: spec.sheenTop.a * 0.3),
        scrim,
      ),
      scrim,
      Color.alphaBlend(
        spec.sheenTop.withValues(alpha: spec.sheenTop.a * 0.18),
        scrim,
      ),
    ],
    stops: const [0.0, 0.24, 0.52, 1.0],
  );
}

/// Rec.709 亮度权重的饱和度矩阵 + 对比度（20 个分量，行主序，平移列保留）。
///
/// 叠在高斯模糊之后，把透出来的背板颜色「提鲜」——这是玻璃和磨砂塑料
/// 最大的观感差别之一。对照稿：saturate 1.62 / contrast 1.06。
///
/// 对比度在 0..255 空间是 `out = c·in + 127.5·(1−c)`，所以把饱和度矩阵
/// 整体乘 c、平移列补 127.5·(1−c) 即可一次矩阵搞定，不用套两层
/// `ColorFilter`。
List<double> glassColorMatrix(double s, [double c = 1.06]) {
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  final t = 127.5 * (1 - c);
  return [
    (r + (1 - r) * s) * c, (g - g * s) * c, (b - b * s) * c, 0, t, //
    (r - r * s) * c, (g + (1 - g) * s) * c, (b - b * s) * c, 0, t, //
    (r - r * s) * c, (g - g * s) * c, (b + (1 - b) * s) * c, 0, t, //
    0, 0, 0, 1, 0, //
  ];
}

/// 玻璃的嵌套深度。只用于「禁止玻璃套玻璃」这一条硬约束。
class _GlassDepth extends InheritedWidget {
  const _GlassDepth({required this.depth, required super.child});

  final int depth;

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlassDepth>()?.depth ?? 0;

  @override
  bool updateShouldNotify(_GlassDepth oldWidget) => oldWidget.depth != depth;
}

/// 一趟 paint 画完「边缘高光 + 内阴影 + 按压阴影」。
///
/// 绘制顺序（光源左上 45°）：
/// 1. 左上柔光（中心随指针在 ±10px 内移动；按压时更强）；
/// 2. 顶部内侧受光带；
/// 3. 底部内侧收暗带；
/// 4. 按压时自上而下的内阴影（α0.38 起，16px 高）；
/// 5. 1px 渐变描边（顶 .86 → 46% .07 → 68% 0 → 底 .16）。
class _LiquidGlassPainter extends CustomPainter {
  _LiquidGlassPainter({
    required this.radius,
    required this.spec,
    required this.light,
    required this.press,
    required this.hover,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final double radius;
  final GlassSpec spec;
  final ValueListenable<Offset> light;
  final Animation<double> press;
  final Animation<double> hover;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 2 || size.height <= 2) return;
    final p = press.value.clamp(0.0, 1.0);
    final r = math.min(radius, math.min(size.width, size.height) / 2);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(math.max(r, 0)),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    // 1. 左上柔光：中心 26% / −6%，随指针/触摸 ±10px。
    final glint = Color.lerp(spec.glint, spec.pressGlint, p)!;
    final dx = light.value.dx;
    final dy = light.value.dy;
    final center = Alignment(
      -1 + 2 * (0.26 * size.width + dx) / size.width,
      -1 + 2 * (-0.06 * size.height + dy) / size.height,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          center: center,
          radius: 1.25,
          colors: [
            glint,
            glint.withValues(alpha: glint.a * 0.19),
            glint.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.38, 0.68],
        ).createShader(Offset.zero & size),
    );

    // 1b. 悬停 / 按压时顶部中心的第二层柔光（对照稿 hover overlay：
    //     `radial-gradient(circle at 50% 0%, #fff, transparent)`）。
    final sheenT = math.max(hover.value.clamp(0.0, 1.0), p);
    if (spec.glint.a > 0 && sheenT > 0.01) {
      final rect = Offset.zero & size;
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.overlay
          ..shader = RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [
              spec.glint.withValues(
                alpha: spec.glint.a * GlassMotion.hoverSheenAlpha * sheenT,
              ),
              spec.glint.withValues(alpha: 0),
            ],
            stops: const [0.0, 1.0],
          ).createShader(rect),
      );
    }

    // 2. 顶部内侧受光带。
    if (spec.innerTop.a > 0) {
      final h = spec.innerDepth;
      final rect = Rect.fromLTWH(0, 0, size.width, h);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [spec.innerTop, spec.innerTop.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    // 3. 底部内侧收暗带（比顶部更深，因为材料厚度投在下沿）。
    final innerBottom = Color.lerp(
      spec.innerBottom,
      spec.innerBottom.withValues(alpha: math.min(1, spec.innerBottom.a * 1.6)),
      p,
    )!;
    if (innerBottom.a > 0) {
      final h = spec.innerDepth * 1.4;
      final rect = Rect.fromLTWH(0, size.height - h, size.width, h);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [innerBottom.withValues(alpha: 0), innerBottom],
          ).createShader(rect),
      );
    }

    // 4. 按压内阴影：对照稿 `inset 0 3px 16px rgba(0,0,0,.38)`。
    if (p > 0.01) {
      final h = 16.0;
      final rect = Rect.fromLTWH(0, 0, size.width, h);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              spec.pressInner.withValues(alpha: spec.pressInner.a * p),
              spec.pressInner.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    canvas.restore();

    // 5. 1px 渐变描边：顶亮、46% 之后几乎消失、底沿再回一点。
    //    渐变角随指针在 ±rimTiltDegrees 内倾斜（对照稿两条边框层
    //    `linear-gradient(135 + mouseOffset.x*1.2deg)` 的可移植部分）。
    final tilt =
        (light.value.dx / GlassMotion.specularTravel) *
        GlassMotion.rimTiltDegrees *
        (math.pi / 180.0);
    final rimDir = Offset(math.sin(tilt), math.cos(tilt));
    final rimRect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final rimPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rimRect, Radius.circular(math.max(r - 0.5, 0))),
      );
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment(-rimDir.dx, -rimDir.dy),
          end: Alignment(rimDir.dx, rimDir.dy),
          colors: [
            spec.rimTop,
            spec.rimTop.withValues(alpha: spec.rimTop.a * 0.35),
            spec.rimTop.withValues(alpha: spec.rimTop.a * 0.08),
            spec.rimTop.withValues(alpha: 0),
            spec.rimBottom,
          ],
          stops: const [0.0, 0.12, 0.46, 0.68, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_LiquidGlassPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.spec != spec;
}
