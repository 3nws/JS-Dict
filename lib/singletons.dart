import "package:flutter/material.dart";
import "package:flutter_ankidroid/flutter_ankidroid.dart";
import "package:get_it/get_it.dart";
import "package:jsdict/packages/jisho_client/jisho_client.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<void> registerSingletons() {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerLazySingleton<JishoClient>(() => JishoClient());
  GetIt.I.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  GetIt.I
      .registerSingletonAsync<Ankidroid>(() => Ankidroid.createAnkiIsolate());
  return GetIt.I.allReady();
}

JishoClient getClient() {
  return GetIt.I<JishoClient>();
}

SharedPreferences getPreferences() {
  return GetIt.I<SharedPreferences>();
}

Ankidroid getAnki() {
  return GetIt.I<Ankidroid>();
}
