import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/data/storage/credential_store.dart';
import 'package:overtone/l10n/app_language.dart';

/// 全局测试默认走中文。
///
/// 既有断言都是按中文文案写的；英文/日文/韩文由 `i18n_catalog_test` 在
/// 词典层面校验（键齐全、占位符一致、无残留中文），不逐页断言。
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  applyAppLanguage(AppLanguage.zh);
  // 测试进程里平台语言固定为中文，MaterialApp 即使没显式传 locale 也解析到 zh。
  final dispatcher = binding.platformDispatcher;
  dispatcher.localeTestValue = const Locale('zh');
  dispatcher.localesTestValue = const [Locale('zh')];
  setUp(() {
    CredentialStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
  });
  await testMain();
}
