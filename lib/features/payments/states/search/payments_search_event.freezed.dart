// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_search_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsSearchEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsSearchEvent()';
}


}

/// @nodoc
class $PaymentsSearchEventCopyWith<$Res>  {
$PaymentsSearchEventCopyWith(PaymentsSearchEvent _, $Res Function(PaymentsSearchEvent) __);
}


/// Adds pattern-matching-related methods to [PaymentsSearchEvent].
extension PaymentsSearchEventPatterns on PaymentsSearchEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentsSearchQueryChanged value)?  queryChanged,TResult Function( PaymentsSearchStatusFilterChanged value)?  statusFilterChanged,TResult Function( PaymentsSearchCleared value)?  cleared,TResult Function( PaymentsSearchRefreshRequested value)?  refreshRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged() when queryChanged != null:
return queryChanged(_that);case PaymentsSearchStatusFilterChanged() when statusFilterChanged != null:
return statusFilterChanged(_that);case PaymentsSearchCleared() when cleared != null:
return cleared(_that);case PaymentsSearchRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentsSearchQueryChanged value)  queryChanged,required TResult Function( PaymentsSearchStatusFilterChanged value)  statusFilterChanged,required TResult Function( PaymentsSearchCleared value)  cleared,required TResult Function( PaymentsSearchRefreshRequested value)  refreshRequested,}){
final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged():
return queryChanged(_that);case PaymentsSearchStatusFilterChanged():
return statusFilterChanged(_that);case PaymentsSearchCleared():
return cleared(_that);case PaymentsSearchRefreshRequested():
return refreshRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentsSearchQueryChanged value)?  queryChanged,TResult? Function( PaymentsSearchStatusFilterChanged value)?  statusFilterChanged,TResult? Function( PaymentsSearchCleared value)?  cleared,TResult? Function( PaymentsSearchRefreshRequested value)?  refreshRequested,}){
final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged() when queryChanged != null:
return queryChanged(_that);case PaymentsSearchStatusFilterChanged() when statusFilterChanged != null:
return statusFilterChanged(_that);case PaymentsSearchCleared() when cleared != null:
return cleared(_that);case PaymentsSearchRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String query)?  queryChanged,TResult Function( Set<PaymentStatus> statuses)?  statusFilterChanged,TResult Function()?  cleared,TResult Function()?  refreshRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case PaymentsSearchStatusFilterChanged() when statusFilterChanged != null:
return statusFilterChanged(_that.statuses);case PaymentsSearchCleared() when cleared != null:
return cleared();case PaymentsSearchRefreshRequested() when refreshRequested != null:
return refreshRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String query)  queryChanged,required TResult Function( Set<PaymentStatus> statuses)  statusFilterChanged,required TResult Function()  cleared,required TResult Function()  refreshRequested,}) {final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged():
return queryChanged(_that.query);case PaymentsSearchStatusFilterChanged():
return statusFilterChanged(_that.statuses);case PaymentsSearchCleared():
return cleared();case PaymentsSearchRefreshRequested():
return refreshRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String query)?  queryChanged,TResult? Function( Set<PaymentStatus> statuses)?  statusFilterChanged,TResult? Function()?  cleared,TResult? Function()?  refreshRequested,}) {final _that = this;
switch (_that) {
case PaymentsSearchQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case PaymentsSearchStatusFilterChanged() when statusFilterChanged != null:
return statusFilterChanged(_that.statuses);case PaymentsSearchCleared() when cleared != null:
return cleared();case PaymentsSearchRefreshRequested() when refreshRequested != null:
return refreshRequested();case _:
  return null;

}
}

}

/// @nodoc


class PaymentsSearchQueryChanged implements PaymentsSearchEvent {
  const PaymentsSearchQueryChanged(this.query);
  

 final  String query;

/// Create a copy of PaymentsSearchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchQueryChangedCopyWith<PaymentsSearchQueryChanged> get copyWith => _$PaymentsSearchQueryChangedCopyWithImpl<PaymentsSearchQueryChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchQueryChanged&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query);
}

@override
String toString() {
    return 'PaymentsSearchEvent.queryChanged(query: $query)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchQueryChangedCopyWith<$Res> implements $PaymentsSearchEventCopyWith<$Res> {
  factory $PaymentsSearchQueryChangedCopyWith(PaymentsSearchQueryChanged value, $Res Function(PaymentsSearchQueryChanged) _then) = _$PaymentsSearchQueryChangedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$PaymentsSearchQueryChangedCopyWithImpl<$Res>
    implements $PaymentsSearchQueryChangedCopyWith<$Res> {
  _$PaymentsSearchQueryChangedCopyWithImpl(this._self, this._then);

  final PaymentsSearchQueryChanged _self;
  final $Res Function(PaymentsSearchQueryChanged) _then;

/// Create a copy of PaymentsSearchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(PaymentsSearchQueryChanged(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PaymentsSearchStatusFilterChanged implements PaymentsSearchEvent {
  const PaymentsSearchStatusFilterChanged( Set<PaymentStatus> statuses): _statuses = statuses;
  

 final  Set<PaymentStatus> _statuses;
 Set<PaymentStatus> get statuses {
  if (_statuses is EqualUnmodifiableSetView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_statuses);
}


/// Create a copy of PaymentsSearchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsSearchStatusFilterChangedCopyWith<PaymentsSearchStatusFilterChanged> get copyWith => _$PaymentsSearchStatusFilterChangedCopyWithImpl<PaymentsSearchStatusFilterChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchStatusFilterChanged&&const DeepCollectionEquality().equals(other.statuses, _statuses));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_statuses));
}

@override
String toString() {
    return 'PaymentsSearchEvent.statusFilterChanged(statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class $PaymentsSearchStatusFilterChangedCopyWith<$Res> implements $PaymentsSearchEventCopyWith<$Res> {
  factory $PaymentsSearchStatusFilterChangedCopyWith(PaymentsSearchStatusFilterChanged value, $Res Function(PaymentsSearchStatusFilterChanged) _then) = _$PaymentsSearchStatusFilterChangedCopyWithImpl;
@useResult
$Res call({
 Set<PaymentStatus> statuses
});




}
/// @nodoc
class _$PaymentsSearchStatusFilterChangedCopyWithImpl<$Res>
    implements $PaymentsSearchStatusFilterChangedCopyWith<$Res> {
  _$PaymentsSearchStatusFilterChangedCopyWithImpl(this._self, this._then);

  final PaymentsSearchStatusFilterChanged _self;
  final $Res Function(PaymentsSearchStatusFilterChanged) _then;

/// Create a copy of PaymentsSearchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statuses = null,}) {
  return _then(PaymentsSearchStatusFilterChanged(
null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as Set<PaymentStatus>,
  ));
}


}

/// @nodoc


class PaymentsSearchCleared implements PaymentsSearchEvent {
  const PaymentsSearchCleared();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsSearchEvent.cleared()';
}


}




/// @nodoc


class PaymentsSearchRefreshRequested implements PaymentsSearchEvent {
  const PaymentsSearchRefreshRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsSearchRefreshRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentsSearchEvent.refreshRequested()';
}


}




// dart format on
