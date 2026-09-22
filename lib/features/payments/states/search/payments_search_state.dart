import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';

part 'payments_search_state.freezed.dart';

@freezed
sealed class PaymentsSearchState with _$PaymentsSearchState {
  const PaymentsSearchState._();

  /// No criteria: the page shows the full authoritative history.
  const factory PaymentsSearchState.idle() = PaymentsSearchIdle;

  const factory PaymentsSearchState.loading({
    required PaymentsSearchCriteria criteria,
  }) = PaymentsSearchLoading;

  const factory PaymentsSearchState.results({
    required PaymentsSearchCriteria criteria,
    required List<Payment> payments,
  }) = PaymentsSearchResults;

  const factory PaymentsSearchState.empty({
    required PaymentsSearchCriteria criteria,
  }) = PaymentsSearchEmpty;

  const factory PaymentsSearchState.error({
    required PaymentsSearchCriteria criteria,
    required PaymentsFailure failure,
  }) = PaymentsSearchError;

  /// Whether any criterion is set; idle is the only inactive state.
  bool get isActive => this is! PaymentsSearchIdle;

  /// The criteria the state describes; idle carries the empty criteria.
  PaymentsSearchCriteria get criteria => switch (this) {
    PaymentsSearchIdle() => PaymentsSearchCriteria.none,
    PaymentsSearchLoading(:final criteria) ||
    PaymentsSearchResults(:final criteria) ||
    PaymentsSearchEmpty(:final criteria) ||
    PaymentsSearchError(:final criteria) => criteria,
  };
}
