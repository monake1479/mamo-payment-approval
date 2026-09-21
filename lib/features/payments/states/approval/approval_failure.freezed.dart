// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approval_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApprovalFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApprovalFailure()';
}


}

/// @nodoc
class $ApprovalFailureCopyWith<$Res>  {
$ApprovalFailureCopyWith(ApprovalFailure _, $Res Function(ApprovalFailure) __);
}


/// Adds pattern-matching-related methods to [ApprovalFailure].
extension ApprovalFailurePatterns on ApprovalFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApprovalAuthenticationError value)?  authentication,TResult Function( ApprovalDecisionError value)?  decision,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApprovalAuthenticationError() when authentication != null:
return authentication(_that);case ApprovalDecisionError() when decision != null:
return decision(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApprovalAuthenticationError value)  authentication,required TResult Function( ApprovalDecisionError value)  decision,}){
final _that = this;
switch (_that) {
case ApprovalAuthenticationError():
return authentication(_that);case ApprovalDecisionError():
return decision(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApprovalAuthenticationError value)?  authentication,TResult? Function( ApprovalDecisionError value)?  decision,}){
final _that = this;
switch (_that) {
case ApprovalAuthenticationError() when authentication != null:
return authentication(_that);case ApprovalDecisionError() when decision != null:
return decision(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ApprovalAuthenticationFailure reason)?  authentication,TResult Function( PaymentsFailure failure)?  decision,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApprovalAuthenticationError() when authentication != null:
return authentication(_that.reason);case ApprovalDecisionError() when decision != null:
return decision(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ApprovalAuthenticationFailure reason)  authentication,required TResult Function( PaymentsFailure failure)  decision,}) {final _that = this;
switch (_that) {
case ApprovalAuthenticationError():
return authentication(_that.reason);case ApprovalDecisionError():
return decision(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ApprovalAuthenticationFailure reason)?  authentication,TResult? Function( PaymentsFailure failure)?  decision,}) {final _that = this;
switch (_that) {
case ApprovalAuthenticationError() when authentication != null:
return authentication(_that.reason);case ApprovalDecisionError() when decision != null:
return decision(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ApprovalAuthenticationError implements ApprovalFailure {
  const ApprovalAuthenticationError(this.reason);
  

 final  ApprovalAuthenticationFailure reason;

/// Create a copy of ApprovalFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalAuthenticationErrorCopyWith<ApprovalAuthenticationError> get copyWith => _$ApprovalAuthenticationErrorCopyWithImpl<ApprovalAuthenticationError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalAuthenticationError&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ApprovalFailure.authentication(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ApprovalAuthenticationErrorCopyWith<$Res> implements $ApprovalFailureCopyWith<$Res> {
  factory $ApprovalAuthenticationErrorCopyWith(ApprovalAuthenticationError value, $Res Function(ApprovalAuthenticationError) _then) = _$ApprovalAuthenticationErrorCopyWithImpl;
@useResult
$Res call({
 ApprovalAuthenticationFailure reason
});




}
/// @nodoc
class _$ApprovalAuthenticationErrorCopyWithImpl<$Res>
    implements $ApprovalAuthenticationErrorCopyWith<$Res> {
  _$ApprovalAuthenticationErrorCopyWithImpl(this._self, this._then);

  final ApprovalAuthenticationError _self;
  final $Res Function(ApprovalAuthenticationError) _then;

/// Create a copy of ApprovalFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(ApprovalAuthenticationError(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ApprovalAuthenticationFailure,
  ));
}


}

/// @nodoc


class ApprovalDecisionError implements ApprovalFailure {
  const ApprovalDecisionError(this.failure);
  

 final  PaymentsFailure failure;

/// Create a copy of ApprovalFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalDecisionErrorCopyWith<ApprovalDecisionError> get copyWith => _$ApprovalDecisionErrorCopyWithImpl<ApprovalDecisionError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalDecisionError&&const DeepCollectionEquality().equals(other.failure, failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(failure));
}

@override
String toString() {
    return 'ApprovalFailure.decision(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ApprovalDecisionErrorCopyWith<$Res> implements $ApprovalFailureCopyWith<$Res> {
  factory $ApprovalDecisionErrorCopyWith(ApprovalDecisionError value, $Res Function(ApprovalDecisionError) _then) = _$ApprovalDecisionErrorCopyWithImpl;
@useResult
$Res call({
 PaymentsFailure failure
});




}
/// @nodoc
class _$ApprovalDecisionErrorCopyWithImpl<$Res>
    implements $ApprovalDecisionErrorCopyWith<$Res> {
  _$ApprovalDecisionErrorCopyWithImpl(this._self, this._then);

  final ApprovalDecisionError _self;
  final $Res Function(ApprovalDecisionError) _then;

/// Create a copy of ApprovalFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = freezed,}) {
  return _then(ApprovalDecisionError(
freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PaymentsFailure,
  ));
}


}

// dart format on
