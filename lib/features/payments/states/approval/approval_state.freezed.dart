// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approval_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApprovalState {

 Payment get request; ApprovalPhase get phase; bool get isRevealed; ApprovalFailure? get failure; PaymentDecision? get completedDecision;
/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalStateCopyWith<ApprovalState> get copyWith => _$ApprovalStateCopyWithImpl<ApprovalState>(this as ApprovalState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApprovalState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalState&&(identical(other.request, _this.request) || other.request == _this.request)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.isRevealed, _this.isRevealed) || other.isRevealed == _this.isRevealed)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.completedDecision, _this.completedDecision) || other.completedDecision == _this.completedDecision));
}


@override
int get hashCode {
  final _this = this as ApprovalState;
  return Object.hash(runtimeType,_this.request,_this.phase,_this.isRevealed,_this.failure,_this.completedDecision);
}

@override
String toString() {
  final _this = this as ApprovalState;
  return 'ApprovalState(request: ${_this.request}, phase: ${_this.phase}, isRevealed: ${_this.isRevealed}, failure: ${_this.failure}, completedDecision: ${_this.completedDecision})';
}


}

/// @nodoc
abstract mixin class $ApprovalStateCopyWith<$Res>  {
  factory $ApprovalStateCopyWith(ApprovalState value, $Res Function(ApprovalState) _then) = _$ApprovalStateCopyWithImpl;
@useResult
$Res call({
 Payment request, ApprovalPhase phase, bool isRevealed, ApprovalFailure? failure, PaymentDecision? completedDecision
});


$PaymentCopyWith<$Res> get request;$ApprovalFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ApprovalStateCopyWithImpl<$Res>
    implements $ApprovalStateCopyWith<$Res> {
  _$ApprovalStateCopyWithImpl(this._self, this._then);

  final ApprovalState _self;
  final $Res Function(ApprovalState) _then;

/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? phase = null,Object? isRevealed = null,Object? failure = freezed,Object? completedDecision = freezed,}) {
  return _then(ApprovalState(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as Payment,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ApprovalPhase,isRevealed: null == isRevealed ? _self.isRevealed : isRevealed // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ApprovalFailure?,completedDecision: freezed == completedDecision ? _self.completedDecision : completedDecision // ignore: cast_nullable_to_non_nullable
as PaymentDecision?,
  ));
}
/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get request {
  
  return $PaymentCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApprovalFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $ApprovalFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApprovalState].
extension ApprovalStatePatterns on ApprovalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalState value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalState value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Payment request,  ApprovalPhase phase,  bool isRevealed,  ApprovalFailure? failure,  PaymentDecision? completedDecision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApprovalState() when $default != null:
return $default(_that.request,_that.phase,_that.isRevealed,_that.failure,_that.completedDecision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Payment request,  ApprovalPhase phase,  bool isRevealed,  ApprovalFailure? failure,  PaymentDecision? completedDecision)  $default,) {final _that = this;
switch (_that) {
case _ApprovalState():
return $default(_that.request,_that.phase,_that.isRevealed,_that.failure,_that.completedDecision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Payment request,  ApprovalPhase phase,  bool isRevealed,  ApprovalFailure? failure,  PaymentDecision? completedDecision)?  $default,) {final _that = this;
switch (_that) {
case _ApprovalState() when $default != null:
return $default(_that.request,_that.phase,_that.isRevealed,_that.failure,_that.completedDecision);case _:
  return null;

}
}

}

/// @nodoc


class _ApprovalState extends ApprovalState {
  const _ApprovalState({required this.request, required this.phase, required this.isRevealed, required this.failure, required this.completedDecision}): super._();
  

@override final  Payment request;
@override final  ApprovalPhase phase;
@override final  bool isRevealed;
@override final  ApprovalFailure? failure;
@override final  PaymentDecision? completedDecision;

/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalStateCopyWith<_ApprovalState> get copyWith => __$ApprovalStateCopyWithImpl<_ApprovalState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalState&&(identical(other.request, request) || other.request == request)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.isRevealed, isRevealed) || other.isRevealed == isRevealed)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.completedDecision, completedDecision) || other.completedDecision == completedDecision));
}


@override
int get hashCode {
    return Object.hash(runtimeType,request,phase,isRevealed,failure,completedDecision);
}

@override
String toString() {
    return 'ApprovalState(request: $request, phase: $phase, isRevealed: $isRevealed, failure: $failure, completedDecision: $completedDecision)';
}


}

/// @nodoc
abstract mixin class _$ApprovalStateCopyWith<$Res> implements $ApprovalStateCopyWith<$Res> {
  factory _$ApprovalStateCopyWith(_ApprovalState value, $Res Function(_ApprovalState) _then) = __$ApprovalStateCopyWithImpl;
@override @useResult
$Res call({
 Payment request, ApprovalPhase phase, bool isRevealed, ApprovalFailure? failure, PaymentDecision? completedDecision
});


@override $PaymentCopyWith<$Res> get request;@override $ApprovalFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ApprovalStateCopyWithImpl<$Res>
    implements _$ApprovalStateCopyWith<$Res> {
  __$ApprovalStateCopyWithImpl(this._self, this._then);

  final _ApprovalState _self;
  final $Res Function(_ApprovalState) _then;

/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? phase = null,Object? isRevealed = null,Object? failure = freezed,Object? completedDecision = freezed,}) {
  return _then(_ApprovalState(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as Payment,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ApprovalPhase,isRevealed: null == isRevealed ? _self.isRevealed : isRevealed // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ApprovalFailure?,completedDecision: freezed == completedDecision ? _self.completedDecision : completedDecision // ignore: cast_nullable_to_non_nullable
as PaymentDecision?,
  ));
}

/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get request {
  
  return $PaymentCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ApprovalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApprovalFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $ApprovalFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
