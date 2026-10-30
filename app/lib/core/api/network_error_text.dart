import 'package:dio/dio.dart';

import '../source/music_source.dart';
import 'package:overtone/l10n/l10n.dart';

/// 把网络层异常整理成用户能看懂的中文文案。
///
/// Dio 在连接失败时会把底层异常的 `toString()` 塞进
/// `DioException.message`（例如
/// `HandshakeException: Connection terminated during handshake`），
/// 原样透传到界面会让中文 UI 冒出英文堆栈。
///
/// 业务层已经给出中文说明时原样返回，只替换纯技术性的英文文案。
String networkErrorText(
  Object error, {
  String? fallback,
}) {
  if (error is SourceFailure) {
    final message = error.message.trim();
    if (message.isNotEmpty && _hasCjk(message)) return message;
  }
  final raw = _rawText(error);
  final status = error is DioException ? error.response?.statusCode : null;
  if (status != null && status >= 500) {
    return l10n.fuWuQiZanShiBuKeYongHttpQingShaoHouChongShi(status);
  }
  if (isGatewayFilteredText(raw)) {
    return l10n.dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFa;
  }
  if (raw.contains('Handshake') ||
      raw.contains('handshake') ||
      raw.contains('CERTIFICATE') ||
      raw.contains('TLS')) {
    return l10n.yuFuWuQiJianLiAnQuanLianJieShiBaiQingJianChaWang;
  }
  if (isConnectionFailureText(raw)) {
    return l10n.wangLuoLianJieShiBaiQingJianChaWangLuoHouChongSh;
  }
  if (isTimeoutText(raw) || _isTimeoutType(error)) {
    return l10n.wangLuoQingQiuChaoShiQingJianChaWangLuoHouChongS;
  }
  if (_hasCjk(raw)) return raw.trim();
  return fallback ?? l10n.wangLuoYiChangQingShaoHouChongShi;
}

/// 中间盒（路由器 URL 过滤 / 办公网网关）拦截的特征文案。
bool isGatewayFilteredText(String text) =>
    text.contains('URL过滤') || text.contains('Access Deny');

/// 连接被断开 / 无法建立的特征文案。
bool isConnectionFailureText(String text) =>
    text.contains('SocketException') ||
    text.contains('Connection terminated') ||
    text.contains('Connection closed') ||
    text.contains('Connection reset') ||
    text.contains('Connection refused') ||
    text.contains('Failed host lookup') ||
    text.contains('Network is unreachable') ||
    text.contains('网络连接失败');

/// 超时的特征文案。
bool isTimeoutText(String text) =>
    text.contains('timed out') ||
    text.contains('Timeout') ||
    text.contains('timeout') ||
    text.contains('网络请求超时');

/// 连接层失败的统称：映射到 `NetworkFailure` 而不是 `UpstreamChanged`。
bool isTransportFailureText(String text) =>
    isGatewayFilteredText(text) ||
    isConnectionFailureText(text) ||
    isTimeoutText(text) ||
    text.contains('Handshake') ||
    text.contains('handshake') ||
    text.contains('安全连接');

String _rawText(Object error) {
  if (error is DioException) {
    final message = (error.message ?? '').trim();
    final cause = error.error?.toString().trim() ?? '';
    return [message, cause].where((part) => part.isNotEmpty).join(' ');
  }
  return error.toString();
}

bool _isTimeoutType(Object error) {
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout;
}

final RegExp _cjk = RegExp(r'[\u4e00-\u9fff]');

bool _hasCjk(String text) => _cjk.hasMatch(text);
