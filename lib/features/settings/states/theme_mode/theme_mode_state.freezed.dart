// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_mode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThemeModeState {

 ThemePreference get preference;
/// Create a copy of ThemeModeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeModeStateCopyWith<ThemeModeState> get copyWith => _$ThemeModeStateCopyWithImpl<ThemeModeState>(this as ThemeModeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThemeModeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeModeState&&(identical(other.preference, _this.preference) || other.preference == _this.preference));
}


@override
int get hashCode {
  final _this = this as ThemeModeState;
  return Object.hash(runtimeType,_this.preference);
}

@override
String toString() {
  final _this = this as ThemeModeState;
  return 'ThemeModeState(preference: ${_this.preference})';
}


}

/// @nodoc
abstract mixin class $ThemeModeStateCopyWith<$Res>  {
  factory $ThemeModeStateCopyWith(ThemeModeState value, $Res Function(ThemeModeState) _then) = _$ThemeModeStateCopyWithImpl;
@useResult
$Res call({
 ThemePreference preference
});




}
/// @nodoc
class _$ThemeModeStateCopyWithImpl<$Res>
    implements $ThemeModeStateCopyWith<$Res> {
  _$ThemeModeStateCopyWithImpl(this._self, this._then);

  final ThemeModeState _self;
  final $Res Function(ThemeModeState) _then;

/// Create a copy of ThemeModeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preference = null,}) {
  return _then(ThemeModeState(
preference: null == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as ThemePreference,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeModeState].
extension ThemeModeStatePatterns on ThemeModeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeModeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeModeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeModeState value)  $default,){
final _that = this;
switch (_that) {
case _ThemeModeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeModeState value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeModeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemePreference preference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeModeState() when $default != null:
return $default(_that.preference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemePreference preference)  $default,) {final _that = this;
switch (_that) {
case _ThemeModeState():
return $default(_that.preference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemePreference preference)?  $default,) {final _that = this;
switch (_that) {
case _ThemeModeState() when $default != null:
return $default(_that.preference);case _:
  return null;

}
}

}

/// @nodoc


class _ThemeModeState implements ThemeModeState {
  const _ThemeModeState({required this.preference});
  

@override final  ThemePreference preference;

/// Create a copy of ThemeModeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeModeStateCopyWith<_ThemeModeState> get copyWith => __$ThemeModeStateCopyWithImpl<_ThemeModeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeModeState&&(identical(other.preference, preference) || other.preference == preference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,preference);
}

@override
String toString() {
    return 'ThemeModeState(preference: $preference)';
}


}

/// @nodoc
abstract mixin class _$ThemeModeStateCopyWith<$Res> implements $ThemeModeStateCopyWith<$Res> {
  factory _$ThemeModeStateCopyWith(_ThemeModeState value, $Res Function(_ThemeModeState) _then) = __$ThemeModeStateCopyWithImpl;
@override @useResult
$Res call({
 ThemePreference preference
});




}
/// @nodoc
class __$ThemeModeStateCopyWithImpl<$Res>
    implements _$ThemeModeStateCopyWith<$Res> {
  __$ThemeModeStateCopyWithImpl(this._self, this._then);

  final _ThemeModeState _self;
  final $Res Function(_ThemeModeState) _then;

/// Create a copy of ThemeModeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preference = null,}) {
  return _then(_ThemeModeState(
preference: null == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as ThemePreference,
  ));
}


}

// dart format on
