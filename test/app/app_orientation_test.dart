import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/platform/app_orientation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('configures portrait-up as the only application orientation', () async {
    final List<MethodCall> calls = <MethodCall>[];
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall call,
    ) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await configureAppOrientation();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'SystemChrome.setPreferredOrientations');
    expect(calls.single.arguments, const <String>[
      'DeviceOrientation.portraitUp',
    ]);
  });
}
