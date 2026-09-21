// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_mode_option_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThemeModeOptionData {

 ThemePreference get value; IconData get icon; String get label; String get description;
/// Create a copy of ThemeModeOptionData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeModeOptionDataCopyWith<ThemeModeOptionData> get copyWith => _$ThemeModeOptionDataCopyWithImpl<ThemeModeOptionData>(this as ThemeModeOptionData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThemeModeOptionData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeModeOptionData&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.description, _this.description) || other.description == _this.description));
}


@override
int get hashCode {
  final _this = this as ThemeModeOptionData;
  return Object.hash(runtimeType,_this.value,_this.icon,_this.label,_this.description);
}

@override
String toString() {
  final _this = this as ThemeModeOptionData;
  return 'ThemeModeOptionData(value: ${_this.value}, icon: ${_this.icon}, label: ${_this.label}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ThemeModeOptionDataCopyWith<$Res>  {
  factory $ThemeModeOptionDataCopyWith(ThemeModeOptionData value, $Res Function(ThemeModeOptionData) _then) = _$ThemeModeOptionDataCopyWithImpl;
@useResult
$Res call({
 ThemePreference value, IconData icon, String label, String description
});




}
/// @nodoc
class _$ThemeModeOptionDataCopyWithImpl<$Res>
    implements $ThemeModeOptionDataCopyWith<$Res> {
  _$ThemeModeOptionDataCopyWithImpl(this._self, this._then);

  final ThemeModeOptionData _self;
  final $Res Function(ThemeModeOptionData) _then;

/// Create a copy of ThemeModeOptionData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? icon = null,Object? label = null,Object? description = null,}) {
  return _then(ThemeModeOptionData(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as ThemePreference,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeModeOptionData].
extension ThemeModeOptionDataPatterns on ThemeModeOptionData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeModeOptionData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeModeOptionData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeModeOptionData value)  $default,){
final _that = this;
switch (_that) {
case _ThemeModeOptionData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeModeOptionData value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeModeOptionData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemePreference value,  IconData icon,  String label,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeModeOptionData() when $default != null:
return $default(_that.value,_that.icon,_that.label,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemePreference value,  IconData icon,  String label,  String description)  $default,) {final _that = this;
switch (_that) {
case _ThemeModeOptionData():
return $default(_that.value,_that.icon,_that.label,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemePreference value,  IconData icon,  String label,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ThemeModeOptionData() when $default != null:
return $default(_that.value,_that.icon,_that.label,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _ThemeModeOptionData implements ThemeModeOptionData {
  const _ThemeModeOptionData({required this.value, required this.icon, required this.label, required this.description});
  

@override final  ThemePreference value;
@override final  IconData icon;
@override final  String label;
@override final  String description;

/// Create a copy of ThemeModeOptionData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeModeOptionDataCopyWith<_ThemeModeOptionData> get copyWith => __$ThemeModeOptionDataCopyWithImpl<_ThemeModeOptionData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeModeOptionData&&(identical(other.value, value) || other.value == value)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value,icon,label,description);
}

@override
String toString() {
    return 'ThemeModeOptionData(value: $value, icon: $icon, label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ThemeModeOptionDataCopyWith<$Res> implements $ThemeModeOptionDataCopyWith<$Res> {
  factory _$ThemeModeOptionDataCopyWith(_ThemeModeOptionData value, $Res Function(_ThemeModeOptionData) _then) = __$ThemeModeOptionDataCopyWithImpl;
@override @useResult
$Res call({
 ThemePreference value, IconData icon, String label, String description
});




}
/// @nodoc
class __$ThemeModeOptionDataCopyWithImpl<$Res>
    implements _$ThemeModeOptionDataCopyWith<$Res> {
  __$ThemeModeOptionDataCopyWithImpl(this._self, this._then);

  final _ThemeModeOptionData _self;
  final $Res Function(_ThemeModeOptionData) _then;

/// Create a copy of ThemeModeOptionData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? icon = null,Object? label = null,Object? description = null,}) {
  return _then(_ThemeModeOptionData(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as ThemePreference,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
