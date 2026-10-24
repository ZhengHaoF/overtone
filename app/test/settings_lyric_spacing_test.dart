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

  double spacing(ProviderContainer c) =>
      c.read(settingsControllerProvider).lyricSpacingScale;

  test('默认行间距 150%', () async {
    final c = await restored({});
    expect(spacing(c), kLyricSpacingScaleDefault);
  });

  test('旧默认值直接换成新默认（没调过的用户得到更紧的观感）', () async {
    final c = await restored({'settings.lyricSpacingScale': '1.0'});
    expect(spacing(c), kLyricSpacingScaleDefault);
  });

  test('调过的旧值按 2.3 折算成新语义（升级后观感不变）', () async {
    // 旧版 130% ≈ 56 × 1.3 = 72.8 的行盒 → 新语义 72.8 / 24.3 ≈ 3.0。
    final c = await restored({'settings.lyricSpacingScale': '1.3'});
    expect(spacing(c), closeTo(1.3 * 2.3, 0.001));
  });

  test('旧键越界值折算后仍夹在新区间内', () async {
    final c = await restored({'settings.lyricSpacingScale': '0.4'});
    expect(spacing(c), kLyricSpacingScaleMin);
  });

  test('新键优先，旧键只在没有新值时参与迁移', () async {
    final c = await restored({
      'settings.lyricSpacingScale': '1.0',
      'settings.lyricSpacingScaleV2': '1.2',
    });
    expect(spacing(c), 1.2);
  });

  test('setLyricSpacingScale 夹到新区间并落盘到 V2 键', () async {
    final c = await restored({});
    final ctrl = c.read(settingsControllerProvider.notifier);
    await ctrl.setLyricSpacingScale(0.4);
    expect(spacing(c), kLyricSpacingScaleMin);

    await ctrl.setLyricSpacingScale(1.8);
    expect(spacing(c), 1.8);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.lyricSpacingScaleV2'), '1.8');
  });

  // 滑块的实际调用序列：onChanged(persist: false) 连续预览，onChangeEnd 再落盘。
  // 松手时值已经进过内存态，落盘不能因为「值没变」被跳过。
  test('行间距：拖动预览后松手仍落盘', () async {
    final c = await restored({});
    final ctrl = c.read(settingsControllerProvider.notifier);
    await ctrl.setLyricSpacingScale(2.0, persist: false);
    await ctrl.setLyricSpacingScale(2.0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.lyricSpacingScaleV2'), '2.0');
  });

  test('字号：拖动预览后松手仍落盘', () async {
    final c = await restored({});
    final ctrl = c.read(settingsControllerProvider.notifier);
    await ctrl.setLyricFontScale(1.4, persist: false);
    await ctrl.setLyricFontScale(1.4);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.lyricFontScale'), '1.4');
  });
}
