import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mamo_approval/common/data/payments/dtos/payment_dto.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';

void main() {
  group('PaymentDto serialization', () {
    test('round trips currency, amount, and UTC timestamps', () {
      final PaymentDto dto = PaymentDto.fromModel(
        Payment(
          id: 'payment-1',
          counterparty: 'Counterparty',
          amount: 1234.5,
          currency: 'USD',
          reference: 'Reference',
          createdAt: DateTime.utc(2026, 9, 1, 10, 30),
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 2, 11, 45),
        ),
      );

      final Map<String, Object?> json = dto.toJson();
      final PaymentDto decoded = PaymentDto.fromJson(json);

      expect(json['amount'], '1234.5');
      expect(json['currency'], 'USD');
      expect(json['createdAt'], '2026-09-01T10:30:00.000Z');
      expect(json['decidedAt'], '2026-09-02T11:45:00.000Z');
      expect(decoded, dto);
      expect(decoded.toModel(), dto.toModel());
    });

    test('converter rejects non-UTC timestamps and malformed wire data', () {
      final Map<String, Object?> base = <String, Object?>{
        'id': 'payment-1',
        'counterparty': 'Counterparty',
        'amount': '1.0',
        'currency': 'AED',
        'reference': 'Reference',
        'createdAt': '2026-09-01T10:30:00.000Z',
        'status': 'approved',
        'decidedAt': '2026-09-02T11:45:00.000Z',
      };

      for (final Map<String, Object?> json in <Map<String, Object?>>[
        <String, Object?>{
          ...base,
          'createdAt': '2026-09-01T14:30:00.000+04:00',
        },
        <String, Object?>{...base, 'amount': 'not-a-number'},
        <String, Object?>{...base, 'status': 'unknown'},
        <String, Object?>{...base}..remove('currency'),
      ]) {
        expect(
          () => PaymentDto.fromJson(json),
          throwsA(isA<CheckedFromJsonException>()),
          reason: '$json must be rejected',
        );
      }
    });

    test('validates DTO values before mapping to the domain', () {
      PaymentDto pending({
        double amount = 1,
        String currency = 'AED',
        DateTime? createdAt,
      }) => PaymentDto(
        id: 'payment-1',
        counterparty: 'Counterparty',
        amount: amount,
        currency: currency,
        reference: 'Reference',
        createdAt: createdAt ?? DateTime.utc(2026, 9),
        status: PaymentStatus.pending,
      );

      expect(pending(currency: 'USD').validate(), isNull);
      expect(
        pending(currency: 'aed').validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidCurrency),
      );
      expect(
        pending(amount: double.infinity).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
      expect(
        pending(amount: 1.001).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
      expect(
        pending(createdAt: DateTime(2026, 9)).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidTimestamp),
      );
    });
  });
}
