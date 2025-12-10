enum TransactionType {
  // Person-related transactions
  saleOnCredit, // Customer owes you. (Increases receivable)
  paymentReceived, // Customer pays off debt. (Decreases receivable, increases cash)
  purchaseOnCredit, // You owe supplier. (Increases payable)
  paymentMade, // You pay off debt to supplier. (Decreases payable, decreases cash)
  
  // Cash-only transactions
  cashSale, // Customer pays immediately. (Income)
  cashIncome, // Other income not from sales.
  cashExpense, // General expense.
}

class Transaction {
  final String id;
  final TransactionType type;
  final String? personId;
  final double amount;
  final DateTime date;
  final String? category;
  final String? note;
  final DateTime? dueDate;

  Transaction({
    required this.id,
    required this.type,
    this.personId,
    required this.amount,
    required this.date,
    this.category,
    this.note,
    this.dueDate,
  });
}
