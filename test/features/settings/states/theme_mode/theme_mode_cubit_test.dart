import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/appearance_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts on the system preference when nothing is stored', () async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final ThemeModeCubit cubit = createThemeModeCubit(preferences);
    addTearDown(cubit.close);

    expect(
      cubit.state,
      const ThemeModeState(preference: ThemePreference.system),
    );
  });

  test('hydrates the persisted preference on load', () async {
    final SharedPreferences preferences = await resetSharedPreferences(
      stored: ThemePreference.dark,
    );
    final ThemeModeCubit cubit = createThemeModeCubit(preferences);
    addTearDown(cubit.close);

    expect(cubit.state, const ThemeModeState(preference: ThemePreference.dark));
  });

  test('select applies and persists the new preference', () async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final ThemeModeCubit cubit = createThemeModeCubit(preferences);
    addTearDown(cubit.close);

    await cubit.select(ThemePreference.light);

    expect(
      cubit.state,
      const ThemeModeState(preference: ThemePreference.light),
    );
    // A fresh owner over the same storage observes the persisted choice.
    final ThemeModeCubit reloaded = createThemeModeCubit(preferences);
    addTearDown(reloaded.close);
    expect(
      reloaded.state,
      const ThemeModeState(preference: ThemePreference.light),
    );
  });

  test('selecting the current preference emits nothing further', () async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final ThemeModeCubit cubit = createThemeModeCubit(preferences);
    addTearDown(cubit.close);
    final List<ThemeModeState> emitted = <ThemeModeState>[];
    final subscription = cubit.stream.listen(emitted.add);
    addTearDown(subscription.cancel);

    await cubit.select(ThemePreference.system);

    expect(emitted, isEmpty);
  });

  test('keeps the applied preference when persistence fails', () async {
    final SharedPreferences preferences = await failingWriteSharedPreferences();
    final ThemeModeCubit cubit = createThemeModeCubit(preferences);
    addTearDown(cubit.close);

    await cubit.select(ThemePreference.dark);

    expect(cubit.state, const ThemeModeState(preference: ThemePreference.dark));
  });
}
