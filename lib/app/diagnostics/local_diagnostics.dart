import 'dart:convert';
import 'dart:developer' as developer;

import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';

enum ErrorOrigin { startup, framework, platform }

/// Local-only diagnostics. Raw exceptions and arbitrary context are not inputs.
class LocalDiagnostics {
  LocalDiagnostics({required this.environment, void Function(String)? write})
    : _write = write ?? _writeToDeviceLog;

  final AppEnvironment environment;
  final void Function(String) _write;

  void record(AppFailureCode code, ErrorOrigin origin, {StackTrace? stack}) {
    // Retain only app source locations, never exception text, absolute paths,
    // arguments, or arbitrary stack lines. No report leaves the device.
    final List<String> locations =
        RegExp(
              r'package:mamo_payment_approval_challenge/[a-zA-Z0-9_/.-]+\.dart:\d+:\d+',
            )
            .allMatches(stack?.toString() ?? '')
            .take(12)
            .map((match) => match[0]!)
            .toList();
    _write(
      jsonEncode(<String, Object>{
        'code': code.name,
        'origin': origin.name,
        'environment': environment.name,
        'locations': locations,
      }),
    );
  }

  static void _writeToDeviceLog(String message) {
    developer.log(message, name: 'mamo.diagnostics', level: 1000);
  }
}
