import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/smooth_scroll.dart';

/// 液态玻璃材质的独立示范页。
///
/// 演示背板模糊、Shader 边缘折射与色散、半透明染色、高光描边和按压反馈。
/// 不接真实播放数据；不支持 ImageFilter.shader 的平台自动退回 bounded blur。
/// 后续若推广到生产组件，可再抽出卡片原语。
class LiquidGlassDemoPage extends StatefulWidget {
  const LiquidGlassDemoPage({super.key});

  @override
  State<LiquidGlassDemoPage> createState() => _LiquidGlassDemoPageState();
}

class _LiquidGlassDemoPageState extends State<LiquidGlassDemoPage> {
  bool _effectsEnabled = true;
  bool _refractionEnabled = true;
  bool _shaderFailed = false;
  bool _playing = false;
  bool _favorite = false;
  double _progress = 0.36;
  ui.FragmentProgram? _refractionProgram;

  @override
  void initState() {
    super.initState();
    _loadRefractionShader();
  }

  Future<void> _loadRefractionShader() async {
    if (!ui.ImageFilter.isShaderFilterSupported) return;
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/glass_refract.frag',
      );
      // 在交给卡片前先验证滤镜的 uniform / sampler 契约，失败则整页走模糊降级。
      final probe = program.fragmentShader();
      try {
        ui.ImageFilter.shader(probe);
      } finally {
        probe.dispose();
      }
      if (!mounted) return;
      setState(() => _refractionProgram = program);
    } catch (error) {
      if (!mounted) return;
      setState(() => _shaderFailed = true);
      debugPrint('[liquid-glass-demo] 折射 Shader 不可用，已退回模糊玻璃：$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(title: Text(context.l10n.yeTaiBoLi)),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GlassBackdropPainter(theme)),
            ),
          ),
          DesktopContentConstraint.form(
            child: SmoothListView(
              // 横向 padding 同设置页：留足投影外溢余量，避免被视口硬裁。
              padding: const EdgeInsets.fromLTRB(
                OvertoneSpacing.xl,
                OvertoneSpacing.sm,
                OvertoneSpacing.xl,
                40,
              ),
              children: [
                Text(
                  context.l10n.yeTaiBoLiJieShao,
                  style: theme.caption.copyWith(height: 1.6),
                ),
                const SizedBox(height: OvertoneSpacing.xl),
                _LiquidGlassCard(
                  effectsEnabled: _effectsEnabled,
                  refractionEnabled: _refractionEnabled,
                  refractionProgram: _refractionProgram,
                  child: _buildBasicCard(theme),
                ),
                const SizedBox(height: OvertoneSpacing.lg),
                _LiquidGlassCard(
                  effectsEnabled: _effectsEnabled,
                  refractionEnabled: _refractionEnabled,
                  refractionProgram: _refractionProgram,
                  child: _buildPlayerCard(theme),
                ),
                const SizedBox(height: OvertoneSpacing.lg),
                _LiquidGlassCard(
                  effectsEnabled: _effectsEnabled,
                  refractionEnabled: _refractionEnabled,
                  refractionProgram: _refractionProgram,
                  child: _buildEffectSwitch(theme),
                ),
                const SizedBox(height: OvertoneSpacing.lg),
                _LiquidGlassCard(
                  effectsEnabled: _effectsEnabled,
                  refractionEnabled: _refractionEnabled,
                  refractionProgram: _refractionProgram,
                  onTap: () {},
                  child: _buildPressDemo(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicCard(OvertoneTheme theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(OvertoneRadius.cover),
            border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 24,
            color: theme.primary,
          ),
        ),
        const SizedBox(width: OvertoneSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.jiChuBoLiKaPian, style: theme.section),
              const SizedBox(height: OvertoneSpacing.xs),
              Text(
                context.l10n.jiChuBoLiKaPianMiaoShu,
                style: theme.caption.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(OvertoneTheme theme) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withValues(alpha: 0.9),
                    theme.favorite.withValues(alpha: 0.72),
                  ],
                ),
                borderRadius: BorderRadius.circular(OvertoneRadius.cover),
                boxShadow: theme.shadowTile,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: OvertoneSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('玻璃海', style: theme.section),
                  const SizedBox(height: OvertoneSpacing.xs),
                  Text(
                    '${context.l10n.zhengZaiBoFang} · ${context.l10n.caiZhiYangLi}',
                    style: theme.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.xiHuan,
              onPressed: () => setState(() => _favorite = !_favorite),
              icon: Icon(
                _favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 24,
                color: _favorite ? theme.favorite : theme.textSecondary,
              ),
            ),
          ],
        ),
        Slider(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
        ),
        Row(
          children: [
            Text('01:24', style: theme.caption),
            const Spacer(),
            Text('03:48', style: theme.caption),
          ],
        ),
        const SizedBox(height: OvertoneSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: context.l10n.shangYiShou,
              onPressed: () => setState(() => _progress = 0),
              icon: const Icon(Icons.skip_previous_rounded, size: 32),
            ),
            const SizedBox(width: OvertoneSpacing.xl),
            IconButton.filled(
              tooltip: _playing ? context.l10n.zanTing : context.l10n.boFang,
              onPressed: () => setState(() => _playing = !_playing),
              icon: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
            const SizedBox(width: OvertoneSpacing.xl),
            IconButton(
              tooltip: context.l10n.xiaYiShou,
              onPressed: () => setState(() => _progress = 0),
              icon: const Icon(Icons.skip_next_rounded, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEffectSwitch(OvertoneTheme theme) {
    final shaderUnavailable =
        _shaderFailed || !ui.ImageFilter.isShaderFilterSupported;
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.blur_on_rounded, size: 24, color: theme.primary),
            const SizedBox(width: OvertoneSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.boLiXiaoGuo, style: theme.body),
                  const SizedBox(height: OvertoneSpacing.xs),
                  Text(
                    context.l10n.chunSeJiangJiShuoMing,
                    style: theme.caption,
                  ),
                ],
              ),
            ),
            Switch(
              value: _effectsEnabled,
              onChanged: (value) => setState(() => _effectsEnabled = value),
            ),
          ],
        ),
        Divider(height: OvertoneSpacing.xxl, color: theme.divider),
        Row(
          children: [
            Icon(Icons.diamond_outlined, size: 24, color: theme.primary),
            const SizedBox(width: OvertoneSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.shaderZheShe, style: theme.body),
                  const SizedBox(height: OvertoneSpacing.xs),
                  Text(
                    shaderUnavailable
                        ? context.l10n.shaderZheSheBuKeYong
                        : context.l10n.shaderZheSheKeYong,
                    style: theme.caption,
                  ),
                ],
              ),
            ),
            Switch(
              value: _refractionEnabled && _refractionProgram != null,
              onChanged: _refractionProgram == null
                  ? null
                  : (value) => setState(() => _refractionEnabled = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPressDemo(OvertoneTheme theme) {
    return Row(
      children: [
        Icon(Icons.touch_app_rounded, size: 24, color: theme.primary),
        const SizedBox(width: OvertoneSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.anYaShiFan, style: theme.body),
              const SizedBox(height: OvertoneSpacing.xs),
              Text(context.l10n.anYaShiFanShuoMing, style: theme.caption),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: theme.textSecondary),
      ],
    );
  }
}

class _LiquidGlassCard extends StatefulWidget {
  const _LiquidGlassCard({
    required this.child,
    required this.effectsEnabled,
    required this.refractionEnabled,
    required this.refractionProgram,
    this.onTap,
  });

  final Widget child;
  final bool effectsEnabled;
  final bool refractionEnabled;
  final ui.FragmentProgram? refractionProgram;
  final VoidCallback? onTap;

  @override
  State<_LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<_LiquidGlassCard> {
  bool _pressed = false;
  ui.FragmentShader? _refractionShader;

  bool get _useRefraction =>
      widget.effectsEnabled &&
      widget.refractionEnabled &&
      widget.refractionProgram != null &&
      ui.ImageFilter.isShaderFilterSupported;

  @override
  void didUpdateWidget(covariant _LiquidGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectsEnabled != widget.effectsEnabled ||
        oldWidget.refractionEnabled != widget.refractionEnabled ||
        oldWidget.refractionProgram != widget.refractionProgram) {
      _disposeRefractionShader();
    }
  }

  ui.ImageFilter _createRefractionFilter() {
    final shader = _refractionShader ??= widget.refractionProgram!
        .fragmentShader();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // 前两个 float 是引擎写入的纹理尺寸；自定义参数全部使用物理像素。
    shader
      ..setFloat(2, OvertoneRadius.floating * dpr)
      ..setFloat(3, 24 * dpr)
      ..setFloat(4, 9 * dpr)
      ..setFloat(5, 0.045)
      ..setFloat(6, 4 * dpr);
    return ui.ImageFilter.shader(shader);
  }

  void _disposeRefractionShader() {
    _refractionShader?.dispose();
    _refractionShader = null;
  }

  @override
  void dispose() {
    _disposeRefractionShader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final interactive = widget.onTap != null;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);
    final radius = BorderRadius.circular(OvertoneRadius.floating);
    // v2 扁平通透档：低不透明度染色，背景大面积透出（对齐 glass_tokens.dart）。
    final tint = widget.effectsEnabled ? (theme.isLight ? 0.48 : 0.30) : 1.0;
    final shaderFilter = _useRefraction ? _createRefractionFilter() : null;

    return AnimatedScale(
      scale: _pressed && !reduceMotion ? 0.985 : 1,
      duration: animationDuration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: animationDuration,
        decoration: BoxDecoration(
          borderRadius: radius,
          // 令牌两段式投影（对齐 glass_tokens.dart）；按压时收缩到薄档。
          boxShadow: _pressed
              ? GlassTokens.resolve(theme, GlassTier.thin).shadow
              : GlassTokens.resolve(theme, GlassTier.regular).shadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: shaderFilter,
            filterConfig: shaderFilter == null
                ? const ImageFilterConfig.blur(
                    sigmaX: 14,
                    sigmaY: 14,
                    bounded: true,
                  )
                : null,
            enabled: widget.effectsEnabled,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // 竖向（对照稿 180deg）：上薄下重，只做收边，不做对角打光。
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.surfaceElevated.withValues(alpha: tint),
                    theme.surface.withValues(
                      alpha: widget.effectsEnabled
                          ? (tint * 1.25).clamp(0.0, 1.0)
                          : tint,
                    ),
                  ],
                ),
                border: Border.all(
                  color: theme.isLight
                      ? Colors.white.withValues(alpha: 0.30)
                      : Colors.white.withValues(alpha: 0.18),
                ),
                borderRadius: radius,
              ),
              child: Stack(
                children: [
                  if (widget.effectsEnabled) ...[
                    Positioned(
                      top: 0,
                      left: OvertoneSpacing.lg,
                      right: OvertoneSpacing.lg,
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(
                          alpha: theme.isLight ? 0.65 : 0.42,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.4,
                              colors: [
                                Colors.white.withValues(
                                  alpha: theme.isLight ? 0.12 : 0.08,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Semantics(
                    button: interactive,
                    child: MouseRegion(
                      cursor: interactive
                          ? SystemMouseCursors.click
                          : MouseCursor.defer,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onTap,
                        onTapDown: interactive
                            ? (_) => setState(() => _pressed = true)
                            : null,
                        onTapUp: interactive
                            ? (_) => setState(() => _pressed = false)
                            : null,
                        onTapCancel: interactive
                            ? () => setState(() => _pressed = false)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(OvertoneSpacing.xl),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBackdropPainter extends CustomPainter {
  const _GlassBackdropPainter(this.theme);

  final OvertoneTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.bg,
          Color.alphaBlend(theme.primary.withValues(alpha: 0.18), theme.bg),
          Color.alphaBlend(theme.favorite.withValues(alpha: 0.12), theme.bg),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.18),
      size.shortestSide * 0.28,
      Paint()..color = theme.primary.withValues(alpha: 0.34),
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.42),
      size.shortestSide * 0.32,
      Paint()..color = theme.favorite.withValues(alpha: 0.24),
    );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.88),
      size.shortestSide * 0.36,
      Paint()..color = theme.primary.withValues(alpha: 0.2),
    );

    final line = Paint()
      ..color = theme.textPrimary.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var y = 32.0; y < size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 80), line);
    }
  }

  @override
  bool shouldRepaint(_GlassBackdropPainter oldDelegate) =>
      oldDelegate.theme != theme;
}
