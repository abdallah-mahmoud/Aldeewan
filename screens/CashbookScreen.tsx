import React, { useMemo, useState, useEffect, useRef } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import type { CashEntry } from '../types';
import { CashEntryType } from '../types';
import { ArrowDownCircle, ArrowUpCircle, Plus, MoreVertical, Edit, Trash2 } from 'lucide-react';
import Modal from '../components/Modal';
import CashEntryForm from '../components/CashEntryForm';

const CashEntryListItem: React.FC<{ entry: CashEntry; onEdit: (entry: CashEntry) => void; onDelete: (id: string) => void; }> = ({ entry, onEdit, onDelete }) => {
    const { t, formatCurrency, formatDate } = useLocalization();
    const [menuOpen, setMenuOpen] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);
    
    const isIncome = entry.type === CashEntryType.INCOME;
    const amountColor = isIncome ? 'text-brand-green' : 'text-brand-red';
    const IconComponent = isIncome ?
        <ArrowDownCircle className="w-6 h-6 text-brand-green" /> :
        <ArrowUpCircle className="w-6 h-6 text-brand-red" />;

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
                setMenuOpen(false);
            }
        };
        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);

    return (
        <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-3 flex items-center justify-between ring-1 ring-black/5 dark:ring-white/10">
            <div className="flex items-center space-x-3 rtl:space-x-reverse">
                <div className={`p-2 rounded-full ${isIncome ? 'bg-green-500/10' : 'bg-red-500/10'}`}>
                    {IconComponent}
                </div>
                <div>
                    <p className="font-semibold text-light-on-surface dark:text-dark-on-surface">{entry.category}</p>
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{formatDate(entry.date)}</p>
                </div>
            </div>
            <div className="flex items-center gap-2">
                <p className={`font-bold text-lg ${amountColor}`}>{formatCurrency(entry.amount)}</p>
                 <div className="relative">
                    <button onClick={() => setMenuOpen(p => !p)} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5">
                        <MoreVertical className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary"/>
                    </button>
                    {menuOpen && (
                        <div ref={menuRef} className="absolute top-full end-0 mt-1 w-32 bg-light-surface dark:bg-dark-surface rounded-md shadow-lg ring-1 ring-black/5 dark:ring-white/10 z-20">
                            <button onClick={() => { onEdit(entry); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm hover:bg-black/5 dark:hover:bg-white/5"><Edit className="w-4 h-4" /> {t('edit')}</button>
                            <button onClick={() => { onDelete(entry.id); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm text-brand-red hover:bg-black/5 dark:hover:bg-white/5"><Trash2 className="w-4 h-4" /> {t('delete')}</button>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

const CashbookScreen: React.FC = () => {
    const { t, formatCurrency } = useLocalization();
    const { cashEntries, addCashEntry, updateCashEntry, deleteCashEntry } = useData();

    const [isFormOpen, setIsFormOpen] = useState(false);
    const [editingEntry, setEditingEntry] = useState<CashEntry | null>(null);
    const [deletingEntryId, setDeletingEntryId] = useState<string | null>(null);

    const { totalIncome, totalExpense, netFlow } = useMemo(() => {
        let income = 0;
        let expense = 0;
        cashEntries.forEach(entry => {
            if (entry.type === CashEntryType.INCOME) {
                income += entry.amount;
            } else {
                expense += entry.amount;
            }
        });
        return { totalIncome: income, totalExpense: expense, netFlow: income - expense };
    }, [cashEntries]);

    const handleOpenForm = (entry: CashEntry | null) => {
        setEditingEntry(entry);
        setIsFormOpen(true);
    };

    const handleCloseForm = () => {
        setIsFormOpen(false);
        setEditingEntry(null);
    };

    const handleSaveEntry = (entryData: Omit<CashEntry, 'id'>) => {
        if (editingEntry) { // Editing
            updateCashEntry(editingEntry.id, entryData);
        } else { // Adding
            addCashEntry(entryData);
        }
        handleCloseForm();
    };

    const handleDeleteConfirm = () => {
        if (deletingEntryId) {
            deleteCashEntry(deletingEntryId);
            setDeletingEntryId(null);
        }
    };

    return (
        <div className="space-y-4">
            <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('incomeAndExpenses')}</h1>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-4 rounded-lg">
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalIncome')}</p>
                    <p className="text-2xl font-bold text-brand-green">{formatCurrency(totalIncome)}</p>
                </div>
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-4 rounded-lg">
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalExpense')}</p>
                    <p className="text-2xl font-bold text-brand-red">{formatCurrency(totalExpense)}</p>
                </div>
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-4 rounded-lg col-span-1 md:col-span-1">
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('netFlow')}</p>
                    <p className={`text-2xl font-bold ${netFlow >= 0 ? 'text-light-primary dark:text-dark-primary' : 'text-orange-500'}`}>{formatCurrency(netFlow)}</p>
                </div>
            </div>

            <div className="space-y-3">
                {cashEntries
                    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
                    .map(entry => (
                        <CashEntryListItem key={entry.id} entry={entry} onEdit={() => handleOpenForm(entry)} onDelete={() => setDeletingEntryId(entry.id)} />
                ))}
            </div>

            <button onClick={() => handleOpenForm(null)} className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110">
                <Plus className="w-6 h-6" />
            </button>
            
            <Modal isOpen={isFormOpen} onClose={handleCloseForm} title={editingEntry ? t('editEntry') : t('addEntry')}>
                <CashEntryForm entry={editingEntry} onSave={handleSaveEntry} onCancel={handleCloseForm} />
            </Modal>
            
            <Modal isOpen={!!deletingEntryId} onClose={() => setDeletingEntryId(null)} title={t('confirmDeletion')}>
                 <div className="p-4 space-y-4">
                    <p>{t('areYouSureDelete')}</p>
                    <div className="flex justify-end gap-2">
                        <button onClick={() => setDeletingEntryId(null)} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                        <button onClick={handleDeleteConfirm} className="px-4 py-2 rounded-lg font-semibold bg-brand-red text-white hover:bg-red-600">{t('delete')}</button>
                    </div>
                </div>
            </Modal>
        </div>
    );
};

export default CashbookScreen;
