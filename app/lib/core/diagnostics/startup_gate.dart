import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overtone/l10n/app_localizations.dart';
import 'package:overtone/l10n/l10n.dart';

/// The shell is drawn before any service waits. Timed-out work is not treated
/// as cancelled: retry is enabled only after it actually settles, avoiding
/// overlapping player/container/native service initializations.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.initialize,
    required this.onError,
    this.timeout = const Duration(seconds: 30),
  });

  final Future<Widget> Function() initialize;
  final void Function(Object, StackTrace) onError;
  final Duration timeout;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  Widget? _app;
  bool _running = false;
  bool _timedOut = false;
  Object? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _running = true;
      _timedOut = false;
      _error = null;
    });
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (mounted && _running) setState(() => _timedOut = true);
    });
    try {
      final app = await widget.initialize();
      if (mounted) setState(() => _app = app);
    } catch (error, stack) {
      widget.onError(error, stack);
      if (mounted) setState(() => _error = error);
    } finally {
      _timer?.cancel();
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = _app;
    if (app != null) return app;
    return MaterialApp(
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_running && !_timedOut) const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _error != null
                      ? l10n.fanYinQiDongShiBaiQingJianChaXiTongQuanXianH(_error.runtimeType)
                      : _timedOut
                      ? l10n.qiDongFuWuXiangYingChaoShiRengZaiDengDaiDangQian
                      : l10n.zhengZaiQiDongFanYin,
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                   Text(l10n.xiangXiJiLuJianYingYongMuLuCrashLog),
                  TextButton(
                    onPressed: _running ? null : _start,
                    child:  Text(l10n.chongShi),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
