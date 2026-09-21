import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';

void main() {
  group('Result', () {
    test('folds success and failure without throwing', () {
      const Result<String, int> success = Success<String, int>(7);
      const Result<String, int> failure = Failure<String, int>('unavailable');

      expect(
        success.fold(
          onSuccess: (int value) => value * 2,
          onFailure: (String _) => 0,
        ),
        14,
      );
      expect(
        failure.fold(
          onSuccess: (int value) => value,
          onFailure: (String value) => value.length,
        ),
        11,
      );
      expect(success.isSuccess, isTrue);
      expect(failure.isFailure, isTrue);
    });

    test('uses Unit for successful operations without a payload', () {
      const Result<String, Unit> result = Success<String, Unit>(unit);

      expect(result, const Success<String, Unit>(Unit()));
    });
  });
}
