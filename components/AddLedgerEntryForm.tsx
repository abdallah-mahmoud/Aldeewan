import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db';
import type { Transaction, LedgerFlowType, Person } from '../types';
import { TransactionType, PersonRole } from '../types';
import DatePicker from './DatePicker';
import Modal from './Modal';
import AddPersonForm from './AddPersonForm';
import { UserPlus } from 'lucide-react';

interface PersonTransactionFormProps {
    flowType: LedgerFlowType;
    onSave: (entryData: Omit<Transaction, 'id'>) => void;
    onCancel: () => void;
}

export const PersonTransactionForm: React.FC<PersonTransactionFormProps> = ({ flowType, onSave, onCancel }) => {
    const { t, getTodayDateString } = useLocalization();
    const { addPerson } = useData();
    const persons = useLiveQuery(() => db.persons.toArray(), []) || [];

    const [personId, setPersonId] = useState('');
    const [amount, setAmount] = useState('');
    const [date, setDate] = useState(getTodayDateString());
    const [note, setNote] = useState('');
    const [isAddPersonModalOpen, setIsAddPersonModalOpen] = useState(false);
    const [amountError, setAmountError] = useState('');

    const handleSaveNewPerson = async (personData: Omit<Person, 'id' | 'createdAt'>) => {
        try {
            const newPersonId = await addPerson(personData);
            setPersonId(newPersonId);
            setIsAddPersonModalOpen(false);
        } catch (error) {
            console.error("Failed to add new person:", error);
        }
    };

    const validate = () => {
        if (Number(amount) <= 0) {
            setAmountError(t('error_amount_positive'));
            return false;
        }
        setAmountError('');
        return true;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        const selectedPerson = persons.find(p => p.id === personId);
        if (!selectedPerson || !date) return;
        
        if (validate()) {
            let transactionType: TransactionType;
            if (flowType === 'debt') {
                transactionType = selectedPerson.role === PersonRole.CUSTOMER ? TransactionType.SALE_ON_CREDIT : TransactionType.PURCHASE_ON_CREDIT;
            } else { // payment
                transactionType = selectedPerson.role === PersonRole.CUSTOMER ? TransactionType.PAYMENT_RECEIVED : TransactionType.PAYMENT_MADE;
            }

            // By saving the date as noon UTC, we prevent timezone shifts from changing the date.
            const dateToSave = new Date(`${date}T12:00:00Z`).toISOString();
            onSave({ personId, amount: Number(amount), date: dateToSave, type: transactionType, note });
        }
    }

    return (
        <>
            <form onSubmit={handleSubmit} className="space-y-4 p-4">
                <div>
                    <div className="flex justify-between items-center mb-1">
                        <label htmlFor="person-select" className="block text-sm font-medium">{t('selectPerson')}</label>
                        <button
                            type="button"
                            onClick={() => setIsAddPersonModalOpen(true)}
                            className="flex items-center gap-1 text-xs text-light-primary dark:text-dark-primary font-semibold hover:underline"
                        >
                            <UserPlus className="w-4 h-4" />
                            {t('addPerson')}
                        </button>
                    </div>
                    <select id="person-select" value={personId} onChange={e => setPersonId(e.target.value)} required className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                        <option value="" disabled>{`-- ${t('selectPerson')} --`}</option>
                        {persons.map(p => (
                            <option key={p.id} value={p.id}>{p.name} ({t(p.role)})</option>
                        ))}
                    </select>
                </div>
                <div>
                    <label htmlFor="ledger-entry-amount" className="block text-sm font-medium mb-1">{t('amount')}</label>
                    <input id="ledger-entry-amount"
                        type="number" 
                        step="any" 
                        value={amount} 
                        onChange={e => { setAmount(e.target.value); if (amountError) setAmountError(''); }} 
                        required 
                        className={`w-full p-2 border rounded-lg bg-light-background dark:bg-dark-background outline-none ${
                            amountError 
                            ? 'border-brand-red focus:ring-brand-red' 
                            : 'border-black/10 dark:border-white/10 focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary'
                        }`}
                    />
                    {amountError && <p className="text-sm text-brand-red mt-1">{amountError}</p>}
                </div>
                <div>
                    <label htmlFor="ledger-entry-date" className="block text-sm font-medium mb-1">{t('date')}</label>
                    <DatePicker id="ledger-entry-date" value={date} onChange={setDate} required />
                </div>
                <div>
                    <label htmlFor="ledger-entry-note" className="block text-sm font-medium mb-1">{t('note')}</label>
                    <textarea id="ledger-entry-note" value={note} onChange={e => setNote(e.target.value)} rows={2} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none" />
                </div>
                <div className="flex justify-end gap-2 pt-2">
                    <button type="button" onClick={onCancel} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                    <button type="submit" className="px-4 py-2 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('save')}</button>
                </div>
            </form>
            <Modal isOpen={isAddPersonModalOpen} onClose={() => setIsAddPersonModalOpen(false)} title={t('addPerson')}>
                <AddPersonForm onSave={handleSaveNewPerson} onCancel={() => setIsAddPersonModalOpen(false)} />
            </Modal>
        </>
    );
};