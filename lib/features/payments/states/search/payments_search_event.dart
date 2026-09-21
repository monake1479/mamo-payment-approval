import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';

part 'payments_search_event.freezed.dart';

@freezed
sealed class PaymentsSearchEvent with _$PaymentsSearchEvent {
  /// The search text changed. Debounced by the bloc so fast typing produces
  /// one search for the final text.
  const factory PaymentsSearchEvent.queryChanged(String query) =
      PaymentsSearchQueryChanged;

  /// The selected decided statuses changed. Empty means every decided status.
  const factory PaymentsSearchEvent.statusFilterChanged(
    Set<PaymentStatus> statuses,
  ) = PaymentsSearchStatusFilterChanged;

  /// Drops the query, the status filter, and any query edit still waiting for
  /// its debounce window.
  const factory PaymentsSearchEvent.cleared() = PaymentsSearchCleared;

  /// Re-runs the active criteria after the authoritative collection changed,
  /// so a fresh decision reaches an open search result immediately.
  const factory PaymentsSearchEvent.refreshRequested() =
      PaymentsSearchRefreshRequested;
}
