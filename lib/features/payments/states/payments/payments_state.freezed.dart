// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsState {

 PaymentsLoadStatus get status; List<Payment> get payments; PaymentSummary get summary; DateTime get reportingPeriodStartUtc; String get reportingTimeZone; String get reportingCurrency; bool get hasLoaded; PaymentsFailure? get failure; bool get isCreatingRequest; Set<String> get decidingPaymentIds;
/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsStateCopyWith<PaymentsState> get copyWith => _$PaymentsStateCopyWithImpl<PaymentsState>(this as PaymentsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.payments, _this.payments)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.reportingPeriodStartUtc, _this.reportingPeriodStartUtc) || other.reportingPeriodStartUtc == _this.reportingPeriodStartUtc)&&(identical(other.reportingTimeZone, _this.reportingTimeZone) || other.reportingTimeZone == _this.reportingTimeZone)&&(identical(other.reportingCurrency, _this.reportingCurrency) || other.reportingCurrency == _this.reportingCurrency)&&(identical(other.hasLoaded, _this.hasLoaded) || other.hasLoaded == _this.hasLoaded)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.isCreatingRequest, _this.isCreatingRequest) || other.isCreatingRequest == _this.isCreatingRequest)&&const DeepCollectionEquality().equals(other.decidingPaymentIds, _this.decidingPaymentIds));
}


@override
int get hashCode {
  final _this = this as PaymentsState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.payments),_this.summary,_this.reportingPeriodStartUtc,_this.reportingTimeZone,_this.reportingCurrency,_this.hasLoaded,_this.failure,_this.isCreatingRequest,const DeepCollectionEquality().hash(_this.decidingPaymentIds));
}

@override
String toString() {
  final _this = this as PaymentsState;
  return 'PaymentsState(status: ${_this.status}, payments: ${_this.payments}, summary: ${_this.summary}, reportingPeriodStartUtc: ${_this.reportingPeriodStartUtc}, reportingTimeZone: ${_this.reportingTimeZone}, reportingCurrency: ${_this.reportingCurrency}, hasLoaded: ${_this.hasLoaded}, failure: ${_this.failure}, isCreatingRequest: ${_this.isCreatingRequest}, decidingPaymentIds: ${_this.decidingPaymentIds})';
}


}

/// @nodoc
abstract mixin class $PaymentsStateCopyWith<$Res>  {
  factory $PaymentsStateCopyWith(PaymentsState value, $Res Function(PaymentsState) _then) = _$PaymentsStateCopyWithImpl;
@useResult
$Res call({
 PaymentsLoadStatus status, List<Payment> payments, PaymentSummary summary, DateTime reportingPeriodStartUtc, String reportingTimeZone, String reportingCurrency, bool hasLoaded, PaymentsFailure? failure, bool isCreatingRequest, Set<String> decidingPaymentIds
});


$PaymentSummaryCopyWith<$Res> get summary;$PaymentsFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$PaymentsStateCopyWithImpl<$Res>
    implements $PaymentsStateCopyWith<$Res> {
  _$PaymentsStateCopyWithImpl(this._self, this._then);

  final PaymentsState _self;
  final $Res Function(PaymentsState) _then;

/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? payments = null,Object? summary = null,Object? reportingPeriodStartUtc = null,Object? reportingTimeZone = null,Object? reportingCurrency = null,Object? hasLoaded = null,Object? failure = freezed,Object? isCreatingRequest = null,Object? decidingPaymentIds = null,}) {
  return _then(PaymentsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentsLoadStatus,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PaymentSummary,reportingPeriodStartUtc: null == reportingPeriodStartUtc ? _self.reportingPeriodStartUtc : reportingPeriodStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reportingTimeZone: null == reportingTimeZone ? _self.reportingTimeZone : reportingTimeZone // ignore: cast_nullable_to_non_nullable
as String,reportingCurrency: null == reportingCurrency ? _self.reportingCurrency : reportingCurrency // ignore: cast_nullable_to_non_nullable
as String,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PaymentsFailure?,isCreatingRequest: null == isCreatingRequest ? _self.isCreatingRequest : isCreatingRequest // ignore: cast_nullable_to_non_nullable
as bool,decidingPaymentIds: null == decidingPaymentIds ? _self.decidingPaymentIds : decidingPaymentIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}
/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res> get summary {

  return $PaymentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $PaymentsFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentsState].
extension PaymentsStatePatterns on PaymentsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsState value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsState value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentsLoadStatus status,  List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency,  bool hasLoaded,  PaymentsFailure? failure,  bool isCreatingRequest,  Set<String> decidingPaymentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsState() when $default != null:
return $default(_that.status,_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency,_that.hasLoaded,_that.failure,_that.isCreatingRequest,_that.decidingPaymentIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentsLoadStatus status,  List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency,  bool hasLoaded,  PaymentsFailure? failure,  bool isCreatingRequest,  Set<String> decidingPaymentIds)  $default,) {final _that = this;
switch (_that) {
case _PaymentsState():
return $default(_that.status,_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency,_that.hasLoaded,_that.failure,_that.isCreatingRequest,_that.decidingPaymentIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentsLoadStatus status,  List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency,  bool hasLoaded,  PaymentsFailure? failure,  bool isCreatingRequest,  Set<String> decidingPaymentIds)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsState() when $default != null:
return $default(_that.status,_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency,_that.hasLoaded,_that.failure,_that.isCreatingRequest,_that.decidingPaymentIds);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsState extends PaymentsState {
  const _PaymentsState({required this.status, required  List<Payment> payments, required this.summary, required this.reportingPeriodStartUtc, required this.reportingTimeZone, required this.reportingCurrency, required this.hasLoaded, required this.failure, required this.isCreatingRequest, required  Set<String> decidingPaymentIds}): _payments = payments,_decidingPaymentIds = decidingPaymentIds,super._();


@override final  PaymentsLoadStatus status;
 final  List<Payment> _payments;
@override List<Payment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

@override final  PaymentSummary summary;
@override final  DateTime reportingPeriodStartUtc;
@override final  String reportingTimeZone;
@override final  String reportingCurrency;
@override final  bool hasLoaded;
@override final  PaymentsFailure? failure;
@override final  bool isCreatingRequest;
 final  Set<String> _decidingPaymentIds;
@override Set<String> get decidingPaymentIds {
  if (_decidingPaymentIds is EqualUnmodifiableSetView) return _decidingPaymentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_decidingPaymentIds);
}


/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsStateCopyWith<_PaymentsState> get copyWith => __$PaymentsStateCopyWithImpl<_PaymentsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.payments, _payments)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.reportingPeriodStartUtc, reportingPeriodStartUtc) || other.reportingPeriodStartUtc == reportingPeriodStartUtc)&&(identical(other.reportingTimeZone, reportingTimeZone) || other.reportingTimeZone == reportingTimeZone)&&(identical(other.reportingCurrency, reportingCurrency) || other.reportingCurrency == reportingCurrency)&&(identical(other.hasLoaded, hasLoaded) || other.hasLoaded == hasLoaded)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.isCreatingRequest, isCreatingRequest) || other.isCreatingRequest == isCreatingRequest)&&const DeepCollectionEquality().equals(other.decidingPaymentIds, _decidingPaymentIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_payments),summary,reportingPeriodStartUtc,reportingTimeZone,reportingCurrency,hasLoaded,failure,isCreatingRequest,const DeepCollectionEquality().hash(_decidingPaymentIds));
}

@override
String toString() {
    return 'PaymentsState(status: $status, payments: $payments, summary: $summary, reportingPeriodStartUtc: $reportingPeriodStartUtc, reportingTimeZone: $reportingTimeZone, reportingCurrency: $reportingCurrency, hasLoaded: $hasLoaded, failure: $failure, isCreatingRequest: $isCreatingRequest, decidingPaymentIds: $decidingPaymentIds)';
}


}

/// @nodoc
abstract mixin class _$PaymentsStateCopyWith<$Res> implements $PaymentsStateCopyWith<$Res> {
  factory _$PaymentsStateCopyWith(_PaymentsState value, $Res Function(_PaymentsState) _then) = __$PaymentsStateCopyWithImpl;
@override @useResult
$Res call({
 PaymentsLoadStatus status, List<Payment> payments, PaymentSummary summary, DateTime reportingPeriodStartUtc, String reportingTimeZone, String reportingCurrency, bool hasLoaded, PaymentsFailure? failure, bool isCreatingRequest, Set<String> decidingPaymentIds
});


@override $PaymentSummaryCopyWith<$Res> get summary;@override $PaymentsFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$PaymentsStateCopyWithImpl<$Res>
    implements _$PaymentsStateCopyWith<$Res> {
  __$PaymentsStateCopyWithImpl(this._self, this._then);

  final _PaymentsState _self;
  final $Res Function(_PaymentsState) _then;

/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? payments = null,Object? summary = null,Object? reportingPeriodStartUtc = null,Object? reportingTimeZone = null,Object? reportingCurrency = null,Object? hasLoaded = null,Object? failure = freezed,Object? isCreatingRequest = null,Object? decidingPaymentIds = null,}) {
  return _then(_PaymentsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentsLoadStatus,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PaymentSummary,reportingPeriodStartUtc: null == reportingPeriodStartUtc ? _self.reportingPeriodStartUtc : reportingPeriodStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reportingTimeZone: null == reportingTimeZone ? _self.reportingTimeZone : reportingTimeZone // ignore: cast_nullable_to_non_nullable
as String,reportingCurrency: null == reportingCurrency ? _self.reportingCurrency : reportingCurrency // ignore: cast_nullable_to_non_nullable
as String,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PaymentsFailure?,isCreatingRequest: null == isCreatingRequest ? _self.isCreatingRequest : isCreatingRequest // ignore: cast_nullable_to_non_nullable
as bool,decidingPaymentIds: null == decidingPaymentIds ? _self._decidingPaymentIds : decidingPaymentIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res> get summary {

  return $PaymentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of PaymentsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $PaymentsFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
