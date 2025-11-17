// Added imports for Jest's global functions to satisfy TypeScript.
import { describe, it, expect } from '@jest/globals';
import { calculateCashFlowReport, generatePersonStatementText } from '../../utils/reporting';
import { TransactionType, PersonRole } from '../../types';
import type { Transaction, Person } from '../../types';

// Mock t function for i18n
const t = (key: string) => key;

describe('calculateCashFlowReport', () => {
    it('should correctly aggregate income and expenses by category', () => {
        const transactions: Transaction[] = [
            { id: '1', type: TransactionType.CASH_SALE, category: 'Sales', amount: 100, date: '' },
            { id: '2', type: TransactionType.CASH_EXPENSE, category: 'Rent', amount: 50, date: '' },
            { id: '3', type: TransactionType.CASH_INCOME, category: 'Tips', amount: 10, date: '' },
            { id: '4', type: TransactionType.CASH_SALE, category: 'Sales', amount: 200, date: '' },
        ];

        const report = calculateCashFlowReport(transactions, t);

        expect(report.categories).toHaveLength(3);
        
        const salesCategory = report.categories.find(c => c.name === 'Sales');
        expect(salesCategory?.income).toBe(300);
        expect(salesCategory?.expense).toBe(0);
        
        const rentCategory = report.categories.find(c => c.name === 'Rent');
        expect(rentCategory?.income).toBe(0);
        expect(rentCategory?.expense).toBe(50);

        expect(report.profitLoss?.cashIn).toBe(310);
        expect(report.profitLoss?.cashOut).toBe(50);
        expect(report.profitLoss?.profit).toBe(260);
    });

    it('should return empty state for no transactions', () => {
        const report = calculateCashFlowReport([], t);
        expect(report.categories).toEqual([]);
        expect(report.profitLoss).toBeNull();
    });
});


describe('generatePersonStatementText', () => {
    const person: Person = { id: 'p1', name: 'Test Person', role: PersonRole.CUSTOMER, phone: null, createdAt: '' };
    const transactionsInDateRange: Transaction[] = [
        { id: 't1', personId: 'p1', type: TransactionType.SALE_ON_CREDIT, amount: 100, date: '2023-01-05T12:00:00Z', note: 'Invoice 1' },
        { id: 't2', personId: 'p1', type: TransactionType.PAYMENT_RECEIVED, amount: 30, date: '2023-01-10T12:00:00Z' },
    ];
    const formatDate = (date: string) => new Date(date).toLocaleDateString('en-US');
    const formatCurrency = (amount: number) => `$${amount.toFixed(2)}`;

    it('should generate a correct statement string', () => {
        const statement = generatePersonStatementText({
            person,
            transactionsInDateRange,
            balanceBroughtForward: 20,
            t,
            formatDate,
            formatCurrency,
        });

        // Check for key elements
        expect(statement).toContain('statement_header');
        expect(statement).toContain('Test Person');
        expect(statement).toContain('statement_summary_header');
        expect(statement).toContain('statement_tx_history_header');
        
        // Check running balance calculation: 20 (brought fwd) + 100 - 30 = 90
        expect(statement).toContain('Running Balance: $120.00'); // After first tx
        expect(statement).toContain('Running Balance: $90.00'); // After second tx
        
        // Check final balance
        expect(statement).toContain('statement_final_balance_due: $90.00');
        
        // Check note is included
        expect(statement).toContain('Note: Invoice 1');
    });
});