import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

part 'ledger_state.freezed.dart';

@freezed
abstract class LedgerState with _$LedgerState {
  const factory LedgerState({
    @Default([]) List<Person> persons,
    @Default([]) List<Transaction> transactions,
    @Default({}) Map<String, double> balances,
  }) = _LedgerState;
}
