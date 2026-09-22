// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_search_criteria.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsSearchCriteria {

 String get query; Set<PaymentStatus> get statuses; PaymentsDateRange? get dateRange; PaymentsSort get sort;
/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchCriteriaCopyWith<PaymentsSearchCriteria> get copyWith => _$PaymentsSearchCriteriaCopyWithImpl<PaymentsSearchCriteria>(this as PaymentsSearchCriteria, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsSearchCriteria;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchCriteria&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.statuses, _this.statuses)&&(identical(other.dateRange, _this.dateRange) || other.dateRange == _this.dateRange)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as PaymentsSearchCriteria;
  return Object.hash(runtimeType,_this.query,const DeepCollectionEquality().hash(_this.statuses),_this.dateRange,_this.sort);
}

@override
String toString() {
  final _this = this as PaymentsSearchCriteria;
  return 'PaymentsSearchCriteria(query: ${_this.query}, statuses: ${_this.statuses}, dateRange: ${_this.dateRange}, sort: ${_this.sort})';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchCriteriaCopyWith<$Res>  {
  factory $PaymentsSearchCriteriaCopyWith(PaymentsSearchCriteria value, $Res Function(PaymentsSearchCriteria) _then) = _$PaymentsSearchCriteriaCopyWithImpl;
@useResult
$Res call({
 String query, Set<PaymentStatus> statuses, PaymentsDateRange? dateRange, PaymentsSort sort
});


$PaymentsDateRangeCopyWith<$Res>? get dateRange;$PaymentsSortCopyWith<$Res> get sort;

}
/// @nodoc
class _$PaymentsSearchCriteriaCopyWithImpl<$Res>
    implements $PaymentsSearchCriteriaCopyWith<$Res> {
  _$PaymentsSearchCriteriaCopyWithImpl(this._self, this._then);

  final PaymentsSearchCriteria _self;
  final $Res Function(PaymentsSearchCriteria) _then;

/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? statuses = null,Object? dateRange = freezed,Object? sort = null,}) {
  return _then(PaymentsSearchCriteria(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as Set<PaymentStatus>,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as PaymentsDateRange?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as PaymentsSort,
  ));
}
/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsDateRangeCopyWith<$Res>? get dateRange {
    if (_self.dateRange == null) {
    return null;
  }

  return $PaymentsDateRangeCopyWith<$Res>(_self.dateRange!, (value) {
    return _then(_self.copyWith(dateRange: value));
  });
}/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSortCopyWith<$Res> get sort {
  
  return $PaymentsSortCopyWith<$Res>(_self.sort, (value) {
    return _then(_self.copyWith(sort: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentsSearchCriteria].
extension PaymentsSearchCriteriaPatterns on PaymentsSearchCriteria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsSearchCriteria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsSearchCriteria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsSearchCriteria value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsSearchCriteria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsSearchCriteria value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsSearchCriteria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  Set<PaymentStatus> statuses,  PaymentsDateRange? dateRange,  PaymentsSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsSearchCriteria() when $default != null:
return $default(_that.query,_that.statuses,_that.dateRange,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  Set<PaymentStatus> statuses,  PaymentsDateRange? dateRange,  PaymentsSort sort)  $default,) {final _that = this;
switch (_that) {
case _PaymentsSearchCriteria():
return $default(_that.query,_that.statuses,_that.dateRange,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  Set<PaymentStatus> statuses,  PaymentsDateRange? dateRange,  PaymentsSort sort)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsSearchCriteria() when $default != null:
return $default(_that.query,_that.statuses,_that.dateRange,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsSearchCriteria extends PaymentsSearchCriteria {
  const _PaymentsSearchCriteria({this.query = '',  Set<PaymentStatus> statuses = const <PaymentStatus>{}, this.dateRange, this.sort = PaymentsSort.decidedAtNewestFirst}): _statuses = statuses,super._();
  

@override@JsonKey() final  String query;
 final  Set<PaymentStatus> _statuses;
@override@JsonKey() Set<PaymentStatus> get statuses {
  if (_statuses is EqualUnmodifiableSetView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_statuses);
}

@override final  PaymentsDateRange? dateRange;
@override@JsonKey() final  PaymentsSort sort;

/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsSearchCriteriaCopyWith<_PaymentsSearchCriteria> get copyWith => __$PaymentsSearchCriteriaCopyWithImpl<_PaymentsSearchCriteria>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsSearchCriteria&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.statuses, _statuses)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_statuses),dateRange,sort);
}

@override
String toString() {
    return 'PaymentsSearchCriteria(query: $query, statuses: $statuses, dateRange: $dateRange, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$PaymentsSearchCriteriaCopyWith<$Res> implements $PaymentsSearchCriteriaCopyWith<$Res> {
  factory _$PaymentsSearchCriteriaCopyWith(_PaymentsSearchCriteria value, $Res Function(_PaymentsSearchCriteria) _then) = __$PaymentsSearchCriteriaCopyWithImpl;
@override @useResult
$Res call({
 String query, Set<PaymentStatus> statuses, PaymentsDateRange? dateRange, PaymentsSort sort
});


@override $PaymentsDateRangeCopyWith<$Res>? get dateRange;@override $PaymentsSortCopyWith<$Res> get sort;

}
/// @nodoc
class __$PaymentsSearchCriteriaCopyWithImpl<$Res>
    implements _$PaymentsSearchCriteriaCopyWith<$Res> {
  __$PaymentsSearchCriteriaCopyWithImpl(this._self, this._then);

  final _PaymentsSearchCriteria _self;
  final $Res Function(_PaymentsSearchCriteria) _then;

/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? statuses = null,Object? dateRange = freezed,Object? sort = null,}) {
  return _then(_PaymentsSearchCriteria(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as Set<PaymentStatus>,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as PaymentsDateRange?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as PaymentsSort,
  ));
}

/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsDateRangeCopyWith<$Res>? get dateRange {
    if (_self.dateRange == null) {
    return null;
  }

  return $PaymentsDateRangeCopyWith<$Res>(_self.dateRange!, (value) {
    return _then(_self.copyWith(dateRange: value));
  });
}/// Create a copy of PaymentsSearchCriteria
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentsSortCopyWith<$Res> get sort {
  
  return $PaymentsSortCopyWith<$Res>(_self.sort, (value) {
    return _then(_self.copyWith(sort: value));
  });
}
}

// dart format on
