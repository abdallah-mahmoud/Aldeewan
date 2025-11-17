import type { Person, Transaction } from '../types';
import { PersonRole, TransactionType } from '../types';

const incomeTypes = [TransactionType.CASH_SALE, TransactionType.PAYMENT_RECEIVED, TransactionType.CASH_INCOME];
const expenseTypes = [TransactionType.CASH_EXPENSE, TransactionType.PAYMENT_MADE];


export function calculateCashFlowReport(transactions: Transaction[], t: (key: string) => string) {
    if (transactions.length === 0) {
        return { categories: [], profitLoss: null };
    }

    const categories: Record<string, { name: string, income: number, expense: number }> = {};
    let cashIn = 0;
    let cashOut = 0;

    transactions.forEach(tx => {
        const categoryName = tx.category || t(tx.type);
        if (!categories[categoryName]) {
            categories[categoryName] = { name: categoryName, income: 0, expense: 0 };
        }
        if (incomeTypes.includes(tx.type)) {
            categories[categoryName].income += tx.amount;
            // From a pure cash flow perspective, only actual cash movements should be counted for profit/loss.
            if (tx.type === TransactionType.CASH_SALE || tx.type === TransactionType.PAYMENT_RECEIVED || tx.type === TransactionType.CASH_INCOME) cashIn += tx.amount;
        } else if (expenseTypes.includes(tx.type)) {
            categories[categoryName].expense += tx.amount;
            if (tx.type === TransactionType.CASH_EXPENSE || tx.type === TransactionType.PAYMENT_MADE) cashOut += tx.amount;
        }
    });
    
    const profit = cashIn - cashOut;

    return { 
        categories: Object.values(categories).sort((a,b) => (b.income + b.expense) - (a.income + a.expense)),
        profitLoss: { cashIn, cashOut, profit }
    };
}


export function generatePersonStatementText({
    person,
    transactionsInDateRange,
    balanceBroughtForward,
    t,
    formatDate,
    formatCurrency,
}: {
    person: Person;
    transactionsInDateRange: Transaction[];
    balanceBroughtForward: number;
    t: (key: string) => string;
    formatDate: (date: string) => string;
    formatCurrency: (amount: number) => string;
}) {
    let runningBalance = balanceBroughtForward;
    
    const history = transactionsInDateRange.map(tx => {
        const debitTypes = [TransactionType.SALE_ON_CREDIT, TransactionType.PURCHASE_ON_CREDIT];
        runningBalance += debitTypes.includes(tx.type) ? tx.amount : -tx.amount;
        
        let txTypeLabel = t(tx.type); // Fallback
        if (person.role === PersonRole.CUSTOMER) {
            txTypeLabel = tx.type === TransactionType.SALE_ON_CREDIT ? t('customer_tx_debt') : t('customer_tx_payment');
        } else {
            txTypeLabel = tx.type === TransactionType.PURCHASE_ON_CREDIT ? t('supplier_tx_debt') : t('supplier_tx_payment');
        }
        
        let entry = `\n🗓️ ${formatDate(tx.date)}\n${txTypeLabel}: ${formatCurrency(tx.amount)}`;
        if (tx.note) entry += `\n  - ${t('statement_tx_note_prefix')}: ${tx.note}`;
        entry += `\n  - ${t('statement_tx_running_balance_prefix')}: ${formatCurrency(runningBalance)}`;
        return entry;
    }).join('\n');

    const header = [ t('statement_header'), `${t('statement_from')}: ${t('appName')}`, `${t('statement_to')}: ${person.name}`, `${t('statement_date')}: ${formatDate(new Date().toISOString())}` ].join('\n');
    let finalBalanceLabel = '';
     if (runningBalance > 0) {
        finalBalanceLabel = person.role === PersonRole.CUSTOMER ? t('statement_final_balance_due') : t('statement_final_balance_payable');
    } else if (runningBalance < 0) {
        finalBalanceLabel = t('statement_final_balance_credit');
    }
    const summary = `\n${t('statement_summary_header')}\n${finalBalanceLabel}: ${formatCurrency(Math.abs(runningBalance))}`;
    const historySection = `\n\n${t('statement_tx_history_header')}\n--------------------${history}\n--------------------`;
    const footer = `\n\n${t('statement_footer_thanks')}\n${t('statement_footer_generated_by')}`;

    return [header, summary, historySection, footer].join('\n');
}
