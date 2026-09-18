import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> configureAppOrientation() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
}
