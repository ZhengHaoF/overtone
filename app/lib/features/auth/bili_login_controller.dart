import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/network_error_text.dart';
import '../../core/source/capabilities.dart';
import '../../core/source/music_platform.dart';
import '../../data/sources/bili/bili_source.dart';
import '../../data/storage/bili_auth_store.dart';
import '../profile/source_library_controller.dart';
import 'package:overtone/l10n/l10n.dart';

class BiliLoginState {
  const BiliLoginState({
    this.loading = false,
    this.session,
    this.status,
    this.account,
    this.error = '',
  });
  final bool loading;
  final LoginQrSession? session;
  final LoginQrStatus? status;
  final LoginAccount? account;
  final String error;
  bool get isLogged => account != null;
}

/// 串行轮询；刷新/退出/离页使旧请求失效。
class BiliLoginController extends Notifier<BiliLoginState> {
  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;
  DeviceLoginSource get _source => ref.read(biliLoginSourceProvider);
  bool _active(int gen) => !_disposed && gen == _generation;

  @override
  BiliLoginState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _generation++;
      _timer?.cancel();
    });
    Future.microtask(refreshAccount);
    return const BiliLoginState();
  }

  Future<void> refreshAccount() async {
    final gen = _generation;
    try {
      final account = await _source.currentAccount();
      if (_active(gen)) state = BiliLoginState(account: account);
    } catch (e) {
      if (_active(gen)) {
        state = BiliLoginState(
          error: networkErrorText(e, fallback: l10n.dengLuTaiQueRenShiBaiQingChongShi),
        );
      }
    }
  }

  Future<void> bootstrap() async {
    await refreshAccount();
    if (!_disposed && !state.isLogged) await startQr();
  }

  Future<void> startQr() async {
    final gen = ++_generation;
    _timer?.cancel();
    state = const BiliLoginState(loading: true);
    try {
      final session = await _source.createLoginQr();
      if (!_active(gen)) return;
      state = BiliLoginState(session: session, status: LoginQrStatus.waiting);
      _schedule(gen, session);
    } catch (e) {
      if (_active(gen)) {
        state = BiliLoginState(
          error: networkErrorText(e, fallback: l10n.erWeiMaHuoQuShiBaiQingChongShi),
        );
      }
    }
  }

  void _schedule(int gen, LoginQrSession session) {
    _timer = Timer(
      ref.read(biliLoginPollIntervalProvider),
      () => _poll(gen, session),
    );
  }

  Future<void> _poll(int gen, LoginQrSession session) async {
    if (!_active(gen)) return;
    try {
      final poll = await _source.pollLoginQr(session);
      if (!_active(gen)) return;
      if (poll.isConfirmed) {
        final account = await _source.currentAccount();
        if (!_active(gen)) return;
        if (account == null) {
          state =  BiliLoginState(error: l10n.dengLuTaiQueRenShiBaiQingChongShi);
          return;
        }
        var persistenceError = '';
        try {
          await ref
              .read(biliSaveSessionProvider)()
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          persistenceError = l10n.yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa_2;
        }
        if (!_active(gen)) return;
        state = BiliLoginState(
          account: account,
          status: LoginQrStatus.confirmed,
          error: persistenceError,
        );
        ref.invalidate(sourceLibraryProvider(MusicPlatform.bili));
        return;
      }
      state = BiliLoginState(session: session, status: poll.status);
      if (poll.status == LoginQrStatus.expired) return;
    } catch (e) {
      if (!_active(gen)) return;
      state = BiliLoginState(
        session: session,
        status: state.status,
        error: networkErrorText(e, fallback: l10n.dengLuZhuangTaiQueRenShiBaiQingChongShi),
      );
    }
    if (_active(gen)) _schedule(gen, session);
  }

  void stopPolling() {
    _generation++;
    _timer?.cancel();
  }

  Future<void> logout() async {
    stopPolling();
    await _source.logout();
    var error = '';
    try {
      await BiliAuthStore.clear().timeout(const Duration(seconds: 8));
    } catch (_) {
      error = l10n.yiTuiChuDengLuAnQuanCunChuQingLiWeiWanChengQingJ;
    }
    if (_disposed) return;
    state = BiliLoginState(error: error);
    ref.invalidate(sourceLibraryProvider(MusicPlatform.bili));
  }
}

final biliLoginSourceProvider = Provider<DeviceLoginSource>(
  (ref) => biliSource,
);
final biliLoginPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);
final biliSaveSessionProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => BiliAuthStore.save(biliSource.client),
);
final biliLoginControllerProvider =
    NotifierProvider<BiliLoginController, BiliLoginState>(
      BiliLoginController.new,
    );
