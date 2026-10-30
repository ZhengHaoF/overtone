import '../../source/music_source.dart';
import 'package:overtone/l10n/l10n.dart';

/// B 站业务码 → 统一 [SourceFailure]（方案 §3.4 口径的精神：分源映射，
/// 禁止混用）。
///
/// B 站多数错误是 **HTTP 200 + `body.code != 0`**；少数（-412 风控）可能
/// 直接是 HTTP 412。调用方先过 [throwIfBadCode]，再拿 `data`。
///
/// B1 只做探针够用的雏形；B2 适配层按实测补全。
abstract final class BiliFailures {
  static const codeOk = 0;

  /// 已知码 → 失败类型。未收录的码一律 [UpstreamChanged]（协议可能变了，
  /// 按 §9 风险表口径不猜）。
  static SourceFailure fromCode(int code, String message) {
    final msg = message.isEmpty ? l10n.bZhanFanHuiCode(code) : message;
    return switch (code) {
      -403 => UpstreamChanged(l10n.qianMingBeiJuJianChaWRidMixinkeyShiFouGuoQi(msg)),
      -404 => NotFound(msg),
      -412 => RateLimited(l10n.chuFaFengKongTuiBiChongShiHuoGengHuanWangLuo(msg)),
      -352 || -401 => RateLimited(l10n.bZhanFengKongJiaoYanShiBaiQingShaoHouChongSh(msg)),
      -101 =>  LoginRequired(l10n.bZhanXuYaoDengLu),
      -105 =>  LoginRequired(l10n.bZhanXuYaoDengLuYanZhengMa),
      _ => UpstreamChanged(msg),
    };
  }

  /// 校验 body 是「code=0」并返回**原始 data**（B 站个别接口的 data 是
  /// 数组——如 `pagelist`——不能假定是对象）。
  static Object? requireOkData(Object? body, String what) {
    if (body is! Map<String, dynamic>) {
      throw UpstreamChanged(l10n.xiangYingBuShiJsonDuiXiang(what));
    }
    final code = body['code'];
    if (code is! int) {
      throw UpstreamChanged(l10n.xiangYingQueShaoCodeZiDuan(what));
    }
    if (code != codeOk) {
      final msg = body['message'] is String
          ? body['message'] as String
          : 'code=$code';
      throw fromCode(code, '$what：$msg');
    }
    return body['data'];
  }

  /// [requireOkData] 的 Map 版（nav / spi / search / view / playurl）。
  static Map<String, dynamic> requireOkMap(Object? body, String what) {
    final data = requireOkData(body, what);
    if (data is Map<String, dynamic>) return data;
    throw UpstreamChanged(l10n.dataBuShiJsonDuiXiang(what));
  }

  /// [requireOkData] 的 List 版（`pagelist` 的 data 就是分 P 数组）。
  static List<dynamic> requireOkList(Object? body, String what) {
    final data = requireOkData(body, what);
    if (data is List) return data;
    throw UpstreamChanged(l10n.dataBuShiJsonShuZu(what));
  }
}
