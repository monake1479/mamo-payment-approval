// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsSearchState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsSearchState()';
}


}

/// @nodoc
class $PaymentsSearchStateCopyWith<$Res>  {
$PaymentsSearchStateCopyWith(PaymentsSearchState _, $Res Function(PaymentsSearchState) __);
}


/// Adds pattern-matching-related methods to [PaymentsSearchState].
extension PaymentsSearchStatePatterns on PaymentsSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentsSearchIdle value)?  idle,TResult Function( PaymentsSearchLoading value)?  loading,TResult Function( PaymentsSearchResults value)?  results,TResult Function( PaymentsSearchEmpty value)?  empty,TResult Function( PaymentsSearchError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentsSearchIdle() when idle != null:
return idle(_that);case PaymentsSearchLoading() when loading != null:
return loading(_that);case PaymentsSearchResults() when results != null:
return results(_that);case PaymentsSearchEmpty() when empty != null:
return empty(_that);case PaymentsSearchError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentsSearchIdle value)  idle,required TResult Function( PaymentsSearchLoading value)  loading,required TResult Function( PaymentsSearchResults value)  results,required TResult Function( PaymentsSearchEmpty value)  empty,required TResult Function( PaymentsSearchError value)  error,}){
final _that = this;
switch (_that) {
case PaymentsSearchIdle():
return idle(_that);case PaymentsSearchLoading():
return loading(_that);case PaymentsSearchResults():
return results(_that);case PaymentsSearchEmpty():
return empty(_that);case PaymentsSearchError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentsSearchIdle value)?  idle,TResult? Function( PaymentsSearchLoading value)?  loading,TResult? Function( PaymentsSearchResults value)?  results,TResult? Function( PaymentsSearchEmpty value)?  empty,TResult? Function( PaymentsSearchError value)?  error,}){
final _that = this;
switch (_that) {
case PaymentsSearchIdle() when idle != null:
return idle(_that);case PaymentsSearchLoading() when loading != null:
return loading(_that);case PaymentsSearchResults() when results != null:
return results(_that);case PaymentsSearchEmpty() when empty != null:
return empty(_that);case PaymentsSearchError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( PaymentsSearchCriteria criteria)?  loading,TResult Function( PaymentsSearchCriteria criteria,  List<Payment> payments)?  results,TResult Function( PaymentsSearchCriteria criteria)?  empty,TResult Function( PaymentsSearchCriteria criteria,  PaymentsFailure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentsSearchIdle() when idle != null:
return idle();case PaymentsSearchLoading() when loading != null:
return loading(_that.criteria);case PaymentsSearchResults() when results != null:
return results(_that.criteria,_that.payments);case PaymentsSearchEmpty() when empty != null:
return empty(_that.criteria);case PaymentsSearchError() when error != null:
return error(_that.criteria,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( PaymentsSearchCriteria criteria)  loading,required TResult Function( PaymentsSearchCriteria criteria,  List<Payment> payments)  results,required TResult Function( PaymentsSearchCriteria criteria)  empty,required TResult Function( PaymentsSearchCriteria criteria,  PaymentsFailure failure)  error,}) {final _that = this;
switch (_that) {
case PaymentsSearchIdle():
return idle();case PaymentsSearchLoading():
return loading(_that.criteria);case PaymentsSearchResults():
return results(_that.criteria,_that.payments);case PaymentsSearchEmpty():
return empty(_that.criteria);case PaymentsSearchError():
return error(_that.criteria,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( PaymentsSearchCriteria criteria)?  loading,TResult? Function( PaymentsSearchCriteria criteria,  List<Payment> payments)?  results,TResult? Function( PaymentsSearchCriteria criteria)?  empty,TResult? Function( PaymentsSearchCriteria criteria,  PaymentsFailure failure)?  error,}) {final _that = this;
switch (_that) {
case PaymentsSearchIdle() when idle != null:
return idle();case PaymentsSearchLoading() when loading != null:
return loading(_that.criteria);case PaymentsSearchResults() when results != null:
return results(_that.criteria,_that.payments);case PaymentsSearchEmpty() when empty != null:
return empty(_that.criteria);case PaymentsSearchError() when error != null:
return error(_that.criteria,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class PaymentsSearchIdle extends PaymentsSearchState {
  const PaymentsSearchIdle(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsSearchState.idle()';
}


}




/// @nodoc


class PaymentsSearchLoading extends PaymentsSearchState {
  const PaymentsSearchLoading({required this.criteria}): super._();
  

 final  PaymentsSearchCriteria criteria;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchLoadingCopyWith<PaymentsSearchLoading> get copyWith => _$PaymentsSearchLoadingCopyWithImpl<PaymentsSearchLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchLoading&&(identical(other.criteria, criteria) || other.criteria == criteria));
}


@override
int get hashCode {
    return Object.hash(runtimeType,criteria);
}

@override
String toString() {
    return 'PaymentsSearchState.loading(criteria: $criteria)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchLoadingCopyWith<$Res> implements $PaymentsSearchStateCopyWith<$Res> {
  factory $PaymentsSearchLoadingCopyWith(PaymentsSearchLoading value, $Res Function(PaymentsSearchLoading) _then) = _$PaymentsSearchLoadingCopyWithImpl;
@useResult
$Res call({
 PaymentsSearchCriteria criteria
});


$PaymentsSearchCriteriaCopyWith<$Res> get criteria;

}
/// @nodoc
class _$PaymentsSearchLoadingCopyWithImpl<$Res>
    implements $PaymentsSearchLoadingCopyWith<$Res> {
  _$PaymentsSearchLoadingCopyWithImpl(this._self, this._then);

  final PaymentsSearchLoading _self;
  final $Res Function(PaymentsSearchLoading) _then;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? criteria = null,}) {
  return _then(PaymentsSearchLoading(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as PaymentsSearchCriteria,
  ));
}

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSearchCriteriaCopyWith<$Res> get criteria {
  
  return $PaymentsSearchCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}
}

/// @nodoc


class PaymentsSearchResults extends PaymentsSearchState {
  const PaymentsSearchResults({required this.criteria, required  List<Payment> payments}): _payments = payments,super._();
  

 final  PaymentsSearchCriteria criteria;
 final  List<Payment> _payments;
 List<Payment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}


/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchResultsCopyWith<PaymentsSearchResults> get copyWith => _$PaymentsSearchResultsCopyWithImpl<PaymentsSearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchResults&&(identical(other.criteria, criteria) || other.criteria == criteria)&&const DeepCollectionEquality().equals(other.payments, _payments));
}


@override
int get hashCode {
    return Object.hash(runtimeType,criteria,const DeepCollectionEquality().hash(_payments));
}

@override
String toString() {
    return 'PaymentsSearchState.results(criteria: $criteria, payments: $payments)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchResultsCopyWith<$Res> implements $PaymentsSearchStateCopyWith<$Res> {
  factory $PaymentsSearchResultsCopyWith(PaymentsSearchResults value, $Res Function(PaymentsSearchResults) _then) = _$PaymentsSearchResultsCopyWithImpl;
@useResult
$Res call({
 PaymentsSearchCriteria criteria, List<Payment> payments
});


$PaymentsSearchCriteriaCopyWith<$Res> get criteria;

}
/// @nodoc
class _$PaymentsSearchResultsCopyWithImpl<$Res>
    implements $PaymentsSearchResultsCopyWith<$Res> {
  _$PaymentsSearchResultsCopyWithImpl(this._self, this._then);

  final PaymentsSearchResults _self;
  final $Res Function(PaymentsSearchResults) _then;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? criteria = null,Object? payments = null,}) {
  return _then(PaymentsSearchResults(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as PaymentsSearchCriteria,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,
  ));
}

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSearchCriteriaCopyWith<$Res> get criteria {
  
  return $PaymentsSearchCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}
}

/// @nodoc


class PaymentsSearchEmpty extends PaymentsSearchState {
  const PaymentsSearchEmpty({required this.criteria}): super._();
  

 final  PaymentsSearchCriteria criteria;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchEmptyCopyWith<PaymentsSearchEmpty> get copyWith => _$PaymentsSearchEmptyCopyWithImpl<PaymentsSearchEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchEmpty&&(identical(other.criteria, criteria) || other.criteria == criteria));
}


@override
int get hashCode {
    return Object.hash(runtimeType,criteria);
}

@override
String toString() {
    return 'PaymentsSearchState.empty(criteria: $criteria)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchEmptyCopyWith<$Res> implements $PaymentsSearchStateCopyWith<$Res> {
  factory $PaymentsSearchEmptyCopyWith(PaymentsSearchEmpty value, $Res Function(PaymentsSearchEmpty) _then) = _$PaymentsSearchEmptyCopyWithImpl;
@useResult
$Res call({
 PaymentsSearchCriteria criteria
});


$PaymentsSearchCriteriaCopyWith<$Res> get criteria;

}
/// @nodoc
class _$PaymentsSearchEmptyCopyWithImpl<$Res>
    implements $PaymentsSearchEmptyCopyWith<$Res> {
  _$PaymentsSearchEmptyCopyWithImpl(this._self, this._then);

  final PaymentsSearchEmpty _self;
  final $Res Function(PaymentsSearchEmpty) _then;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? criteria = null,}) {
  return _then(PaymentsSearchEmpty(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as PaymentsSearchCriteria,
  ));
}

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSearchCriteriaCopyWith<$Res> get criteria {
  
  return $PaymentsSearchCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}
}

/// @nodoc


class PaymentsSearchError extends PaymentsSearchState {
  const PaymentsSearchError({required this.criteria, required this.failure}): super._();
  

 final  PaymentsSearchCriteria criteria;
 final  PaymentsFailure failure;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchErrorCopyWith<PaymentsSearchError> get copyWith => _$PaymentsSearchErrorCopyWithImpl<PaymentsSearchError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchError&&(identical(other.criteria, criteria) || other.criteria == criteria)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,criteria,failure);
}

@override
String toString() {
    return 'PaymentsSearchState.error(criteria: $criteria, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchErrorCopyWith<$Res> implements $PaymentsSearchStateCopyWith<$Res> {
  factory $PaymentsSearchErrorCopyWith(PaymentsSearchError value, $Res Function(PaymentsSearchError) _then) = _$PaymentsSearchErrorCopyWithImpl;
@useResult
$Res call({
 PaymentsSearchCriteria criteria, PaymentsFailure failure
});


$PaymentsSearchCriteriaCopyWith<$Res> get criteria;$PaymentsFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$PaymentsSearchErrorCopyWithImpl<$Res>
    implements $PaymentsSearchErrorCopyWith<$Res> {
  _$PaymentsSearchErrorCopyWithImpl(this._self, this._then);

  final PaymentsSearchError _self;
  final $Res Function(PaymentsSearchError) _then;

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? criteria = null,Object? failure = null,}) {
  return _then(PaymentsSearchError(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as PaymentsSearchCriteria,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PaymentsFailure,
  ));
}

/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSearchCriteriaCopyWith<$Res> get criteria {
  
  return $PaymentsSearchCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}/// Create a copy of PaymentsSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsFailureCopyWith<$Res> get failure {
  
  return $PaymentsFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
