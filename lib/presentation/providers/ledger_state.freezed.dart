// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LedgerState {

 List<Person> get persons; List<Transaction> get transactions; Map<String, double> get balances;
/// Create a copy of LedgerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerStateCopyWith<LedgerState> get copyWith => _$LedgerStateCopyWithImpl<LedgerState>(this as LedgerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerState&&const DeepCollectionEquality().equals(other.persons, persons)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.balances, balances));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(persons),const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(balances));

@override
String toString() {
  return 'LedgerState(persons: $persons, transactions: $transactions, balances: $balances)';
}


}

/// @nodoc
abstract mixin class $LedgerStateCopyWith<$Res>  {
  factory $LedgerStateCopyWith(LedgerState value, $Res Function(LedgerState) _then) = _$LedgerStateCopyWithImpl;
@useResult
$Res call({
 List<Person> persons, List<Transaction> transactions, Map<String, double> balances
});




}
/// @nodoc
class _$LedgerStateCopyWithImpl<$Res>
    implements $LedgerStateCopyWith<$Res> {
  _$LedgerStateCopyWithImpl(this._self, this._then);

  final LedgerState _self;
  final $Res Function(LedgerState) _then;

/// Create a copy of LedgerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? persons = null,Object? transactions = null,Object? balances = null,}) {
  return _then(_self.copyWith(
persons: null == persons ? _self.persons : persons // ignore: cast_nullable_to_non_nullable
as List<Person>,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,balances: null == balances ? _self.balances : balances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// @nodoc


class _LedgerState implements LedgerState {
  const _LedgerState({final  List<Person> persons = const [], final  List<Transaction> transactions = const [], final  Map<String, double> balances = const {}}): _persons = persons,_transactions = transactions,_balances = balances;
  

 final  List<Person> _persons;
@override@JsonKey() List<Person> get persons {
  if (_persons is EqualUnmodifiableListView) return _persons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_persons);
}

 final  List<Transaction> _transactions;
@override@JsonKey() List<Transaction> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

 final  Map<String, double> _balances;
@override@JsonKey() Map<String, double> get balances {
  if (_balances is EqualUnmodifiableMapView) return _balances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_balances);
}


/// Create a copy of LedgerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerStateCopyWith<_LedgerState> get copyWith => __$LedgerStateCopyWithImpl<_LedgerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerState&&const DeepCollectionEquality().equals(other._persons, _persons)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._balances, _balances));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_persons),const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_balances));

@override
String toString() {
  return 'LedgerState(persons: $persons, transactions: $transactions, balances: $balances)';
}


}

/// @nodoc
abstract mixin class _$LedgerStateCopyWith<$Res> implements $LedgerStateCopyWith<$Res> {
  factory _$LedgerStateCopyWith(_LedgerState value, $Res Function(_LedgerState) _then) = __$LedgerStateCopyWithImpl;
@override @useResult
$Res call({
 List<Person> persons, List<Transaction> transactions, Map<String, double> balances
});




}
/// @nodoc
class __$LedgerStateCopyWithImpl<$Res>
    implements _$LedgerStateCopyWith<$Res> {
  __$LedgerStateCopyWithImpl(this._self, this._then);

  final _LedgerState _self;
  final $Res Function(_LedgerState) _then;

/// Create a copy of LedgerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? persons = null,Object? transactions = null,Object? balances = null,}) {
  return _then(_LedgerState(
persons: null == persons ? _self._persons : persons // ignore: cast_nullable_to_non_nullable
as List<Person>,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,balances: null == balances ? _self._balances : balances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
