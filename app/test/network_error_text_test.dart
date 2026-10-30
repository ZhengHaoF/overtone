import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/api/network_error_text.dart';
import 'package:overtone/core/source/music_source.dart';

DioException _dio({
  String? message,
  DioExceptionType type = DioExceptionType.connectionError,
  Object? error,
  int? statusCode,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/fixture'),
    type: type,
    message: message,
    error: error,
    response: statusCode == null
        ? null
        : Response<void>(
            requestOptions: RequestOptions(path: '/fixture'),
            statusCode: statusCode,
          ),
  );
}

void main() {
  test('TLS 握手断开（截图里的英文堆栈）→ 中文安全连接提示', () {
    final text = networkErrorText(
      _dio(message: 'HandshakeException: Connection terminated during handshake'),
    );
    expect(text, '与服务器建立安全连接失败，请检查网络或代理设置后重试');
  });

  test('SocketException → 连接失败提示', () {
    final text = networkErrorText(
      _dio(message: 'SocketException: Connection refused (OS Error: ...)'),
    );
    expect(text, '网络连接失败，请检查网络后重试');
  });

  test('连接超时类型 → 超时提示', () {
    final text = networkErrorText(
      _dio(type: DioExceptionType.connectionTimeout),
    );
    expect(text, '网络请求超时，请检查网络后重试');
  });

  test('网关 URL 过滤 → 保留「URL过滤」字样供 filtered 判定', () {
    final text = networkErrorText(_dio(message: 'router page: URL过滤'));
    expect(text, contains('URL过滤'));
    expect(isGatewayFilteredText(text), isTrue);
  });

  test('HTTP 5xx → 服务器暂时不可用', () {
    final text = networkErrorText(_dio(statusCode: 502, message: 'Bad Gateway'));
    expect(text, '服务器暂时不可用（HTTP 502），请稍后重试');
  });

  test('业务中文文案原样返回', () {
    expect(
      networkErrorText(_dio(message: '云盘文件暂无播放地址')),
      '云盘文件暂无播放地址',
    );
  });

  test('SourceFailure 的中文说明原样返回', () {
    expect(
      networkErrorText(NotFound('缺少云盘文件标识，无法删除')),
      '缺少云盘文件标识，无法删除',
    );
  });

  test('无法识别的英文异常 → fallback', () {
    expect(
      networkErrorText(StateError('boom'), fallback: '请求失败'),
      '请求失败',
    );
  });

  test('英文业务错误不进入超时判定', () {
    final text = networkErrorText(_dio(message: 'bad token'), fallback: '登录失败');
    expect(text, '登录失败');
  });
}
