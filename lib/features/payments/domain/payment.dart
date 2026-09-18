import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';

enum PaymentStatus { pending, approved, rejected }

enum PaymentDecision { approve, reject }

final class Payment {
  const Payment({
    required this.id,
    required this.counterparty,
    required this.amount,
    required this.reference,
    required this.createdAt,
    required this.status,
    this.decidedAt,
  });

  final String id;
  final String counterparty;
  final double amount;
  final String reference;
  final DateTime createdAt;
  final PaymentStatus status;
  final DateTime? decidedAt;

  String get currency => PaymentMoney.currencyCode;

  Payment copyWith({PaymentStatus? status, DateTime? decidedAt}) {
    return Payment(
      id: id,
      counterparty: counterparty,
      amount: amount,
      reference: reference,
      createdAt: createdAt,
      status: status ?? this.status,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  InvalidPaymentFailure? validate() {
    if (id.trim().isEmpty) {
      return const InvalidPaymentFailure(InvalidPaymentReason.emptyId);
    }
    if (counterparty.trim().isEmpty) {
      return const InvalidPaymentFailure(
        InvalidPaymentReason.emptyCounterparty,
      );
    }
    if (reference.trim().isEmpty) {
      return const InvalidPaymentFailure(InvalidPaymentReason.emptyReference);
    }
    if (PaymentMoney.tryToFils(amount) == null) {
      return const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount);
    }
    if (!createdAt.isUtc || (decidedAt != null && !decidedAt!.isUtc)) {
      return const InvalidPaymentFailure(InvalidPaymentReason.invalidTimestamp);
    }
    final bool pendingTimeline =
        status == PaymentStatus.pending && decidedAt == null;
    final bool decidedTimeline =
        status != PaymentStatus.pending &&
        decidedAt != null &&
        !decidedAt!.isBefore(createdAt);
    if (!pendingTimeline && !decidedTimeline) {
      return const InvalidPaymentFailure(
        InvalidPaymentReason.invalidStatusTimeline,
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Payment &&
            other.id == id &&
            other.counterparty == counterparty &&
            PaymentMoney.equivalent(other.amount, amount) &&
            other.reference == reference &&
            other.createdAt == createdAt &&
            other.status == status &&
            other.decidedAt == decidedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    counterparty,
    PaymentMoney.tryToFils(amount),
    reference,
    createdAt,
    status,
    decidedAt,
  );
}
