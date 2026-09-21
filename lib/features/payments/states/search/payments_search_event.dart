import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';

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

  /// The decision-date window changed; `null` removes it.
  const factory PaymentsSearchEvent.dateRangeChanged(
    PaymentsDateRange? dateRange,
  ) = PaymentsSearchDateRangeChanged;

  /// The requested ordering changed.
  const factory PaymentsSearchEvent.sortChanged(PaymentsSort sort) =
      PaymentsSearchSortChanged;

  /// Drops every criterion and any query edit still waiting for its debounce
  /// window.
  const factory PaymentsSearchEvent.cleared() = PaymentsSearchCleared;

  /// Re-runs the active criteria after the authoritative collection changed,
  /// so a fresh decision reaches an open search result immediately.
  const factory PaymentsSearchEvent.refreshRequested() =
      PaymentsSearchRefreshRequested;
}
