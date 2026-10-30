import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/shared/tray/single_instance_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('原生 activate 会回调 onActivate，未知方法忽略', () async {
    var calls = 0;
    SingleInstanceBridge.ensureListening(() async => calls++);

    const codec = StandardMethodCodec();
    Future<void> send(String method) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'overtone/single_instance',
            codec.encodeMethodCall(MethodCall(method)),
            (_) {},
          );
      await Future<void>.delayed(Duration.zero);
    }

    await send('activate');
    await send('activate');
    expect(calls, 2);

    await send('somethingElse');
    expect(calls, 2);
  });
}
