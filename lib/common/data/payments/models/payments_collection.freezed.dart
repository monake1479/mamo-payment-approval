// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsCollection {

 List<Payment> get payments; PaymentSummary get summary; DateTime get reportingPeriodStartUtc; String get reportingTimeZone; String get reportingCurrency;
/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsCollectionCopyWith<PaymentsCollection> get copyWith => _$PaymentsCollectionCopyWithImpl<PaymentsCollection>(this as PaymentsCollection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsCollection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsCollection&&const DeepCollectionEquality().equals(other.payments, _this.payments)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.reportingPeriodStartUtc, _this.reportingPeriodStartUtc) || other.reportingPeriodStartUtc == _this.reportingPeriodStartUtc)&&(identical(other.reportingTimeZone, _this.reportingTimeZone) || other.reportingTimeZone == _this.reportingTimeZone)&&(identical(other.reportingCurrency, _this.reportingCurrency) || other.reportingCurrency == _this.reportingCurrency));
}


@override
int get hashCode {
  final _this = this as PaymentsCollection;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.payments),_this.summary,_this.reportingPeriodStartUtc,_this.reportingTimeZone,_this.reportingCurrency);
}

@override
String toString() {
  final _this = this as PaymentsCollection;
  return 'PaymentsCollection(payments: ${_this.payments}, summary: ${_this.summary}, reportingPeriodStartUtc: ${_this.reportingPeriodStartUtc}, reportingTimeZone: ${_this.reportingTimeZone}, reportingCurrency: ${_this.reportingCurrency})';
}


}

/// @nodoc
abstract mixin class $PaymentsCollectionCopyWith<$Res>  {
  factory $PaymentsCollectionCopyWith(PaymentsCollection value, $Res Function(PaymentsCollection) _then) = _$PaymentsCollectionCopyWithImpl;
@useResult
$Res call({
 List<Payment> payments, PaymentSummary summary, DateTime reportingPeriodStartUtc, String reportingTimeZone, String reportingCurrency
});


$PaymentSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$PaymentsCollectionCopyWithImpl<$Res>
    implements $PaymentsCollectionCopyWith<$Res> {
  _$PaymentsCollectionCopyWithImpl(this._self, this._then);

  final PaymentsCollection _self;
  final $Res Function(PaymentsCollection) _then;

/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payments = null,Object? summary = null,Object? reportingPeriodStartUtc = null,Object? reportingTimeZone = null,Object? reportingCurrency = null,}) {
  return _then(PaymentsCollection(
payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PaymentSummary,reportingPeriodStartUtc: null == reportingPeriodStartUtc ? _self.reportingPeriodStartUtc : reportingPeriodStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reportingTimeZone: null == reportingTimeZone ? _self.reportingTimeZone : reportingTimeZone // ignore: cast_nullable_to_non_nullable
as String,reportingCurrency: null == reportingCurrency ? _self.reportingCurrency : reportingCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res> get summary {
  
  return $PaymentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentsCollection].
extension PaymentsCollectionPatterns on PaymentsCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsCollection value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsCollection value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsCollection() when $default != null:
return $default(_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency)  $default,) {final _that = this;
switch (_that) {
case _PaymentsCollection():
return $default(_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Payment> payments,  PaymentSummary summary,  DateTime reportingPeriodStartUtc,  String reportingTimeZone,  String reportingCurrency)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsCollection() when $default != null:
return $default(_that.payments,_that.summary,_that.reportingPeriodStartUtc,_that.reportingTimeZone,_that.reportingCurrency);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsCollection extends PaymentsCollection {
  const _PaymentsCollection({required  List<Payment> payments, required this.summary, required this.reportingPeriodStartUtc, required this.reportingTimeZone, required this.reportingCurrency}): _payments = payments,super._();
  

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

/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsCollectionCopyWith<_PaymentsCollection> get copyWith => __$PaymentsCollectionCopyWithImpl<_PaymentsCollection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsCollection&&const DeepCollectionEquality().equals(other.payments, _payments)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.reportingPeriodStartUtc, reportingPeriodStartUtc) || other.reportingPeriodStartUtc == reportingPeriodStartUtc)&&(identical(other.reportingTimeZone, reportingTimeZone) || other.reportingTimeZone == reportingTimeZone)&&(identical(other.reportingCurrency, reportingCurrency) || other.reportingCurrency == reportingCurrency));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_payments),summary,reportingPeriodStartUtc,reportingTimeZone,reportingCurrency);
}

@override
String toString() {
    return 'PaymentsCollection(payments: $payments, summary: $summary, reportingPeriodStartUtc: $reportingPeriodStartUtc, reportingTimeZone: $reportingTimeZone, reportingCurrency: $reportingCurrency)';
}


}

/// @nodoc
abstract mixin class _$PaymentsCollectionCopyWith<$Res> implements $PaymentsCollectionCopyWith<$Res> {
  factory _$PaymentsCollectionCopyWith(_PaymentsCollection value, $Res Function(_PaymentsCollection) _then) = __$PaymentsCollectionCopyWithImpl;
@override @useResult
$Res call({
 List<Payment> payments, PaymentSummary summary, DateTime reportingPeriodStartUtc, String reportingTimeZone, String reportingCurrency
});


@override $PaymentSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$PaymentsCollectionCopyWithImpl<$Res>
    implements _$PaymentsCollectionCopyWith<$Res> {
  __$PaymentsCollectionCopyWithImpl(this._self, this._then);

  final _PaymentsCollection _self;
  final $Res Function(_PaymentsCollection) _then;

/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payments = null,Object? summary = null,Object? reportingPeriodStartUtc = null,Object? reportingTimeZone = null,Object? reportingCurrency = null,}) {
  return _then(_PaymentsCollection(
payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PaymentSummary,reportingPeriodStartUtc: null == reportingPeriodStartUtc ? _self.reportingPeriodStartUtc : reportingPeriodStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reportingTimeZone: null == reportingTimeZone ? _self.reportingTimeZone : reportingTimeZone // ignore: cast_nullable_to_non_nullable
as String,reportingCurrency: null == reportingCurrency ? _self.reportingCurrency : reportingCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PaymentsCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res> get summary {
  
  return $PaymentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
