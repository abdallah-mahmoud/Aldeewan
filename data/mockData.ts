import type { Person, LedgerEntry, CashEntry } from '../types';
import { PersonRole, LedgerEntryType, CashEntryType } from '../types';

export const mockPersons: Person[] = [
  { id: '1', name: 'بقالة أبو أحمد', role: PersonRole.SUPPLIER, phone: '0501234567', createdAt: new Date().toISOString() },
  { id: '2', name: 'خالد عبدالله', role: PersonRole.CUSTOMER, phone: '0559876543', createdAt: new Date().toISOString() },
  { id: '3', name: 'فاطمة علي', role: PersonRole.CUSTOMER, phone: '0531122334', createdAt: new Date().toISOString() },
  { id: '4', name: 'شركة النور للتوزيع', role: PersonRole.SUPPLIER, phone: '0114567890', createdAt: new Date().toISOString() },
];

export const mockLedgerEntries: LedgerEntry[] = [
  // Transactions for بقالة أبو أحمد (Supplier)
  { id: 'l1', personId: '1', type: LedgerEntryType.DEBT, amount: 500, date: '2023-10-01T10:00:00Z', note: 'فاتورة مواد غذائية' },
  { id: 'l2', personId: '1', type: LedgerEntryType.PAYMENT, amount: 300, date: '2023-10-05T15:00:00Z' },
  { id: 'l3', personId: '1', type: LedgerEntryType.DEBT, amount: 250, date: '2023-10-10T11:00:00Z', note: 'فاتورة منظفات' },

  // Transactions for خالد عبدالله (Customer)
  { id: 'l4', personId: '2', type: LedgerEntryType.DEBT, amount: 150, date: '2023-10-02T09:00:00Z', dueDate: '2023-10-15T09:00:00Z' },
  { id: 'l5', personId: '2', type: LedgerEntryType.DEBT, amount: 75, date: '2023-10-08T18:00:00Z', dueDate: '2023-10-20T18:00:00Z' },
  { id: 'l6', personId: '2', type: LedgerEntryType.PAYMENT, amount: 100, date: '2023-10-12T12:00:00Z' },

  // Transactions for فاطمة علي (Customer)
  { id: 'l7', personId: '3', type: LedgerEntryType.DEBT, amount: 200, date: '2023-09-25T14:00:00Z' },
  { id: 'l8', personId: '3', type: LedgerEntryType.PAYMENT, amount: 200, date: '2023-10-01T16:00:00Z' },
  
  // Transactions for شركة النور للتوزيع (Supplier)
  { id: 'l9', personId: '4', type: LedgerEntryType.DEBT, amount: 1200, date: '2023-10-03T13:00:00Z', note: 'بضاعة جديدة' },
];

export const mockCashEntries: CashEntry[] = [
  { id: 'c1', type: CashEntryType.INCOME, category: 'مبيعات نقدية', amount: 350, date: '2023-10-15T19:00:00Z' },
  { id: 'c2', type: CashEntryType.EXPENSE, category: 'فاتورة كهرباء', amount: 180, date: '2023-10-15T10:00:00Z' },
  { id: 'c3', type: CashEntryType.INCOME, category: 'مبيعات نقدية', amount: 420, date: '2023-10-16T19:00:00Z' },
  { id: 'c4', type: CashEntryType.EXPENSE, category: 'إيجار المحل', amount: 1500, date: '2023-10-01T09:00:00Z' },
  { id: 'c5', type: CashEntryType.EXPENSE, category: 'مستلزمات مكتبية', amount: 75, date: '2023-10-10T11:00:00Z' },
];