import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import type { CashEntry } from '../types';
import { CashEntryType } from '../types';
import DatePicker from './DatePicker';

interface CashEntryFormProps {
    entry: CashEntry | null;
    onSave: (entryData: Omit<CashEntry, 'id'>) => void;
    onCancel: () => void;
}
const CashEntryForm: React.FC<CashEntryFormProps> = ({ entry, onSave, onCancel }) => {
    const { t } = useLocalization();
    const [type, setType] = useState(entry?.type || CashEntryType.INCOME);
    const [category, setCategory] = useState(entry?.category || '');
    const [amount, setAmount] = useState(entry?.amount || '');
    const [date, setDate] = useState(entry ? new Date(entry.date).toISOString().split('T')[0] : new Date().toISOString().split('T')[0]);
    const [note, setNote] = useState(entry?.note || '');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!category || !amount || !date) return;
        onSave({ type, category, amount: Number(amount), date: new Date(date).toISOString(), note });
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label className="block text-sm font-medium mb-1">{t('type')}</label>
                <select value={type} onChange={e => setType(e.target.value as CashEntryType)} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                    <option value={CashEntryType.INCOME}>{t('income')}</option>
                    <option value={CashEntryType.EXPENSE}>{t('expense')}</option>
                </select>
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('category')}</label>
                <input type="text" value={category} onChange={e => setCategory(e.target.value)} required className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none" />
            </div>
            <div>
                <label className="block text-sm font-medium mb-1">{t('amount')}</label>
                <input type="number" step="any" value={amount} onChange={e => setAmount(e.target.value)} required className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none" />
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

export default CashEntryForm;