// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentDto {

 String get id; String get counterparty;@PaymentAmountJsonConverter() double get amount; String get currency; String get reference;@UtcDateTimeJsonConverter() DateTime get createdAt; PaymentStatus get status;@UtcDateTimeJsonConverter() DateTime? get decidedAt;
/// Create a copy of PaymentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentDtoCopyWith<PaymentDto> get copyWith => _$PaymentDtoCopyWithImpl<PaymentDto>(this as PaymentDto, _$identity);

  /// Serializes this PaymentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.counterparty, _this.counterparty) || other.counterparty == _this.counterparty)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.decidedAt, _this.decidedAt) || other.decidedAt == _this.decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentDto;
  return Object.hash(runtimeType,_this.id,_this.counterparty,_this.amount,_this.currency,_this.reference,_this.createdAt,_this.status,_this.decidedAt);
}

@override
String toString() {
  final _this = this as PaymentDto;
  return 'PaymentDto(id: ${_this.id}, counterparty: ${_this.counterparty}, amount: ${_this.amount}, currency: ${_this.currency}, reference: ${_this.reference}, createdAt: ${_this.createdAt}, status: ${_this.status}, decidedAt: ${_this.decidedAt})';
}


}

/// @nodoc
abstract mixin class $PaymentDtoCopyWith<$Res>  {
  factory $PaymentDtoCopyWith(PaymentDto value, $Res Function(PaymentDto) _then) = _$PaymentDtoCopyWithImpl;
@useResult
$Res call({
 String id, String counterparty,@PaymentAmountJsonConverter() double amount, String currency, String reference,@UtcDateTimeJsonConverter() DateTime createdAt, PaymentStatus status,@UtcDateTimeJsonConverter() DateTime? decidedAt
});




}
/// @nodoc
class _$PaymentDtoCopyWithImpl<$Res>
    implements $PaymentDtoCopyWith<$Res> {
  _$PaymentDtoCopyWithImpl(this._self, this._then);

  final PaymentDto _self;
  final $Res Function(PaymentDto) _then;

/// Create a copy of PaymentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? counterparty = null,Object? amount = null,Object? currency = null,Object? reference = null,Object? createdAt = null,Object? status = null,Object? decidedAt = freezed,}) {
  return _then(PaymentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,counterparty: null == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentDto].
extension PaymentDtoPatterns on PaymentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String counterparty, @PaymentAmountJsonConverter()  double amount,  String currency,  String reference, @UtcDateTimeJsonConverter()  DateTime createdAt,  PaymentStatus status, @UtcDateTimeJsonConverter()  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentDto() when $default != null:
return $default(_that.id,_that.counterparty,_that.amount,_that.currency,_that.reference,_that.createdAt,_that.status,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String counterparty, @PaymentAmountJsonConverter()  double amount,  String currency,  String reference, @UtcDateTimeJsonConverter()  DateTime createdAt,  PaymentStatus status, @UtcDateTimeJsonConverter()  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentDto():
return $default(_that.id,_that.counterparty,_that.amount,_that.currency,_that.reference,_that.createdAt,_that.status,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String counterparty, @PaymentAmountJsonConverter()  double amount,  String currency,  String reference, @UtcDateTimeJsonConverter()  DateTime createdAt,  PaymentStatus status, @UtcDateTimeJsonConverter()  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentDto() when $default != null:
return $default(_that.id,_that.counterparty,_that.amount,_that.currency,_that.reference,_that.createdAt,_that.status,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentDto extends PaymentDto {
  const _PaymentDto({required this.id, required this.counterparty, @PaymentAmountJsonConverter() required this.amount, required this.currency, required this.reference, @UtcDateTimeJsonConverter() required this.createdAt, required this.status, @UtcDateTimeJsonConverter() this.decidedAt}): super._();
  factory _PaymentDto.fromJson(Map<String, dynamic> json) => _$PaymentDtoFromJson(json);

@override final  String id;
@override final  String counterparty;
@override@PaymentAmountJsonConverter() final  double amount;
@override final  String currency;
@override final  String reference;
@override@UtcDateTimeJsonConverter() final  DateTime createdAt;
@override final  PaymentStatus status;
@override@UtcDateTimeJsonConverter() final  DateTime? decidedAt;

/// Create a copy of PaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentDtoCopyWith<_PaymentDto> get copyWith => __$PaymentDtoCopyWithImpl<_PaymentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.counterparty, counterparty) || other.counterparty == counterparty)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,counterparty,amount,currency,reference,createdAt,status,decidedAt);
}

@override
String toString() {
    return 'PaymentDto(id: $id, counterparty: $counterparty, amount: $amount, currency: $currency, reference: $reference, createdAt: $createdAt, status: $status, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentDtoCopyWith<$Res> implements $PaymentDtoCopyWith<$Res> {
  factory _$PaymentDtoCopyWith(_PaymentDto value, $Res Function(_PaymentDto) _then) = __$PaymentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String counterparty,@PaymentAmountJsonConverter() double amount, String currency, String reference,@UtcDateTimeJsonConverter() DateTime createdAt, PaymentStatus status,@UtcDateTimeJsonConverter() DateTime? decidedAt
});




}
/// @nodoc
class __$PaymentDtoCopyWithImpl<$Res>
    implements _$PaymentDtoCopyWith<$Res> {
  __$PaymentDtoCopyWithImpl(this._self, this._then);

  final _PaymentDto _self;
  final $Res Function(_PaymentDto) _then;

/// Create a copy of PaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? counterparty = null,Object? amount = null,Object? currency = null,Object? reference = null,Object? createdAt = null,Object? status = null,Object? decidedAt = freezed,}) {
  return _then(_PaymentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,counterparty: null == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
