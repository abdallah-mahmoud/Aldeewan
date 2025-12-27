import 'package:realm/realm.dart';

part 'financial_account_model.realm.dart';

/// Represents a financial account item stored in the Realm database.
///
/// This class defines the schema for a financial account, including its name,
/// provider, type, balance, currency, and fields for API integration.
@RealmModel()
class _FinancialAccountModel {
  /// The unique identifier for the financial account.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late int id;

  /// The user-friendly name of the account (e.g., "My Savings Account", "Mbok Account").
  late String name;
  /// The identifier of the provider for this account (e.g., "MBOK", "SYBER", "CASH").
  late String providerId;
  /// The type of the financial account (e.g., "BANK", "WALLET", "CASH").
  late String accountType;
  /// The current balance of the account.
  late double balance;
  /// The currency in which the account balance is denominated (e.g., "SDG", "USD").
  late String currency;

  // API Integration Fields
  /// The ID of the account as recognized by an external bank or payment system.
  String? externalAccountId;
  /// The timestamp of the last successful synchronization with an external provider.
  DateTime? lastSyncTime;
  /// The current status of the account integration (e.g., "ACTIVE", "ERROR", "NEEDS_REAUTH").
  String? status;
  /// The hex code representation of a color associated with this account for UI purposes.
  String? colorHex;
}
