import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';

part 'payments_search_criteria.freezed.dart';

/// Everything a decided-history search asks the backend for. The default
/// instance means "the plain history": no text, every decided status, no
/// date window, newest decision first.
@freezed
abstract class PaymentsSearchCriteria with _$PaymentsSearchCriteria {
  const PaymentsSearchCriteria._();

  const factory PaymentsSearchCriteria({
    @Default('') String query,
    @Default(<PaymentStatus>{}) Set<PaymentStatus> statuses,
    PaymentsDateRange? dateRange,
    @Default(PaymentsSort.decidedAtNewestFirst) PaymentsSort sort,
  }) = _PaymentsSearchCriteria;

  static const PaymentsSearchCriteria none = PaymentsSearchCriteria();

  /// True when the criteria would only reproduce the plain history.
  bool get isEmpty => this == none;
}
