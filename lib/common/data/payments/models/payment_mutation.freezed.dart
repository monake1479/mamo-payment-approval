// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_mutation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMutation {

 Payment get payment; PaymentsCollection get collection;
/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMutationCopyWith<PaymentMutation> get copyWith => _$PaymentMutationCopyWithImpl<PaymentMutation>(this as PaymentMutation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentMutation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMutation&&(identical(other.payment, _this.payment) || other.payment == _this.payment)&&(identical(other.collection, _this.collection) || other.collection == _this.collection));
}


@override
int get hashCode {
  final _this = this as PaymentMutation;
  return Object.hash(runtimeType,_this.payment,_this.collection);
}

@override
String toString() {
  final _this = this as PaymentMutation;
  return 'PaymentMutation(payment: ${_this.payment}, collection: ${_this.collection})';
}


}

/// @nodoc
abstract mixin class $PaymentMutationCopyWith<$Res>  {
  factory $PaymentMutationCopyWith(PaymentMutation value, $Res Function(PaymentMutation) _then) = _$PaymentMutationCopyWithImpl;
@useResult
$Res call({
 Payment payment, PaymentsCollection collection
});


$PaymentCopyWith<$Res> get payment;$PaymentsCollectionCopyWith<$Res> get collection;

}
/// @nodoc
class _$PaymentMutationCopyWithImpl<$Res>
    implements $PaymentMutationCopyWith<$Res> {
  _$PaymentMutationCopyWithImpl(this._self, this._then);

  final PaymentMutation _self;
  final $Res Function(PaymentMutation) _then;

/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payment = null,Object? collection = null,}) {
  return _then(PaymentMutation(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as PaymentsCollection,
  ));
}
/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsCollectionCopyWith<$Res> get collection {
  
  return $PaymentsCollectionCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentMutation].
extension PaymentMutationPatterns on PaymentMutation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMutation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMutation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMutation value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMutation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMutation value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMutation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Payment payment,  PaymentsCollection collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMutation() when $default != null:
return $default(_that.payment,_that.collection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Payment payment,  PaymentsCollection collection)  $default,) {final _that = this;
switch (_that) {
case _PaymentMutation():
return $default(_that.payment,_that.collection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Payment payment,  PaymentsCollection collection)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMutation() when $default != null:
return $default(_that.payment,_that.collection);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMutation implements PaymentMutation {
  const _PaymentMutation({required this.payment, required this.collection});
  

@override final  Payment payment;
@override final  PaymentsCollection collection;

/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMutationCopyWith<_PaymentMutation> get copyWith => __$PaymentMutationCopyWithImpl<_PaymentMutation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMutation&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.collection, collection) || other.collection == collection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,payment,collection);
}

@override
String toString() {
    return 'PaymentMutation(payment: $payment, collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$PaymentMutationCopyWith<$Res> implements $PaymentMutationCopyWith<$Res> {
  factory _$PaymentMutationCopyWith(_PaymentMutation value, $Res Function(_PaymentMutation) _then) = __$PaymentMutationCopyWithImpl;
@override @useResult
$Res call({
 Payment payment, PaymentsCollection collection
});


@override $PaymentCopyWith<$Res> get payment;@override $PaymentsCollectionCopyWith<$Res> get collection;

}
/// @nodoc
class __$PaymentMutationCopyWithImpl<$Res>
    implements _$PaymentMutationCopyWith<$Res> {
  __$PaymentMutationCopyWithImpl(this._self, this._then);

  final _PaymentMutation _self;
  final $Res Function(_PaymentMutation) _then;

/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? collection = null,}) {
  return _then(_PaymentMutation(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as PaymentsCollection,
  ));
}

/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of PaymentMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsCollectionCopyWith<$Res> get collection {
  
  return $PaymentsCollectionCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on
