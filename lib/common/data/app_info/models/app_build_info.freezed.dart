// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_build_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppBuildInfo {

 String get version; String get buildNumber; String get packageName;
/// Create a copy of AppBuildInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBuildInfoCopyWith<AppBuildInfo> get copyWith => _$AppBuildInfoCopyWithImpl<AppBuildInfo>(this as AppBuildInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppBuildInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBuildInfo&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.buildNumber, _this.buildNumber) || other.buildNumber == _this.buildNumber)&&(identical(other.packageName, _this.packageName) || other.packageName == _this.packageName));
}


@override
int get hashCode {
  final _this = this as AppBuildInfo;
  return Object.hash(runtimeType,_this.version,_this.buildNumber,_this.packageName);
}

@override
String toString() {
  final _this = this as AppBuildInfo;
  return 'AppBuildInfo(version: ${_this.version}, buildNumber: ${_this.buildNumber}, packageName: ${_this.packageName})';
}


}

/// @nodoc
abstract mixin class $AppBuildInfoCopyWith<$Res>  {
  factory $AppBuildInfoCopyWith(AppBuildInfo value, $Res Function(AppBuildInfo) _then) = _$AppBuildInfoCopyWithImpl;
@useResult
$Res call({
 String version, String buildNumber, String packageName
});




}
/// @nodoc
class _$AppBuildInfoCopyWithImpl<$Res>
    implements $AppBuildInfoCopyWith<$Res> {
  _$AppBuildInfoCopyWithImpl(this._self, this._then);

  final AppBuildInfo _self;
  final $Res Function(AppBuildInfo) _then;

/// Create a copy of AppBuildInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? buildNumber = null,Object? packageName = null,}) {
  return _then(AppBuildInfo(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppBuildInfo].
extension AppBuildInfoPatterns on AppBuildInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBuildInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBuildInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBuildInfo value)  $default,){
final _that = this;
switch (_that) {
case _AppBuildInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBuildInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AppBuildInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String packageName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBuildInfo() when $default != null:
return $default(_that.version,_that.buildNumber,_that.packageName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String packageName)  $default,) {final _that = this;
switch (_that) {
case _AppBuildInfo():
return $default(_that.version,_that.buildNumber,_that.packageName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String buildNumber,  String packageName)?  $default,) {final _that = this;
switch (_that) {
case _AppBuildInfo() when $default != null:
return $default(_that.version,_that.buildNumber,_that.packageName);case _:
  return null;

}
}

}

/// @nodoc


class _AppBuildInfo implements AppBuildInfo {
  const _AppBuildInfo({required this.version, required this.buildNumber, required this.packageName});
  

@override final  String version;
@override final  String buildNumber;
@override final  String packageName;

/// Create a copy of AppBuildInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBuildInfoCopyWith<_AppBuildInfo> get copyWith => __$AppBuildInfoCopyWithImpl<_AppBuildInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBuildInfo&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.packageName, packageName) || other.packageName == packageName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,version,buildNumber,packageName);
}

@override
String toString() {
    return 'AppBuildInfo(version: $version, buildNumber: $buildNumber, packageName: $packageName)';
}


}

/// @nodoc
abstract mixin class _$AppBuildInfoCopyWith<$Res> implements $AppBuildInfoCopyWith<$Res> {
  factory _$AppBuildInfoCopyWith(_AppBuildInfo value, $Res Function(_AppBuildInfo) _then) = __$AppBuildInfoCopyWithImpl;
@override @useResult
$Res call({
 String version, String buildNumber, String packageName
});




}
/// @nodoc
class __$AppBuildInfoCopyWithImpl<$Res>
    implements _$AppBuildInfoCopyWith<$Res> {
  __$AppBuildInfoCopyWithImpl(this._self, this._then);

  final _AppBuildInfo _self;
  final $Res Function(_AppBuildInfo) _then;

/// Create a copy of AppBuildInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? buildNumber = null,Object? packageName = null,}) {
  return _then(_AppBuildInfo(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
