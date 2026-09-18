// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure()';
}


}

/// @nodoc
class $PaymentsFailureCopyWith<$Res>  {
$PaymentsFailureCopyWith(PaymentsFailure _, $Res Function(PaymentsFailure) __);
}


/// Adds pattern-matching-related methods to [PaymentsFailure].
extension PaymentsFailurePatterns on PaymentsFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InvalidPaymentFailure value)?  invalidPayment,TResult Function( DuplicateRequestFailure value)?  duplicateRequest,TResult Function( PaymentNotFoundFailure value)?  paymentNotFound,TResult Function( PaymentAlreadyDecidedFailure value)?  paymentAlreadyDecided,TResult Function( PaymentBusyFailure value)?  paymentBusy,TResult Function( OperationCancelledFailure value)?  operationCancelled,TResult Function( PaymentsUnavailableFailure value)?  unavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InvalidPaymentFailure() when invalidPayment != null:
return invalidPayment(_that);case DuplicateRequestFailure() when duplicateRequest != null:
return duplicateRequest(_that);case PaymentNotFoundFailure() when paymentNotFound != null:
return paymentNotFound(_that);case PaymentAlreadyDecidedFailure() when paymentAlreadyDecided != null:
return paymentAlreadyDecided(_that);case PaymentBusyFailure() when paymentBusy != null:
return paymentBusy(_that);case OperationCancelledFailure() when operationCancelled != null:
return operationCancelled(_that);case PaymentsUnavailableFailure() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InvalidPaymentFailure value)  invalidPayment,required TResult Function( DuplicateRequestFailure value)  duplicateRequest,required TResult Function( PaymentNotFoundFailure value)  paymentNotFound,required TResult Function( PaymentAlreadyDecidedFailure value)  paymentAlreadyDecided,required TResult Function( PaymentBusyFailure value)  paymentBusy,required TResult Function( OperationCancelledFailure value)  operationCancelled,required TResult Function( PaymentsUnavailableFailure value)  unavailable,}){
final _that = this;
switch (_that) {
case InvalidPaymentFailure():
return invalidPayment(_that);case DuplicateRequestFailure():
return duplicateRequest(_that);case PaymentNotFoundFailure():
return paymentNotFound(_that);case PaymentAlreadyDecidedFailure():
return paymentAlreadyDecided(_that);case PaymentBusyFailure():
return paymentBusy(_that);case OperationCancelledFailure():
return operationCancelled(_that);case PaymentsUnavailableFailure():
return unavailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InvalidPaymentFailure value)?  invalidPayment,TResult? Function( DuplicateRequestFailure value)?  duplicateRequest,TResult? Function( PaymentNotFoundFailure value)?  paymentNotFound,TResult? Function( PaymentAlreadyDecidedFailure value)?  paymentAlreadyDecided,TResult? Function( PaymentBusyFailure value)?  paymentBusy,TResult? Function( OperationCancelledFailure value)?  operationCancelled,TResult? Function( PaymentsUnavailableFailure value)?  unavailable,}){
final _that = this;
switch (_that) {
case InvalidPaymentFailure() when invalidPayment != null:
return invalidPayment(_that);case DuplicateRequestFailure() when duplicateRequest != null:
return duplicateRequest(_that);case PaymentNotFoundFailure() when paymentNotFound != null:
return paymentNotFound(_that);case PaymentAlreadyDecidedFailure() when paymentAlreadyDecided != null:
return paymentAlreadyDecided(_that);case PaymentBusyFailure() when paymentBusy != null:
return paymentBusy(_that);case OperationCancelledFailure() when operationCancelled != null:
return operationCancelled(_that);case PaymentsUnavailableFailure() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( InvalidPaymentReason reason)?  invalidPayment,TResult Function()?  duplicateRequest,TResult Function()?  paymentNotFound,TResult Function()?  paymentAlreadyDecided,TResult Function()?  paymentBusy,TResult Function()?  operationCancelled,TResult Function()?  unavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InvalidPaymentFailure() when invalidPayment != null:
return invalidPayment(_that.reason);case DuplicateRequestFailure() when duplicateRequest != null:
return duplicateRequest();case PaymentNotFoundFailure() when paymentNotFound != null:
return paymentNotFound();case PaymentAlreadyDecidedFailure() when paymentAlreadyDecided != null:
return paymentAlreadyDecided();case PaymentBusyFailure() when paymentBusy != null:
return paymentBusy();case OperationCancelledFailure() when operationCancelled != null:
return operationCancelled();case PaymentsUnavailableFailure() when unavailable != null:
return unavailable();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( InvalidPaymentReason reason)  invalidPayment,required TResult Function()  duplicateRequest,required TResult Function()  paymentNotFound,required TResult Function()  paymentAlreadyDecided,required TResult Function()  paymentBusy,required TResult Function()  operationCancelled,required TResult Function()  unavailable,}) {final _that = this;
switch (_that) {
case InvalidPaymentFailure():
return invalidPayment(_that.reason);case DuplicateRequestFailure():
return duplicateRequest();case PaymentNotFoundFailure():
return paymentNotFound();case PaymentAlreadyDecidedFailure():
return paymentAlreadyDecided();case PaymentBusyFailure():
return paymentBusy();case OperationCancelledFailure():
return operationCancelled();case PaymentsUnavailableFailure():
return unavailable();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( InvalidPaymentReason reason)?  invalidPayment,TResult? Function()?  duplicateRequest,TResult? Function()?  paymentNotFound,TResult? Function()?  paymentAlreadyDecided,TResult? Function()?  paymentBusy,TResult? Function()?  operationCancelled,TResult? Function()?  unavailable,}) {final _that = this;
switch (_that) {
case InvalidPaymentFailure() when invalidPayment != null:
return invalidPayment(_that.reason);case DuplicateRequestFailure() when duplicateRequest != null:
return duplicateRequest();case PaymentNotFoundFailure() when paymentNotFound != null:
return paymentNotFound();case PaymentAlreadyDecidedFailure() when paymentAlreadyDecided != null:
return paymentAlreadyDecided();case PaymentBusyFailure() when paymentBusy != null:
return paymentBusy();case OperationCancelledFailure() when operationCancelled != null:
return operationCancelled();case PaymentsUnavailableFailure() when unavailable != null:
return unavailable();case _:
  return null;

}
}

}

/// @nodoc


class InvalidPaymentFailure extends PaymentsFailure {
  const InvalidPaymentFailure(this.reason): super._();


 final  InvalidPaymentReason reason;

/// Create a copy of PaymentsFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidPaymentFailureCopyWith<InvalidPaymentFailure> get copyWith => _$InvalidPaymentFailureCopyWithImpl<InvalidPaymentFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidPaymentFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'PaymentsFailure.invalidPayment(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $InvalidPaymentFailureCopyWith<$Res> implements $PaymentsFailureCopyWith<$Res> {
  factory $InvalidPaymentFailureCopyWith(InvalidPaymentFailure value, $Res Function(InvalidPaymentFailure) _then) = _$InvalidPaymentFailureCopyWithImpl;
@useResult
$Res call({
 InvalidPaymentReason reason
});




}
/// @nodoc
class _$InvalidPaymentFailureCopyWithImpl<$Res>
    implements $InvalidPaymentFailureCopyWith<$Res> {
  _$InvalidPaymentFailureCopyWithImpl(this._self, this._then);

  final InvalidPaymentFailure _self;
  final $Res Function(InvalidPaymentFailure) _then;

/// Create a copy of PaymentsFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(InvalidPaymentFailure(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as InvalidPaymentReason,
  ));
}


}

/// @nodoc


class DuplicateRequestFailure extends PaymentsFailure {
  const DuplicateRequestFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateRequestFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.duplicateRequest()';
}


}




/// @nodoc


class PaymentNotFoundFailure extends PaymentsFailure {
  const PaymentNotFoundFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentNotFoundFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.paymentNotFound()';
}


}




/// @nodoc


class PaymentAlreadyDecidedFailure extends PaymentsFailure {
  const PaymentAlreadyDecidedFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentAlreadyDecidedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.paymentAlreadyDecided()';
}


}




/// @nodoc


class PaymentBusyFailure extends PaymentsFailure {
  const PaymentBusyFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentBusyFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.paymentBusy()';
}


}




/// @nodoc


class OperationCancelledFailure extends PaymentsFailure {
  const OperationCancelledFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperationCancelledFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.operationCancelled()';
}


}




/// @nodoc


class PaymentsUnavailableFailure extends PaymentsFailure {
  const PaymentsUnavailableFailure(): super._();







@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsUnavailableFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsFailure.unavailable()';
}


}




// dart format on
