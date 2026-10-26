import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> restored(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsControllerProvider.notifier).ensureRestored();
    return container;
  }

  bool archive(ProviderContainer c) =>
      c.read(settingsControllerProvider).archiveSkin;

  SettingsController ctrl(ProviderContainer c) =>
      c.read(settingsControllerProvider.notifier);

  test('默认关闭', () async {
    final c = await restored({});
    expect(archive(c), isFalse);
  });

  test('兼容旧键 settings.playerSkinArchive', () async {
    final c = await restored({'settings.playerSkinArchive': true});
    expect(archive(c), isTrue);
  });

  test('新键优先于旧键', () async {
    final c = await restored({
      'settings.archiveSkin': false,
      'settings.playerSkinArchive': true,
    });
    expect(archive(c), isFalse);
  });

  test('setArchiveSkin 落盘到新键', () async {
    final c = await restored({});
    await ctrl(c).setArchiveSkin(true);
    expect(archive(c), isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings.archiveSkin'), isTrue);
  });
}
