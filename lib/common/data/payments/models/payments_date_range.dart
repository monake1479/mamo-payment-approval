import 'package:freezed_annotation/freezed_annotation.dart';

part 'payments_date_range.freezed.dart';

/// Decision-time window as UTC instants: [startUtc] inclusive, [endUtc]
/// exclusive. Presentation derives it from calendar days in the account's
/// reporting zone; the backend compares stored UTC timestamps against it.
@freezed
abstract class PaymentsDateRange with _$PaymentsDateRange {
  const factory PaymentsDateRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) = _PaymentsDateRange;
}
