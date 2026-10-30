import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/source/capabilities.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../shared/widgets/smooth_scroll.dart';
import 'bili_login_controller.dart';
import 'package:overtone/l10n/l10n.dart';

class BiliLoginPage extends ConsumerStatefulWidget {
  const BiliLoginPage({super.key, this.forceRelogin = false});
  final bool forceRelogin;
  @override
  ConsumerState<BiliLoginPage> createState() => _BiliLoginPageState();
}

class _BiliLoginPageState extends ConsumerState<BiliLoginPage> {
  late BiliLoginController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ref.read(biliLoginControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.forceRelogin) {
        _controller.startQr();
      } else {
        _controller.bootstrap();
      }
    });
  }

  @override
  void dispose() {
    _controller.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biliLoginControllerProvider);
    return Scaffold(
      appBar: AppBar(title:  Text(context.l10n.biLiBiLiZhangHao)),
      body: SmoothSingleChildScrollView(
        padding: const EdgeInsets.all(OvertoneSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.account case final account?) ...[
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(account.nickname),
                subtitle: Text('UID ${account.userId}'),
              ),
              TextButton(
                onPressed: _controller.startQr,
                child:  Text(context.l10n.qieHuanZhangHao),
              ),
              TextButton(
                onPressed: _controller.logout,
                child:  Text(context.l10n.tuiChuDengLu),
              ),
            ] else ...[
               Text(context.l10n.daKaiBiLiBiLiAppSaoYiSaoSaoMaHouZaiShouJiShangQu),
              const SizedBox(height: OvertoneSpacing.xl),
              if (state.loading)
                const Center(child: CircularProgressIndicator()),
              if (state.session != null &&
                  state.status != LoginQrStatus.expired)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: QrImageView(
                      data: state.session!.qrContent,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: OvertoneSpacing.lg),
              Text(switch (state.status) {
                LoginQrStatus.scanned => context.l10n.yiSaoMaQingZaiShouJiShangQueRen,
                LoginQrStatus.expired => context.l10n.erWeiMaYiGuoQiQingShuaXin,
                _ => context.l10n.dengDaiSaoMa,
              }, textAlign: TextAlign.center),
              if (state.error.isNotEmpty)
                Text(state.error, textAlign: TextAlign.center),
              TextButton(
                onPressed: _controller.startQr,
                child:  Text(context.l10n.shuaXinErWeiMa),
              ),
            ],
            const SizedBox(height: OvertoneSpacing.xl),
             Text(
              context.l10n.dengLuPingJuJinCunBenJiTuiChuDengLuJiQingChu,
            ),
          ],
        ),
      ),
    );
  }
}
