import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import 'auth_controller.dart';
import '../../shared/widgets/smooth_scroll.dart';
import 'package:overtone/l10n/l10n.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscureCode = true;
  bool _obscurePwd = true;

  /// Captured in initState: `ref` is unusable from dispose().
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auth.startQrLogin();
    });
  }

  @override
  void dispose() {
    _auth.stopQrPolling();
    _tabs.dispose();
    _phone.dispose();
    _code.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _popIfLogged() async {
    // Navigation handled by ref.listen → context.go('/profile').
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    // Any successful login (QR / SMS / password) → back to 我的 tab.
    ref.listen(authControllerProvider, (prev, next) {
      final wasLogged = prev?.isLogged ?? false;
      if (next.isLogged && !wasLogged && mounted) {
        context.go('/profile');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title:  Text(context.l10n.dengLu),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: theme.primary,
          labelColor: theme.primary,
          unselectedLabelColor: theme.textSecondary,
          tabs:  [
            Tab(text: context.l10n.saoMa),
            Tab(text: context.l10n.yanZhengMa),
            Tab(text: context.l10n.zhangHao),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: [
            // --- QR ---
            _QrLoginView(
              auth: auth,
              onRefresh: controller.startQrLogin,
            ),
            // --- SMS ---
            SmoothListView(
              padding: const EdgeInsets.all(OvertoneSpacing.xl),
              children: [
                Text(context.l10n.shouJiYanZhengMaDengLu, style: theme.section),
                const SizedBox(height: 8),
                Text(
                  context.l10n.shiYongKuGouBangDingShouJiHaoJieShouDuanXinYanZh,
                  style: theme.caption,
                ),
                const SizedBox(height: OvertoneSpacing.xl),
                _Field(
                  controller: _phone,
                  hint: context.l10n.shouJiHao,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: OvertoneSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _code,
                        hint: context.l10n.yanZhengMa,
                        keyboardType: TextInputType.number,
                        obscure: _obscureCode,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureCode
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureCode = !_obscureCode),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: auth.smsCountdown > 0
                            ? null
                            : () => controller.sendSmsCode(_phone.text),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(OvertoneRadius.button),
                          ),
                        ),
                        child: Text(
                          auth.smsCountdown > 0
                              ? '${auth.smsCountdown}s'
                              : context.l10n.huoQuYanZhengMa,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OvertoneSpacing.lg),
                if (auth.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: OvertoneSpacing.md),
                    child: Text(
                      auth.errorMessage,
                      style: theme.caption.copyWith(
                        color: auth.status == LoginStatus.logged
                            ? theme.primary
                            : theme.danger,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: auth.status == LoginStatus.loading
                      ? null
                      : () async {
                          final ok = await controller.loginWithSms(
                            phone: _phone.text,
                            code: _code.text,
                          );
                          if (ok) await _popIfLogged();
                        },
                  child: auth.status == LoginStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      :  Text(context.l10n.dengLu),
                ),
              ],
            ),
            // --- Password ---
            SmoothListView(
              padding: const EdgeInsets.all(OvertoneSpacing.xl),
              children: [
                Text(context.l10n.zhangHaoMiMaDengLu, style: theme.section),
                const SizedBox(height: 8),
                Text(
                  context.l10n.kuGouZhangHaoShouJiHaoMiMa,
                  style: theme.caption,
                ),
                const SizedBox(height: OvertoneSpacing.xl),
                _Field(controller: _username, hint: context.l10n.zhangHaoShouJiHao),
                const SizedBox(height: OvertoneSpacing.md),
                _Field(
                  controller: _password,
                  hint: context.l10n.miMa,
                  obscure: _obscurePwd,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePwd
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePwd = !_obscurePwd),
                  ),
                ),
                const SizedBox(height: OvertoneSpacing.lg),
                if (auth.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: OvertoneSpacing.md),
                    child: Text(
                      auth.errorMessage,
                      style: theme.caption
                          .copyWith(color: theme.danger),
                    ),
                  ),
                FilledButton(
                  onPressed: auth.status == LoginStatus.loading
                      ? null
                      : () async {
                          final ok = await controller.loginWithPassword(
                            username: _username.text,
                            password: _password.text,
                          );
                          if (ok) await _popIfLogged();
                        },
                  child: auth.status == LoginStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      :  Text(context.l10n.dengLu),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            OvertoneSpacing.xl,
            0,
            OvertoneSpacing.xl,
            OvertoneSpacing.lg,
          ),
          child: OutlinedButton.icon(
            onPressed: () async {
              await controller.continueAsGuest();
              if (context.mounted) context.pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.textPrimary,
              side: BorderSide(color: theme.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(OvertoneRadius.button),
              ),
            ),
            icon: const Icon(Icons.person_outline_rounded, size: 20),
            label:  Text(context.l10n.youKeJiXuXianTingGe),
          ),
        ),
      ),
    );
  }
}

class _QrLoginView extends StatelessWidget {
  const _QrLoginView({required this.auth, required this.onRefresh});

  final AuthState auth;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final phase = auth.qrPhase;
    final url = auth.qrContentUrl;

    Widget center;
    if (phase == QrPhase.loading) {
      center = const CircularProgressIndicator();
    } else if (phase == QrPhase.waiting ||
        phase == QrPhase.scanned ||
        phase == QrPhase.success) {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(OvertoneRadius.card),
            ),
            child: QrImageView(
              data: url,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: OvertoneSpacing.lg),
          Text(
            switch (phase) {
              QrPhase.scanned => context.l10n.yiSaoMaQingZaiShouJiShangQueRen,
              QrPhase.success => context.l10n.dengLuChengGong,
              _ => context.l10n.qingYongKuGouAppSaoMaDengLu,
            },
            style: theme.body,
          ),
          if (phase == QrPhase.waiting) ...[
            const SizedBox(height: 8),
            Text(context.l10n.mei3MiaoZiDongJianCe, style: theme.caption),
          ],
        ],
      );
    } else if (phase == QrPhase.expired) {
      center = _StatusBox(
        icon: Icons.qr_code_2_rounded,
        message: context.l10n.erWeiMaYiGuoQi,
        actionLabel: context.l10n.shuaXin,
        onAction: onRefresh,
      );
    } else {
      center = _StatusBox(
        icon: Icons.wifi_off_rounded,
        message: auth.errorMessage.isEmpty
            ? context.l10n.erWeiMaJiaZaiShiBai
            : auth.errorMessage,
        actionLabel: context.l10n.chongShi,
        onAction: onRefresh,
      );
    }

    return SmoothSingleChildScrollView(
      padding: const EdgeInsets.all(OvertoneSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.kuGouSaoMaDengLu, style: theme.section),
          const SizedBox(height: 8),
          Text(
            context.l10n.daKaiShouJiKuGouSaoYiSaoDengLuHouKeTongBuXiHuanY,
            style: theme.caption,
          ),
          const SizedBox(height: OvertoneSpacing.xxl),
          Center(child: center),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: theme.textTertiary),
        const SizedBox(height: OvertoneSpacing.md),
        Text(message, style: theme.caption, textAlign: TextAlign.center),
        const SizedBox(height: OvertoneSpacing.lg),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: theme.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.caption,
        filled: true,
        fillColor: theme.surface,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OvertoneRadius.tile),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
