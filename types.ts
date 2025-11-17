export enum PersonRole {
  CUSTOMER = 'customer',
  SUPPLIER = 'supplier',
}

export enum TransactionType {
  // Person-related transactions
  SALE_ON_CREDIT = 'sale_on_credit', // Customer owes you. (Increases receivable)
  PAYMENT_RECEIVED = 'payment_received', // Customer pays off debt. (Decreases receivable, increases cash)
  PURCHASE_ON_CREDIT = 'purchase_on_credit', // You owe supplier. (Increases payable)
  PAYMENT_MADE = 'payment_made', // You pay off debt to supplier. (Decreases payable, decreases cash)
  
  // Cash-only transactions
  CASH_SALE = 'cash_sale', // Customer pays immediately. (Income)
  CASH_INCOME = 'cash_income', // Other income not from sales.
  CASH_EXPENSE = 'cash_expense', // General expense.
}

export interface Person {
  id: string;
  role: PersonRole;
  name: string;
  phone: string | null;
  createdAt: string; // ISO Date String
}

export interface Transaction {
  id: string;
  type: TransactionType;
  personId?: string | null;
  amount: number;
  date: string; // ISO Date String
  category?: string | null;
  note?: string | null;
  dueDate?: string | null;
}

export type Screen = 'home' | 'ledger' | 'cashbook' | 'reports' | 'settings' | 'about';
export type LedgerFlowType = 'debt' | 'payment';