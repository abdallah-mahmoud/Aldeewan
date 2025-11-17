import type { Person, Transaction } from '../types';
import { PersonRole, TransactionType } from '../types';

// Helper to generate dynamic dates for more realistic mock data
const getDate = (daysAgo: number = 0, monthOffset: number = 0): string => {
    const date = new Date();
    if (monthOffset) {
        date.setMonth(date.getMonth() + monthOffset);
    }
    date.setDate(date.getDate() - daysAgo);
    // Return date as YYYY-MM-DDTHH:mm:ss.sssZ
    return date.toISOString();
};


export const mockPersons: Person[] = [
  { id: '1', name: 'بقالة أبو أحمد', role: PersonRole.SUPPLIER, phone: '0501234567', createdAt: getDate(30) },
  { id: '2', name: 'خالد عبدالله', role: PersonRole.CUSTOMER, phone: '0559876543', createdAt: getDate(25) },
  { id: '3', name: 'فاطمة علي', role: PersonRole.CUSTOMER, phone: '0531122334', createdAt: getDate(20) },
  { id: '4', name: 'شركة النور للتوزيع', role: PersonRole.SUPPLIER, phone: '0114567890', createdAt: getDate(15) },
  { id: '5', name: 'مكتبة جرير', role: PersonRole.SUPPLIER, phone: '920000089', createdAt: getDate(10) }, // New supplier
  { id: '6', name: 'سارة إبراهيم', role: PersonRole.CUSTOMER, phone: null, createdAt: getDate(5) }, // New customer
];

export const mockTransactions: Transaction[] = [
  // --- Transactions THIS MONTH ---
  
  // بقالة أبو أحمد (Supplier, id: '1') -> I owe them 450
  { id: 't1', personId: '1', type: TransactionType.PURCHASE_ON_CREDIT, amount: 500, date: getDate(28), note: 'فاتورة مواد غذائية' },
  { id: 't2', personId: '1', type: TransactionType.PAYMENT_MADE, amount: 300, date: getDate(22) },
  { id: 't3', personId: '1', type: TransactionType.PURCHASE_ON_CREDIT, amount: 250, date: getDate(15), note: 'فاتورة منظفات' },

  // خالد عبدالله (Customer, id: '2') -> Owes me 125
  { id: 't4', personId: '2', type: TransactionType.SALE_ON_CREDIT, amount: 150, date: getDate(25), dueDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString() },
  { id: 't5', personId: '2', type: TransactionType.SALE_ON_CREDIT, amount: 75, date: getDate(18), dueDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000).toISOString() },
  { id: 't6', personId: '2', type: TransactionType.PAYMENT_RECEIVED, amount: 100, date: getDate(10) },

  // فاطمة علي (Customer, id: '3') -> Balance is 0
  { id: 't8', personId: '3', type: TransactionType.PAYMENT_RECEIVED, amount: 200, date: getDate(28) },
  
  // شركة النور للتوزيع (Supplier, id: '4') -> I owe them 1200
  { id: 't9', personId: '4', type: TransactionType.PURCHASE_ON_CREDIT, amount: 1200, date: getDate(20), note: 'بضاعة جديدة' },
  
  // سارة إبراهيم (Customer, id: '6') -> I owe her 50 (Credit Balance)
  { id: 't15', personId: '6', type: TransactionType.SALE_ON_CREDIT, amount: 100, date: getDate(5) },
  { id: 't16', personId: '6', type: TransactionType.PAYMENT_RECEIVED, amount: 150, date: getDate(2), note: 'دفعة مقدمة' },

  // Cashbook transactions for THIS month
  { id: 't10', type: TransactionType.CASH_SALE, category: 'مبيعات نقدية', amount: 350, date: getDate(3) },
  { id: 't11', type: TransactionType.CASH_EXPENSE, category: 'فاتورة كهرباء', amount: 180, date: getDate(2) },
  { id: 't12', type: TransactionType.CASH_SALE, category: 'مبيعات نقدية', amount: 420, date: getDate(1) },
  { id: 't13', type: TransactionType.CASH_EXPENSE, category: 'إيجار المحل', amount: 1500, date: getDate(28) },
  { id: 't14', type: TransactionType.CASH_EXPENSE, category: 'مستلزمات مكتبية', amount: 75, date: getDate(12) },

  // --- Transactions LAST MONTH (for historical context) ---
  { id: 't7', personId: '3', type: TransactionType.SALE_ON_CREDIT, amount: 200, date: getDate(5, -1) },
  { id: 't17', personId: '4', type: TransactionType.PAYMENT_MADE, amount: 1000, date: getDate(10, -1) },
  { id: 't18', personId: '1', type: TransactionType.PURCHASE_ON_CREDIT, amount: 400, date: getDate(15, -1) },
];
