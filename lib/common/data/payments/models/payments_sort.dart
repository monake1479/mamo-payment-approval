import 'package:freezed_annotation/freezed_annotation.dart';

part 'payments_sort.freezed.dart';

enum PaymentsSortField { decidedAt, createdAt, amount, counterparty }

enum SortDirection { ascending, descending }

/// Ordering requested from the payments backend. The backend applies it and
/// breaks ties by the stable identifier; the application never re-sorts.
@freezed
abstract class PaymentsSort with _$PaymentsSort {
  const factory PaymentsSort({
    required PaymentsSortField field,
    required SortDirection direction,
  }) = _PaymentsSort;

  /// The decided-history order: newest decision first.
  static const PaymentsSort decidedAtNewestFirst = PaymentsSort(
    field: PaymentsSortField.decidedAt,
    direction: SortDirection.descending,
  );
}
