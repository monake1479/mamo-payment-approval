// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debug_action_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DebugActionState {

 double get x; double get y;
/// Create a copy of DebugActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebugActionStateCopyWith<DebugActionState> get copyWith => _$DebugActionStateCopyWithImpl<DebugActionState>(this as DebugActionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DebugActionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DebugActionState&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y));
}


@override
int get hashCode {
  final _this = this as DebugActionState;
  return Object.hash(runtimeType,_this.x,_this.y);
}

@override
String toString() {
  final _this = this as DebugActionState;
  return 'DebugActionState(x: ${_this.x}, y: ${_this.y})';
}


}

/// @nodoc
abstract mixin class $DebugActionStateCopyWith<$Res>  {
  factory $DebugActionStateCopyWith(DebugActionState value, $Res Function(DebugActionState) _then) = _$DebugActionStateCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$DebugActionStateCopyWithImpl<$Res>
    implements $DebugActionStateCopyWith<$Res> {
  _$DebugActionStateCopyWithImpl(this._self, this._then);

  final DebugActionState _self;
  final $Res Function(DebugActionState) _then;

/// Create a copy of DebugActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(DebugActionState(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DebugActionState].
extension DebugActionStatePatterns on DebugActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DebugActionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DebugActionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DebugActionState value)  $default,){
final _that = this;
switch (_that) {
case _DebugActionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DebugActionState value)?  $default,){
final _that = this;
switch (_that) {
case _DebugActionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DebugActionState() when $default != null:
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _DebugActionState():
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _DebugActionState() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc


class _DebugActionState implements DebugActionState {
  const _DebugActionState({required this.x, required this.y});
  

@override final  double x;
@override final  double y;

/// Create a copy of DebugActionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebugActionStateCopyWith<_DebugActionState> get copyWith => __$DebugActionStateCopyWithImpl<_DebugActionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DebugActionState&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode {
    return Object.hash(runtimeType,x,y);
}

@override
String toString() {
    return 'DebugActionState(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$DebugActionStateCopyWith<$Res> implements $DebugActionStateCopyWith<$Res> {
  factory _$DebugActionStateCopyWith(_DebugActionState value, $Res Function(_DebugActionState) _then) = __$DebugActionStateCopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$DebugActionStateCopyWithImpl<$Res>
    implements _$DebugActionStateCopyWith<$Res> {
  __$DebugActionStateCopyWithImpl(this._self, this._then);

  final _DebugActionState _self;
  final $Res Function(_DebugActionState) _then;

/// Create a copy of DebugActionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_DebugActionState(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
