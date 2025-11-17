// Added imports for Jest's global functions to satisfy TypeScript.
import { describe, it, expect } from '@jest/globals';
import { calculatePersonBalance } from '../../utils/calculations';
import { PersonRole, TransactionType } from '../../types';
import type { Person, Transaction } from '../../types';

describe('calculatePersonBalance', () => {
  const customer: Person = { id: 'c1', name: 'Customer A', role: PersonRole.CUSTOMER, phone: null, createdAt: '' };
  const supplier: Person = { id: 's1', name: 'Supplier A', role: PersonRole.SUPPLIER, phone: null, createdAt: '' };

  const transactions: Transaction[] = [
    // Customer transactions: c1 owes 150
    { id: 't1', personId: 'c1', type: TransactionType.SALE_ON_CREDIT, amount: 200, date: '' },
    { id: 't2', personId: 'c1', type: TransactionType.PAYMENT_RECEIVED, amount: 50, date: '' },
    
    // Supplier transactions: we owe s1 500
    { id: 't3', personId: 's1', type: TransactionType.PURCHASE_ON_CREDIT, amount: 800, date: '' },
    { id: 't4', personId: 's1', type: TransactionType.PAYMENT_MADE, amount: 300, date: '' },

    // Customer with credit balance: c2 has -50
    { id: 't5', personId: 'c2', type: TransactionType.PAYMENT_RECEIVED, amount: 150, date: '' },
    { id: 't6', personId: 'c2', type: TransactionType.SALE_ON_CREDIT, amount: 100, date: '' },

    // Supplier with credit balance: s2 has -200
    { id: 't7', personId: 's2', type: TransactionType.PAYMENT_MADE, amount: 500, date: '' },
    { id: 't8', personId: 's2', type: TransactionType.PURCHASE_ON_CREDIT, amount: 300, date: '' },
  ];

  it('should return 0 for an undefined person', () => {
    expect(calculatePersonBalance(undefined, transactions)).toBe(0);
  });

  it('should correctly calculate the balance for a customer who owes money', () => {
    expect(calculatePersonBalance(customer, transactions)).toBe(150); // 200 - 50
  });

  it('should correctly calculate the balance for a supplier who is owed money', () => {
    expect(calculatePersonBalance(supplier, transactions)).toBe(500); // 800 - 300
  });
  
  it('should correctly calculate a negative balance (credit) for a customer', () => {
    const customer2: Person = { id: 'c2', name: 'Customer B', role: PersonRole.CUSTOMER, phone: null, createdAt: '' };
    expect(calculatePersonBalance(customer2, transactions)).toBe(-50); // 100 - 150
  });

  it('should correctly calculate a negative balance (credit) for a supplier', () => {
    const supplier2: Person = { id: 's2', name: 'Supplier B', role: PersonRole.SUPPLIER, phone: null, createdAt: '' };
    expect(calculatePersonBalance(supplier2, transactions)).toBe(-200); // 300 - 500
  });

  it('should return 0 for a person with no transactions', () => {
    const newPerson: Person = { id: 'new', name: 'New Person', role: PersonRole.CUSTOMER, phone: null, createdAt: '' };
    expect(calculatePersonBalance(newPerson, transactions)).toBe(0);
  });
});