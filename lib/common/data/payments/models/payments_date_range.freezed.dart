// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_date_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsDateRange {

 DateTime get startUtc; DateTime get endUtc;
/// Create a copy of PaymentsDateRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsDateRangeCopyWith<PaymentsDateRange> get copyWith => _$PaymentsDateRangeCopyWithImpl<PaymentsDateRange>(this as PaymentsDateRange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsDateRange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsDateRange&&(identical(other.startUtc, _this.startUtc) || other.startUtc == _this.startUtc)&&(identical(other.endUtc, _this.endUtc) || other.endUtc == _this.endUtc));
}


@override
int get hashCode {
  final _this = this as PaymentsDateRange;
  return Object.hash(runtimeType,_this.startUtc,_this.endUtc);
}

@override
String toString() {
  final _this = this as PaymentsDateRange;
  return 'PaymentsDateRange(startUtc: ${_this.startUtc}, endUtc: ${_this.endUtc})';
}


}

/// @nodoc
abstract mixin class $PaymentsDateRangeCopyWith<$Res>  {
  factory $PaymentsDateRangeCopyWith(PaymentsDateRange value, $Res Function(PaymentsDateRange) _then) = _$PaymentsDateRangeCopyWithImpl;
@useResult
$Res call({
 DateTime startUtc, DateTime endUtc
});




}
/// @nodoc
class _$PaymentsDateRangeCopyWithImpl<$Res>
    implements $PaymentsDateRangeCopyWith<$Res> {
  _$PaymentsDateRangeCopyWithImpl(this._self, this._then);

  final PaymentsDateRange _self;
  final $Res Function(PaymentsDateRange) _then;

/// Create a copy of PaymentsDateRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startUtc = null,Object? endUtc = null,}) {
  return _then(PaymentsDateRange(
startUtc: null == startUtc ? _self.startUtc : startUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endUtc: null == endUtc ? _self.endUtc : endUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentsDateRange].
extension PaymentsDateRangePatterns on PaymentsDateRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsDateRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsDateRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsDateRange value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsDateRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsDateRange value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsDateRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startUtc,  DateTime endUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsDateRange() when $default != null:
return $default(_that.startUtc,_that.endUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startUtc,  DateTime endUtc)  $default,) {final _that = this;
switch (_that) {
case _PaymentsDateRange():
return $default(_that.startUtc,_that.endUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startUtc,  DateTime endUtc)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsDateRange() when $default != null:
return $default(_that.startUtc,_that.endUtc);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsDateRange implements PaymentsDateRange {
  const _PaymentsDateRange({required this.startUtc, required this.endUtc});
  

@override final  DateTime startUtc;
@override final  DateTime endUtc;

/// Create a copy of PaymentsDateRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsDateRangeCopyWith<_PaymentsDateRange> get copyWith => __$PaymentsDateRangeCopyWithImpl<_PaymentsDateRange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsDateRange&&(identical(other.startUtc, startUtc) || other.startUtc == startUtc)&&(identical(other.endUtc, endUtc) || other.endUtc == endUtc));
}


@override
int get hashCode {
    return Object.hash(runtimeType,startUtc,endUtc);
}

@override
String toString() {
    return 'PaymentsDateRange(startUtc: $startUtc, endUtc: $endUtc)';
}


}

/// @nodoc
abstract mixin class _$PaymentsDateRangeCopyWith<$Res> implements $PaymentsDateRangeCopyWith<$Res> {
  factory _$PaymentsDateRangeCopyWith(_PaymentsDateRange value, $Res Function(_PaymentsDateRange) _then) = __$PaymentsDateRangeCopyWithImpl;
@override @useResult
$Res call({
 DateTime startUtc, DateTime endUtc
});




}
/// @nodoc
class __$PaymentsDateRangeCopyWithImpl<$Res>
    implements _$PaymentsDateRangeCopyWith<$Res> {
  __$PaymentsDateRangeCopyWithImpl(this._self, this._then);

  final _PaymentsDateRange _self;
  final $Res Function(_PaymentsDateRange) _then;

/// Create a copy of PaymentsDateRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startUtc = null,Object? endUtc = null,}) {
  return _then(_PaymentsDateRange(
startUtc: null == startUtc ? _self.startUtc : startUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endUtc: null == endUtc ? _self.endUtc : endUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
