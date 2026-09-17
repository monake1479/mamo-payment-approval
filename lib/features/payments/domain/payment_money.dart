import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

abstract final class PaymentMoney {
  static const String currencyCode = 'AED';
  static const double maximumAmount = 999999999.99;
  static const double _precisionTolerance = 0.0000001;
  static const int _maximumFils = 99999999999;

  static PaymentsResult<double> canonicalize(double amount) {
    final int? fils = tryToFils(amount);
    if (fils == null || fils <= 0) {
      return const PaymentsError<double>(
        InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
    }
    return PaymentsSuccess<double>(fils / 100);
  }

  static bool equivalent(double left, double right) {
    final int? leftFils = tryToFils(left);
    final int? rightFils = tryToFils(right);
    return leftFils != null && leftFils == rightFils;
  }

  static bool equivalentOrZero(double left, double right) {
    if (left == 0 && right == 0) {
      return true;
    }
    return equivalent(left, right);
  }

  static String formatAed(double amount) {
    final int fils = amount == 0 ? 0 : _requireFils(amount);
    final String digits = fils.toString().padLeft(3, '0');
    final String whole = digits.substring(0, digits.length - 2);
    final String fraction = digits.substring(digits.length - 2);
    final StringBuffer grouped = StringBuffer();
    for (int index = 0; index < whole.length; index += 1) {
      if (index > 0 && (whole.length - index) % 3 == 0) {
        grouped.write(',');
      }
      grouped.write(whole[index]);
    }
    return '$currencyCode $grouped.$fraction';
  }

  static PaymentsResult<double> parse(String serializedAmount) {
    if (!RegExp(r'^(?:0|[1-9][0-9]*)\.[0-9]{2}$').hasMatch(serializedAmount)) {
      return const PaymentsError<double>(
        InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
    }
    final double? parsed = double.tryParse(serializedAmount);
    if (parsed == null) {
      return const PaymentsError<double>(
        InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
    }
    return canonicalize(parsed);
  }

  static String serialize(double amount) {
    final int fils = _requireFils(amount);
    final String digits = fils.toString().padLeft(3, '0');
    return '${digits.substring(0, digits.length - 2)}.'
        '${digits.substring(digits.length - 2)}';
  }

  static PaymentsResult<double> sum(Iterable<double> amounts) {
    int totalFils = 0;
    for (final double amount in amounts) {
      final int? fils = tryToFils(amount);
      if (fils == null || fils <= 0 || totalFils > _maximumFils - fils) {
        return const PaymentsError<double>(
          InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
        );
      }
      totalFils += fils;
    }
    return PaymentsSuccess<double>(totalFils / 100);
  }

  static int? tryToFils(double amount) {
    if (!amount.isFinite || amount <= 0 || amount > maximumAmount) {
      return null;
    }
    final int roundedFils = (amount * 100).round();
    final double canonicalAmount = roundedFils / 100;
    if ((amount - canonicalAmount).abs() >= _precisionTolerance ||
        roundedFils > _maximumFils) {
      return null;
    }
    return roundedFils;
  }

  static int? toFilsOrZero(double amount) {
    if (amount == 0) {
      return 0;
    }
    return tryToFils(amount);
  }

  static int _requireFils(double amount) {
    final int? fils = tryToFils(amount);
    if (fils == null) {
      throw ArgumentError.value(amount, 'amount', 'Must be valid whole fils');
    }
    return fils;
  }
}
