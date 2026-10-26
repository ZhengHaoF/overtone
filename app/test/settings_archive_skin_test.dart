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

  ExperimentalUiSkin experimentalUi(ProviderContainer c) =>
      c.read(settingsControllerProvider).experimentalUi;

  SettingsController ctrl(ProviderContainer c) =>
      c.read(settingsControllerProvider.notifier);

  test('默认项为「默认」（关闭）', () async {
    final c = await restored({});
    expect(experimentalUi(c), ExperimentalUiSkin.off);
    expect(experimentalUi(c).label, '默认');
    expect(archive(c), isFalse);
  });

  test('兼容旧键 settings.playerSkinArchive', () async {
    final c = await restored({'settings.playerSkinArchive': true});
    expect(experimentalUi(c), ExperimentalUiSkin.swiss);
    expect(archive(c), isTrue);
  });

  test('新键优先于旧键', () async {
    final c = await restored({
      'settings.archiveSkin': false,
      'settings.playerSkinArchive': true,
    });
    expect(experimentalUi(c), ExperimentalUiSkin.off);
    expect(archive(c), isFalse);
  });

  test('setArchiveSkin 落盘到新键', () async {
    final c = await restored({});
    await ctrl(c).setArchiveSkin(true);
    expect(experimentalUi(c), ExperimentalUiSkin.swiss);
    expect(archive(c), isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings.archiveSkin'), isTrue);
    expect(prefs.getString('settings.experimentalUi'), 'swiss');
  });

  test('setExperimentalUi 切换并同时落盘', () async {
    final c = await restored({});
    await ctrl(c).setExperimentalUi(ExperimentalUiSkin.swiss);
    expect(experimentalUi(c), ExperimentalUiSkin.swiss);
    expect(experimentalUi(c).label, '瑞士国际排版');
    expect(archive(c), isTrue);

    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.experimentalUi'), 'swiss');
    expect(prefs.getBool('settings.archiveSkin'), isTrue);

    await ctrl(c).setExperimentalUi(ExperimentalUiSkin.off);
    expect(experimentalUi(c), ExperimentalUiSkin.off);
    expect(archive(c), isFalse);

    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.experimentalUi'), 'off');
    expect(prefs.getBool('settings.archiveSkin'), isFalse);
  });

  test('从 settings.experimentalUi 恢复', () async {
    final c = await restored({'settings.experimentalUi': 'swiss'});
    expect(experimentalUi(c), ExperimentalUiSkin.swiss);
    expect(archive(c), isTrue);
  });
}
