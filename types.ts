export enum PersonRole {
  CUSTOMER = 'customer',
  SUPPLIER = 'supplier',
}

export enum LedgerEntryType {
  DEBT = 'debt',
  PAYMENT = 'payment',
  ADJUSTMENT = 'adjustment',
}

export enum CashEntryType {
  INCOME = 'income',
  EXPENSE = 'expense',
}

export interface Person {
  id: string;
  role: PersonRole;
  name: string;
  phone: string | null;
  createdAt: string; // ISO Date String
}

export interface LedgerEntry {
  id: string;
  personId: string;
  type: LedgerEntryType;
  amount: number;
  date: string; // ISO Date String
  dueDate?: string | null;
  note?: string | null;
}

export interface CashEntry {
  id: string;
  type: CashEntryType;
  category: string;
  amount: number;
  date: string; // ISO Date String
  note?: string | null;
}

export type Screen = 'home' | 'ledger' | 'cashbook' | 'reports' | 'settings';