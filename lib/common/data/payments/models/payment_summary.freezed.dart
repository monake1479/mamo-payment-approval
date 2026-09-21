// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentSummary {

 double get approvedAmount; int get approvedCount;
/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<PaymentSummary> get copyWith => _$PaymentSummaryCopyWithImpl<PaymentSummary>(this as PaymentSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSummary&&(identical(other.approvedAmount, _this.approvedAmount) || other.approvedAmount == _this.approvedAmount)&&(identical(other.approvedCount, _this.approvedCount) || other.approvedCount == _this.approvedCount));
}


@override
int get hashCode {
  final _this = this as PaymentSummary;
  return Object.hash(runtimeType,_this.approvedAmount,_this.approvedCount);
}

@override
String toString() {
  final _this = this as PaymentSummary;
  return 'PaymentSummary(approvedAmount: ${_this.approvedAmount}, approvedCount: ${_this.approvedCount})';
}


}

/// @nodoc
abstract mixin class $PaymentSummaryCopyWith<$Res>  {
  factory $PaymentSummaryCopyWith(PaymentSummary value, $Res Function(PaymentSummary) _then) = _$PaymentSummaryCopyWithImpl;
@useResult
$Res call({
 double approvedAmount, int approvedCount
});




}
/// @nodoc
class _$PaymentSummaryCopyWithImpl<$Res>
    implements $PaymentSummaryCopyWith<$Res> {
  _$PaymentSummaryCopyWithImpl(this._self, this._then);

  final PaymentSummary _self;
  final $Res Function(PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? approvedAmount = null,Object? approvedCount = null,}) {
  return _then(PaymentSummary(
approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as double,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentSummary].
extension PaymentSummaryPatterns on PaymentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSummary value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double approvedAmount,  int approvedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.approvedAmount,_that.approvedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double approvedAmount,  int approvedCount)  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary():
return $default(_that.approvedAmount,_that.approvedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double approvedAmount,  int approvedCount)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.approvedAmount,_that.approvedCount);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentSummary implements PaymentSummary {
  const _PaymentSummary({required this.approvedAmount, required this.approvedCount});
  

@override final  double approvedAmount;
@override final  int approvedCount;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSummaryCopyWith<_PaymentSummary> get copyWith => __$PaymentSummaryCopyWithImpl<_PaymentSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSummary&&(identical(other.approvedAmount, approvedAmount) || other.approvedAmount == approvedAmount)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,approvedAmount,approvedCount);
}

@override
String toString() {
    return 'PaymentSummary(approvedAmount: $approvedAmount, approvedCount: $approvedCount)';
}


}

/// @nodoc
abstract mixin class _$PaymentSummaryCopyWith<$Res> implements $PaymentSummaryCopyWith<$Res> {
  factory _$PaymentSummaryCopyWith(_PaymentSummary value, $Res Function(_PaymentSummary) _then) = __$PaymentSummaryCopyWithImpl;
@override @useResult
$Res call({
 double approvedAmount, int approvedCount
});




}
/// @nodoc
class __$PaymentSummaryCopyWithImpl<$Res>
    implements _$PaymentSummaryCopyWith<$Res> {
  __$PaymentSummaryCopyWithImpl(this._self, this._then);

  final _PaymentSummary _self;
  final $Res Function(_PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? approvedAmount = null,Object? approvedCount = null,}) {
  return _then(_PaymentSummary(
approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as double,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
