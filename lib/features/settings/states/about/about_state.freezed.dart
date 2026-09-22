// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'about_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AboutState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AboutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AboutState()';
}


}

/// @nodoc
class $AboutStateCopyWith<$Res>  {
$AboutStateCopyWith(AboutState _, $Res Function(AboutState) __);
}


/// Adds pattern-matching-related methods to [AboutState].
extension AboutStatePatterns on AboutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AboutLoading value)?  loading,TResult Function( AboutLoaded value)?  loaded,TResult Function( AboutFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AboutLoading() when loading != null:
return loading(_that);case AboutLoaded() when loaded != null:
return loaded(_that);case AboutFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AboutLoading value)  loading,required TResult Function( AboutLoaded value)  loaded,required TResult Function( AboutFailed value)  failed,}){
final _that = this;
switch (_that) {
case AboutLoading():
return loading(_that);case AboutLoaded():
return loaded(_that);case AboutFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AboutLoading value)?  loading,TResult? Function( AboutLoaded value)?  loaded,TResult? Function( AboutFailed value)?  failed,}){
final _that = this;
switch (_that) {
case AboutLoading() when loading != null:
return loading(_that);case AboutLoaded() when loaded != null:
return loaded(_that);case AboutFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( AppBuildInfo buildInfo,  AppEnvironment environment,  bool isDeviceAuthenticationAvailable)?  loaded,TResult Function( AppInfoFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AboutLoading() when loading != null:
return loading();case AboutLoaded() when loaded != null:
return loaded(_that.buildInfo,_that.environment,_that.isDeviceAuthenticationAvailable);case AboutFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( AppBuildInfo buildInfo,  AppEnvironment environment,  bool isDeviceAuthenticationAvailable)  loaded,required TResult Function( AppInfoFailure failure)  failed,}) {final _that = this;
switch (_that) {
case AboutLoading():
return loading();case AboutLoaded():
return loaded(_that.buildInfo,_that.environment,_that.isDeviceAuthenticationAvailable);case AboutFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( AppBuildInfo buildInfo,  AppEnvironment environment,  bool isDeviceAuthenticationAvailable)?  loaded,TResult? Function( AppInfoFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case AboutLoading() when loading != null:
return loading();case AboutLoaded() when loaded != null:
return loaded(_that.buildInfo,_that.environment,_that.isDeviceAuthenticationAvailable);case AboutFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class AboutLoading implements AboutState {
  const AboutLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AboutLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AboutState.loading()';
}


}




/// @nodoc


class AboutLoaded implements AboutState {
  const AboutLoaded({required this.buildInfo, required this.environment, required this.isDeviceAuthenticationAvailable});
  

 final  AppBuildInfo buildInfo;
 final  AppEnvironment environment;
 final  bool isDeviceAuthenticationAvailable;

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AboutLoadedCopyWith<AboutLoaded> get copyWith => _$AboutLoadedCopyWithImpl<AboutLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AboutLoaded&&(identical(other.buildInfo, buildInfo) || other.buildInfo == buildInfo)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.isDeviceAuthenticationAvailable, isDeviceAuthenticationAvailable) || other.isDeviceAuthenticationAvailable == isDeviceAuthenticationAvailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,buildInfo,environment,isDeviceAuthenticationAvailable);
}

@override
String toString() {
    return 'AboutState.loaded(buildInfo: $buildInfo, environment: $environment, isDeviceAuthenticationAvailable: $isDeviceAuthenticationAvailable)';
}


}

/// @nodoc
abstract mixin class $AboutLoadedCopyWith<$Res> implements $AboutStateCopyWith<$Res> {
  factory $AboutLoadedCopyWith(AboutLoaded value, $Res Function(AboutLoaded) _then) = _$AboutLoadedCopyWithImpl;
@useResult
$Res call({
 AppBuildInfo buildInfo, AppEnvironment environment, bool isDeviceAuthenticationAvailable
});


$AppBuildInfoCopyWith<$Res> get buildInfo;

}
/// @nodoc
class _$AboutLoadedCopyWithImpl<$Res>
    implements $AboutLoadedCopyWith<$Res> {
  _$AboutLoadedCopyWithImpl(this._self, this._then);

  final AboutLoaded _self;
  final $Res Function(AboutLoaded) _then;

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? buildInfo = null,Object? environment = null,Object? isDeviceAuthenticationAvailable = null,}) {
  return _then(AboutLoaded(
buildInfo: null == buildInfo ? _self.buildInfo : buildInfo // ignore: cast_nullable_to_non_nullable
as AppBuildInfo,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as AppEnvironment,isDeviceAuthenticationAvailable: null == isDeviceAuthenticationAvailable ? _self.isDeviceAuthenticationAvailable : isDeviceAuthenticationAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBuildInfoCopyWith<$Res> get buildInfo {
  
  return $AppBuildInfoCopyWith<$Res>(_self.buildInfo, (value) {
    return _then(_self.copyWith(buildInfo: value));
  });
}
}

/// @nodoc


class AboutFailed implements AboutState {
  const AboutFailed({required this.failure});
  

 final  AppInfoFailure failure;

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AboutFailedCopyWith<AboutFailed> get copyWith => _$AboutFailedCopyWithImpl<AboutFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AboutFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'AboutState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $AboutFailedCopyWith<$Res> implements $AboutStateCopyWith<$Res> {
  factory $AboutFailedCopyWith(AboutFailed value, $Res Function(AboutFailed) _then) = _$AboutFailedCopyWithImpl;
@useResult
$Res call({
 AppInfoFailure failure
});


$AppInfoFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$AboutFailedCopyWithImpl<$Res>
    implements $AboutFailedCopyWith<$Res> {
  _$AboutFailedCopyWithImpl(this._self, this._then);

  final AboutFailed _self;
  final $Res Function(AboutFailed) _then;

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(AboutFailed(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppInfoFailure,
  ));
}

/// Create a copy of AboutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppInfoFailureCopyWith<$Res> get failure {
  
  return $AppInfoFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
