import React, { useMemo } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db';
import { calculatePersonBalance } from '../utils/calculations';
import type { Screen, LedgerFlowType } from '../types';
import { TransactionType } from '../types';
import { FilePlus2, CreditCard, PlusCircle, Scale, ArrowDownCircle, ArrowUpCircle } from 'lucide-react';


interface ActionButtonProps {
    label: string;
    Icon: React.ElementType;
    onClick: () => void;
}

const ActionButton: React.FC<ActionButtonProps> = ({ label, Icon, onClick }) => (
    <button
        onClick={onClick}
        className="bg-light-surface dark:bg-dark-surface rounded-lg p-4 flex flex-col items-center justify-center text-center ring-1 ring-black/5 dark:ring-white/10 hover:ring-light-primary dark:hover:ring-dark-primary transition-all duration-200"
    >
        <div className="bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary rounded-full p-3 mb-3">
            <Icon className="w-7 h-7" />
        </div>
        <span className="font-semibold text-sm text-light-on-surface dark:text-dark-on-surface">{label}</span>
    </button>
);

interface StatCardProps {
    label: string;
    value: number;
    Icon: React.ElementType;
    colorClass: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, value, Icon, colorClass }) => {
    const { formatCurrency } = useLocalization();
    const formattedValue = formatCurrency(value);
    
    // Determine text size based on length to prevent wrapping
    let valueTextSize = 'text-xl';
    

    return (
        <div className="bg-light-surface dark:bg-dark-surface p-4 rounded-lg flex items-center space-x-3 rtl:space-x-reverse ring-1 ring-black/5 dark:ring-white/10">
            <div className={`p-2 rounded-full bg-opacity-10 ${colorClass.replace('text-', 'bg-')}`}>
                <Icon className={`w-6 h-6 ${colorClass}`} />
            </div>
            <div className="min-w-0">
                <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{label}</p>
                <p className={`${valueTextSize} font-bold text-light-on-surface dark:text-dark-on-surface whitespace-nowrap`}>{formattedValue}</p>
            </div>
        </div>
    );
};


interface HomeScreenProps {
    setActiveScreen: (screen: Screen) => void;
    onAddCashEntry: () => void;
    onAddLedgerEntry: (type: LedgerFlowType) => void;
}

const HomeScreen: React.FC<HomeScreenProps> = ({ setActiveScreen, onAddCashEntry, onAddLedgerEntry }) => {
    const { t } = useLocalization();
    const persons = useLiveQuery(() => db.persons.toArray(), []) || [];
    const transactions = useLiveQuery(() => db.transactions.toArray(), []) || [];

    const homeScreenTotals = useMemo(() => {
        let totalReceivable = 0;
        let totalPayable = 0;

        persons.forEach(person => {
            const balance = calculatePersonBalance(person, transactions);
            if (balance > 0) {
                if (person.role === 'customer') {
                    totalReceivable += balance;
                } else if (person.role === 'supplier') {
                    totalPayable += balance;
                }
            }
        });
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();

        let monthlyIncome = 0;
        let monthlyExpense = 0;

        const incomeTypes = [TransactionType.CASH_SALE, TransactionType.PAYMENT_RECEIVED, TransactionType.CASH_INCOME];
        const expenseTypes = [TransactionType.PAYMENT_MADE, TransactionType.CASH_EXPENSE];

        transactions.forEach(t => {
            const entryDate = new Date(t.date);
            if (entryDate.getMonth() === currentMonth && entryDate.getFullYear() === currentYear) {
                if (incomeTypes.includes(t.type)) {
                    monthlyIncome += t.amount;
                } else if (expenseTypes.includes(t.type)) {
                    monthlyExpense += t.amount;
                }
            }
        });

        return { totalReceivable, totalPayable, monthlyIncome, monthlyExpense };
    }, [persons, transactions]);

    const { totalReceivable, totalPayable, monthlyIncome, monthlyExpense } = homeScreenTotals;

    return (
        <div className="space-y-6">
             <h2 className="text-lg font-semibold text-center text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('tagline')}</h2>
            
            <div className="grid grid-cols-1 gap-4">
                <StatCard label={t('totalReceivable')} value={totalReceivable} Icon={ArrowDownCircle} colorClass="text-brand-green" />
                <StatCard label={t('totalPayable')} value={totalPayable} Icon={ArrowUpCircle} colorClass="text-brand-red" />
                <StatCard label={t('monthlyIncome')} value={monthlyIncome} Icon={ArrowDownCircle} colorClass="text-brand-green" />
                <StatCard label={t('monthlyExpense')} value={monthlyExpense} Icon={ArrowUpCircle} colorClass="text-brand-red" />
            </div>

            <div>
                <h2 className="text-lg font-bold mb-3 text-light-on-surface dark:text-dark-on-surface">{t('quickActions')}</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <ActionButton label={t('addDebt')} Icon={FilePlus2} onClick={() => onAddLedgerEntry('debt')} />
                    <ActionButton label={t('recordPayment')} Icon={CreditCard} onClick={() => onAddLedgerEntry('payment')} />
                    <ActionButton label={t('addCashEntry')} Icon={PlusCircle} onClick={onAddCashEntry} />
                    <ActionButton label={t('viewBalances')} Icon={Scale} onClick={() => setActiveScreen('ledger')} />
                </div>
            </div>
        </div>
    );
};

export default HomeScreen;