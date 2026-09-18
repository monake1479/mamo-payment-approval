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
mixin _$DebugActionPosition {

 double get x; double get y;
/// Create a copy of DebugActionPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebugActionPositionCopyWith<DebugActionPosition> get copyWith => _$DebugActionPositionCopyWithImpl<DebugActionPosition>(this as DebugActionPosition, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DebugActionPosition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DebugActionPosition&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y));
}


@override
int get hashCode {
  final _this = this as DebugActionPosition;
  return Object.hash(runtimeType,_this.x,_this.y);
}

@override
String toString() {
  final _this = this as DebugActionPosition;
  return 'DebugActionPosition(x: ${_this.x}, y: ${_this.y})';
}


}

/// @nodoc
abstract mixin class $DebugActionPositionCopyWith<$Res>  {
  factory $DebugActionPositionCopyWith(DebugActionPosition value, $Res Function(DebugActionPosition) _then) = _$DebugActionPositionCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$DebugActionPositionCopyWithImpl<$Res>
    implements $DebugActionPositionCopyWith<$Res> {
  _$DebugActionPositionCopyWithImpl(this._self, this._then);

  final DebugActionPosition _self;
  final $Res Function(DebugActionPosition) _then;

/// Create a copy of DebugActionPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(DebugActionPosition(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DebugActionPosition].
extension DebugActionPositionPatterns on DebugActionPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DebugActionPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DebugActionPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DebugActionPosition value)  $default,){
final _that = this;
switch (_that) {
case _DebugActionPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DebugActionPosition value)?  $default,){
final _that = this;
switch (_that) {
case _DebugActionPosition() when $default != null:
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
case _DebugActionPosition() when $default != null:
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
case _DebugActionPosition():
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
case _DebugActionPosition() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc


class _DebugActionPosition implements DebugActionPosition {
  const _DebugActionPosition({required this.x, required this.y});


@override final  double x;
@override final  double y;

/// Create a copy of DebugActionPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebugActionPositionCopyWith<_DebugActionPosition> get copyWith => __$DebugActionPositionCopyWithImpl<_DebugActionPosition>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DebugActionPosition&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode {
    return Object.hash(runtimeType,x,y);
}

@override
String toString() {
    return 'DebugActionPosition(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$DebugActionPositionCopyWith<$Res> implements $DebugActionPositionCopyWith<$Res> {
  factory _$DebugActionPositionCopyWith(_DebugActionPosition value, $Res Function(_DebugActionPosition) _then) = __$DebugActionPositionCopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$DebugActionPositionCopyWithImpl<$Res>
    implements _$DebugActionPositionCopyWith<$Res> {
  __$DebugActionPositionCopyWithImpl(this._self, this._then);

  final _DebugActionPosition _self;
  final $Res Function(_DebugActionPosition) _then;

/// Create a copy of DebugActionPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_DebugActionPosition(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
