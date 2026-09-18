import 'package:kedis/settings/home_layout_controller.dart';
import 'package:kedis/settings/home_layout_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to Grid and persists List selection', () async {
    SharedPreferences.setMockInitialValues({});

    final store = HomeLayoutPreferenceStore();
    final initial = await store.load();
    expect(initial, HomeLayoutMode.grid);

    final controller = HomeLayoutController(
      store,
      initialLayoutMode: initial,
    );
    await controller.setLayoutMode(HomeLayoutMode.list);

    expect(controller.layoutMode, HomeLayoutMode.list);
    expect(await HomeLayoutPreferenceStore().load(), HomeLayoutMode.list);
  });
}
