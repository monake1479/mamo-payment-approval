import 'package:mamo_approval/common/data/payments/models/payment.dart';

/// Canonical ordering for decided payments: newest decision first, then the
/// stable identifier ascending so equal decision times stay deterministic.
abstract final class DecidedPaymentOrder {
  static int newestFirst(Payment left, Payment right) {
    final int byDecision = right.decidedAt!.compareTo(left.decidedAt!);
    return byDecision != 0 ? byDecision : left.id.compareTo(right.id);
  }
}
