import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import type { LedgerEntry } from '../types';
import { LedgerEntryType } from '../types';
import DatePicker from './DatePicker';

interface AddLedgerEntryFormProps {
    type: LedgerEntryType;
    onSave: (entryData: Omit<LedgerEntry, 'id'>) => void;
    onCancel: () => void;
}

const AddLedgerEntryForm: React.FC<AddLedgerEntryFormProps> = ({ type, onSave, onCancel }) => {
    const { t } = useLocalization();
    const { persons } = useData();

    const [personId, setPersonId] = useState('');
    const [amount, setAmount] = useState('');
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const [note, setNote] = useState('');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!personId || !amount || !date) return;
        onSave({ personId, amount: Number(amount), date: new Date(date).toISOString(), type, note });
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label className="block text-sm font-medium mb-1">{t('selectPerson')}</label>
                <select value={personId} onChange={e => setPersonId(e.target.value)} required className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                    <option value="" disabled>{`-- ${t('selectPerson')} --`}</option>
                    {persons.map(p => (
                        <option key={p.id} value={p.id}>{p.name} ({t(p.role)})</option>
                    ))}
                </select>
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
    );
};

export default AddLedgerEntryForm;