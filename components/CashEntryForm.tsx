import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import type { Transaction } from '../types';
import { TransactionType } from '../types';
import DatePicker from './DatePicker';

interface CashTransactionFormProps {
    entry: Transaction | null;
    onSave: (entryData: Omit<Transaction, 'id'>) => void;
    onCancel: () => void;
}
export const CashTransactionForm: React.FC<CashTransactionFormProps> = ({ entry, onSave, onCancel }) => {
    const { t, getTodayDateString } = useLocalization();
    const [type, setType] = useState(entry?.type || TransactionType.CASH_INCOME);
    const [category, setCategory] = useState(entry?.category || '');
    const [amount, setAmount] = useState(entry?.amount || '');
    const [date, setDate] = useState(entry ? new Date(entry.date).toISOString().split('T')[0] : getTodayDateString());
    const [note, setNote] = useState(entry?.note || '');
    const [errors, setErrors] = useState<{ category?: string; amount?: string }>({});

    const isIncome = type === TransactionType.CASH_INCOME || type === TransactionType.CASH_SALE;

    const validate = () => {
        const newErrors: { category?: string; amount?: string } = {};
        if (category.trim() === '') {
            newErrors.category = t('error_category_required');
        }
        if (Number(amount) <= 0) {
            newErrors.amount = t('error_amount_positive');
        }
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validate()) {
            // By saving the date as noon UTC, we prevent timezone shifts from changing the date.
            const dateToSave = new Date(`${date}T12:00:00Z`).toISOString();
            const transactionType = type === TransactionType.CASH_SALE ? (isIncome ? TransactionType.CASH_SALE : TransactionType.CASH_EXPENSE) : type;
            onSave({ type: transactionType, category, amount: Number(amount), date: dateToSave, note });
        }
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label className="block text-sm font-medium mb-1">{t('type')}</label>
                <select 
                    value={isIncome ? 'income' : 'expense'} 
                    onChange={e => setType(e.target.value === 'income' ? TransactionType.CASH_INCOME : TransactionType.CASH_EXPENSE)} 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none"
                >
                    <option value='income'>{t('income')}</option>
                    <option value='expense'>{t('expense')}</option>
                </select>
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('category')}</label>
                <input 
                    type="text" 
                    value={category} 
                    onChange={e => { setCategory(e.target.value); if (errors.category) setErrors(p => ({...p, category: undefined})); }} 
                    required 
                    className={`w-full p-2 border rounded-lg bg-light-background dark:bg-dark-background outline-none ${
                        errors.category 
                        ? 'border-brand-red focus:ring-brand-red' 
                        : 'border-black/10 dark:border-white/10 focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary'
                    }`}
                />
                {errors.category && <p className="text-sm text-brand-red mt-1">{errors.category}</p>}
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('amount')}</label>
                <input 
                    type="number" 
                    step="any" 
                    value={amount} 
                    onChange={e => { setAmount(e.target.value); if (errors.amount) setErrors(p => ({...p, amount: undefined})); }} 
                    required 
                    className={`w-full p-2 border rounded-lg bg-light-background dark:bg-dark-background outline-none ${
                        errors.amount 
                        ? 'border-brand-red focus:ring-brand-red' 
                        : 'border-black/10 dark:border-white/10 focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary'
                    }`}
                />
                {errors.amount && <p className="text-sm text-brand-red mt-1">{errors.amount}</p>}
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('date')}</label>
                <DatePicker value={date} onChange={setDate} required />
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('note')}</label>
                <textarea value={note} onChange={e => setNote(e.target.value)} rows={2} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none" />
            </div>
            <div className="flex justify-end gap-2 pt-2">
                <button type="button" onClick={onCancel} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                <button type="submit" className="px-4 py-2 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('save')}</button>
            </div>
        </form>
    )
}
