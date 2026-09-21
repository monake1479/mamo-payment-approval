import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';

part 'payments_search_state.freezed.dart';

@freezed
sealed class PaymentsSearchState with _$PaymentsSearchState {
  const PaymentsSearchState._();

  /// No criteria: the page shows the full authoritative history.
  const factory PaymentsSearchState.idle() = PaymentsSearchIdle;

  const factory PaymentsSearchState.loading({
    required String query,
    required Set<PaymentStatus> statuses,
  }) = PaymentsSearchLoading;

  const factory PaymentsSearchState.results({
    required String query,
    required Set<PaymentStatus> statuses,
    required List<Payment> payments,
  }) = PaymentsSearchResults;

  const factory PaymentsSearchState.empty({
    required String query,
    required Set<PaymentStatus> statuses,
  }) = PaymentsSearchEmpty;

  const factory PaymentsSearchState.error({
    required String query,
    required Set<PaymentStatus> statuses,
    required PaymentsFailure failure,
  }) = PaymentsSearchError;

  /// Whether any criterion is set; idle is the only inactive state.
  bool get isActive => this is! PaymentsSearchIdle;

  String get query => switch (this) {
    PaymentsSearchIdle() => '',
    PaymentsSearchLoading(:final query) ||
    PaymentsSearchResults(:final query) ||
    PaymentsSearchEmpty(:final query) ||
    PaymentsSearchError(:final query) => query,
  };

  Set<PaymentStatus> get statuses => switch (this) {
    PaymentsSearchIdle() => const <PaymentStatus>{},
    PaymentsSearchLoading(:final statuses) ||
    PaymentsSearchResults(:final statuses) ||
    PaymentsSearchEmpty(:final statuses) ||
    PaymentsSearchError(:final statuses) => statuses,
  };
}
