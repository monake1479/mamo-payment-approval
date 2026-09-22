// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_sort.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsSort {

 PaymentsSortField get field; SortDirection get direction;
/// Create a copy of PaymentsSort
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSortCopyWith<PaymentsSort> get copyWith => _$PaymentsSortCopyWithImpl<PaymentsSort>(this as PaymentsSort, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsSort;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSort&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.direction, _this.direction) || other.direction == _this.direction));
}


@override
int get hashCode {
  final _this = this as PaymentsSort;
  return Object.hash(runtimeType,_this.field,_this.direction);
}

@override
String toString() {
  final _this = this as PaymentsSort;
  return 'PaymentsSort(field: ${_this.field}, direction: ${_this.direction})';
}


}

/// @nodoc
abstract mixin class $PaymentsSortCopyWith<$Res>  {
  factory $PaymentsSortCopyWith(PaymentsSort value, $Res Function(PaymentsSort) _then) = _$PaymentsSortCopyWithImpl;
@useResult
$Res call({
 PaymentsSortField field, SortDirection direction
});




}
/// @nodoc
class _$PaymentsSortCopyWithImpl<$Res>
    implements $PaymentsSortCopyWith<$Res> {
  _$PaymentsSortCopyWithImpl(this._self, this._then);

  final PaymentsSort _self;
  final $Res Function(PaymentsSort) _then;

/// Create a copy of PaymentsSort
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? direction = null,}) {
  return _then(PaymentsSort(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as PaymentsSortField,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SortDirection,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentsSort].
extension PaymentsSortPatterns on PaymentsSort {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsSort value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsSort() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsSort value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsSort():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsSort value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsSort() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentsSortField field,  SortDirection direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsSort() when $default != null:
return $default(_that.field,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentsSortField field,  SortDirection direction)  $default,) {final _that = this;
switch (_that) {
case _PaymentsSort():
return $default(_that.field,_that.direction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentsSortField field,  SortDirection direction)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsSort() when $default != null:
return $default(_that.field,_that.direction);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsSort implements PaymentsSort {
  const _PaymentsSort({required this.field, required this.direction});
  

@override final  PaymentsSortField field;
@override final  SortDirection direction;

/// Create a copy of PaymentsSort
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsSortCopyWith<_PaymentsSort> get copyWith => __$PaymentsSortCopyWithImpl<_PaymentsSort>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsSort&&(identical(other.field, field) || other.field == field)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field,direction);
}

@override
String toString() {
    return 'PaymentsSort(field: $field, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$PaymentsSortCopyWith<$Res> implements $PaymentsSortCopyWith<$Res> {
  factory _$PaymentsSortCopyWith(_PaymentsSort value, $Res Function(_PaymentsSort) _then) = __$PaymentsSortCopyWithImpl;
@override @useResult
$Res call({
 PaymentsSortField field, SortDirection direction
});




}
/// @nodoc
class __$PaymentsSortCopyWithImpl<$Res>
    implements _$PaymentsSortCopyWith<$Res> {
  __$PaymentsSortCopyWithImpl(this._self, this._then);

  final _PaymentsSort _self;
  final $Res Function(_PaymentsSort) _then;

/// Create a copy of PaymentsSort
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? direction = null,}) {
  return _then(_PaymentsSort(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as PaymentsSortField,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SortDirection,
  ));
}


}

// dart format on
