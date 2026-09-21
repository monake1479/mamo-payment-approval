// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_authentication_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceAuthenticationFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceAuthenticationFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeviceAuthenticationFailure()';
}


}

/// @nodoc
class $DeviceAuthenticationFailureCopyWith<$Res>  {
$DeviceAuthenticationFailureCopyWith(DeviceAuthenticationFailure _, $Res Function(DeviceAuthenticationFailure) __);
}


/// Adds pattern-matching-related methods to [DeviceAuthenticationFailure].
extension DeviceAuthenticationFailurePatterns on DeviceAuthenticationFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeviceAuthenticationCancelledFailure value)?  cancelled,TResult Function( DeviceAuthenticationUnavailableFailure value)?  unavailable,TResult Function( DeviceAuthenticationFailedFailure value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure() when cancelled != null:
return cancelled(_that);case DeviceAuthenticationUnavailableFailure() when unavailable != null:
return unavailable(_that);case DeviceAuthenticationFailedFailure() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeviceAuthenticationCancelledFailure value)  cancelled,required TResult Function( DeviceAuthenticationUnavailableFailure value)  unavailable,required TResult Function( DeviceAuthenticationFailedFailure value)  failed,}){
final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure():
return cancelled(_that);case DeviceAuthenticationUnavailableFailure():
return unavailable(_that);case DeviceAuthenticationFailedFailure():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeviceAuthenticationCancelledFailure value)?  cancelled,TResult? Function( DeviceAuthenticationUnavailableFailure value)?  unavailable,TResult? Function( DeviceAuthenticationFailedFailure value)?  failed,}){
final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure() when cancelled != null:
return cancelled(_that);case DeviceAuthenticationUnavailableFailure() when unavailable != null:
return unavailable(_that);case DeviceAuthenticationFailedFailure() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  cancelled,TResult Function()?  unavailable,TResult Function()?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure() when cancelled != null:
return cancelled();case DeviceAuthenticationUnavailableFailure() when unavailable != null:
return unavailable();case DeviceAuthenticationFailedFailure() when failed != null:
return failed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  cancelled,required TResult Function()  unavailable,required TResult Function()  failed,}) {final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure():
return cancelled();case DeviceAuthenticationUnavailableFailure():
return unavailable();case DeviceAuthenticationFailedFailure():
return failed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  cancelled,TResult? Function()?  unavailable,TResult? Function()?  failed,}) {final _that = this;
switch (_that) {
case DeviceAuthenticationCancelledFailure() when cancelled != null:
return cancelled();case DeviceAuthenticationUnavailableFailure() when unavailable != null:
return unavailable();case DeviceAuthenticationFailedFailure() when failed != null:
return failed();case _:
  return null;

}
}

}

/// @nodoc


class DeviceAuthenticationCancelledFailure extends DeviceAuthenticationFailure {
  const DeviceAuthenticationCancelledFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceAuthenticationCancelledFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeviceAuthenticationFailure.cancelled()';
}


}




/// @nodoc


class DeviceAuthenticationUnavailableFailure extends DeviceAuthenticationFailure {
  const DeviceAuthenticationUnavailableFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceAuthenticationUnavailableFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeviceAuthenticationFailure.unavailable()';
}


}




/// @nodoc


class DeviceAuthenticationFailedFailure extends DeviceAuthenticationFailure {
  const DeviceAuthenticationFailedFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceAuthenticationFailedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeviceAuthenticationFailure.failed()';
}


}




// dart format on
