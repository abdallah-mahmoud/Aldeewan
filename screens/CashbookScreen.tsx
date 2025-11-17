import React, { useMemo, useState, useEffect, useRef } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import { useToast } from '../context/ToastContext';
import type { Transaction } from '../types';
import { TransactionType } from '../types';
import { ArrowDownCircle, ArrowUpCircle, Plus, MoreVertical, Edit, Trash2, Archive, Filter, Search, X } from 'lucide-react';
import Modal from '../components/Modal';
import { CashTransactionForm } from '../components/CashEntryForm';
import EmptyState from '../components/EmptyState';
import DatePicker from '../components/DatePicker';
import useDebounce from '../hooks/useDebounce';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db';
import { useVirtualizer } from '@tanstack/react-virtual';

const incomeTypes = [TransactionType.CASH_SALE, TransactionType.PAYMENT_RECEIVED, TransactionType.CASH_INCOME];
const expenseTypes = [TransactionType.PAYMENT_MADE, TransactionType.CASH_EXPENSE];
const cashTypes = [...incomeTypes, ...expenseTypes];

const TransactionListItem: React.FC<{ transaction: Transaction; onEdit: (transaction: Transaction) => void; onDelete: (id: string) => void; }> = ({ transaction, onEdit, onDelete }) => {
    const { t, formatCurrency, formatDate } = useLocalization();
    const [menuOpen, setMenuOpen] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);
    
    const isIncome = incomeTypes.includes(transaction.type);
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

    const title = transaction.category || t(transaction.type);

    return (
        <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-3 flex items-center justify-between ring-1 ring-black/5 dark:ring-white/10">
            <div className="flex items-center space-x-3 rtl:space-x-reverse">
                <div className={`p-2 rounded-full ${isIncome ? 'bg-green-500/10' : 'bg-red-500/10'}`}>
                    {IconComponent}
                </div>
                <div>
                    <p className="font-semibold text-light-on-surface dark:text-dark-on-surface">{title}</p>
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{formatDate(transaction.date)}</p>
                </div>
            </div>
            <div className="flex items-center gap-2">
                <p className={`font-bold text-lg ${amountColor}`}>{formatCurrency(transaction.amount)}</p>
                 <div className="relative">
                    <button onClick={() => setMenuOpen(p => !p)} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5">
                        <MoreVertical className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary"/>
                    </button>
                    {menuOpen && (
                        <div ref={menuRef} className="absolute top-full end-0 mt-1 w-32 bg-light-surface dark:bg-dark-surface rounded-md shadow-lg ring-1 ring-black/5 dark:ring-white/10 z-20">
                            <button onClick={() => { onEdit(transaction); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm hover:bg-black/5 dark:hover:bg-white/5"><Edit className="w-4 h-4" /> {t('edit')}</button>
                            <button onClick={() => { onDelete(transaction.id); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm text-brand-red hover:bg-black/5 dark:hover:bg-white/5"><Trash2 className="w-4 h-4" /> {t('delete')}</button>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

const FilterButton: React.FC<{ label: string; isActive: boolean; onClick: () => void; }> = ({ label, isActive, onClick }) => (
    <button
        onClick={onClick}
        className={`w-full py-2 px-3 rounded-lg text-sm font-semibold transition-colors ${
            isActive
                ? 'bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background shadow'
                : 'bg-light-background dark:bg-dark-background hover:bg-black/5 dark:hover:bg-white/5 ring-1 ring-inset ring-black/10 dark:ring-white/10'
        }`}
    >
        {label}
    </button>
);


const CashbookScreen: React.FC = () => {
    const { t, formatCurrency } = useLocalization();
    const { addTransaction, updateTransaction, deleteTransaction } = useData();
    const { showToast } = useToast();
    
    const allCashTransactions = useLiveQuery(() => 
        db.transactions.where('type').anyOf(cashTypes).sortBy('date'), 
    [])?.reverse() || [];


    const [isFormOpen, setIsFormOpen] = useState(false);
    const [editingTransaction, setEditingTransaction] = useState<Transaction | null>(null);
    const [deletingTransactionId, setDeletingTransactionId] = useState<string | null>(null);
    const [isFilterPanelOpen, setFilterPanelOpen] = useState(false);
    
    const [localSearchTerm, setLocalSearchTerm] = useState('');
    const debouncedSearchTerm = useDebounce(localSearchTerm, 300);
    
    const [filters, setFilters] = useState({
        searchTerm: '',
        dateOption: 'all',
        type: 'all',
        startDate: '',
        endDate: '',
    });

    useEffect(() => {
        handleFilterChange('searchTerm', debouncedSearchTerm);
    }, [debouncedSearchTerm]);


    const handleFilterChange = (key: keyof typeof filters, value: string) => {
        setFilters(prev => ({...prev, [key]: value}));
    };
    
    const resetFilters = () => {
        setLocalSearchTerm('');
        setFilters({ searchTerm: '', dateOption: 'all', type: 'all', startDate: '', endDate: '' });
        setFilterPanelOpen(false);
    };
    
    const filteredCashTransactions = useMemo(() => {
        const { searchTerm, dateOption, type, startDate, endDate } = filters;
        
        return allCashTransactions.filter(t => {
            if (type !== 'all') {
                const isIncome = incomeTypes.includes(t.type);
                if (type === 'income' && !isIncome) return false;
                if (type === 'expense' && isIncome) return false;
            }

            if (dateOption !== 'all') {
                const txDate = new Date(t.date);
                if (dateOption === 'thisMonth') {
                    const now = new Date();
                    if (txDate.getMonth() !== now.getMonth() || txDate.getFullYear() !== now.getFullYear()) return false;
                } else if (dateOption === 'lastMonth') {
                    const now = new Date();
                    const lastMonthDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
                    if (txDate.getMonth() !== lastMonthDate.getMonth() || txDate.getFullYear() !== lastMonthDate.getFullYear()) return false;
                } else if (dateOption === 'custom' && startDate && endDate) {
                    const start = new Date(`${startDate}T00:00:00Z`);
                    const end = new Date(`${endDate}T23:59:59Z`);
                    if (txDate < start || txDate > end) return false;
                }
            }

            if (searchTerm) {
                const term = searchTerm.toLowerCase();
                const inCategory = t.category?.toLowerCase().includes(term);
                const inNote = t.note?.toLowerCase().includes(term);
                if (!inCategory && !inNote) return false;
            }
            
            return true;
        });
    }, [allCashTransactions, filters]);


    const { totalIncome, totalExpense, netFlow } = useMemo(() => {
        let income = 0;
        let expense = 0;
        filteredCashTransactions.forEach(t => {
            if (incomeTypes.includes(t.type)) {
                income += t.amount;
            } else {
                expense += t.amount;
            }
        });
        return { totalIncome: income, totalExpense: expense, netFlow: income - expense };
    }, [filteredCashTransactions]);

    const handleOpenForm = (transaction: Transaction | null) => {
        setEditingTransaction(transaction);
        setIsFormOpen(true);
    };

    const handleCloseForm = () => {
        setIsFormOpen(false);
        setEditingTransaction(null);
    };

    const handleSaveTransaction = (transactionData: Omit<Transaction, 'id'>) => {
        if (editingTransaction) {
            updateTransaction(editingTransaction.id, transactionData);
        } else {
            addTransaction(transactionData);
        }
        handleCloseForm();
        showToast(t('toast_saved_successfully'), 'success');
    };

    const handleDeleteConfirm = () => {
        if (deletingTransactionId) {
            deleteTransaction(deletingTransactionId);
            setDeletingTransactionId(null);
            showToast(t('toast_deleted_successfully'), 'success');
        }
    };

    const isAnyFilterActive = filters.dateOption !== 'all' || filters.type !== 'all' || filters.searchTerm !== '';
    
    const parentRef = useRef<HTMLDivElement>(null);
    const rowVirtualizer = useVirtualizer({
        count: filteredCashTransactions.length,
        getScrollElement: () => parentRef.current,
        estimateSize: () => 76,
        overscan: 5,
    });

    return (
        <div className="space-y-4">
            <div className="flex justify-between items-center">
                 <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('incomeAndExpenses')}</h1>
                 <button 
                    onClick={() => setFilterPanelOpen(p => !p)} 
                    className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5 relative"
                    aria-label={t('filters')}
                >
                    <Filter className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                    {isAnyFilterActive ? (
                        <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-light-primary dark:bg-dark-primary ring-2 ring-light-background dark:ring-dark-background" />
                    ): null}
                </button>
            </div>

            {isFilterPanelOpen && (
                <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-4 animate-in fade-in-0 duration-200">
                    <div className="relative">
                        <input
                            type="text"
                            placeholder={t('search_by_category_note')}
                            value={localSearchTerm}
                            onChange={(e) => setLocalSearchTerm(e.target.value)}
                            className="w-full p-2 ps-10 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary outline-none"
                        />
                        <div className="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
                             <Search className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                        </div>
                    </div>
                    
                    <div>
                         <p className="text-sm font-semibold text-light-on-surface-secondary dark:text-dark-on-surface-secondary mb-2">{t('by_date')}</p>
                         <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                            <FilterButton label={t('all')} isActive={filters.dateOption === 'all'} onClick={() => handleFilterChange('dateOption', 'all')} />
                            <FilterButton label={t('thisMonth')} isActive={filters.dateOption === 'thisMonth'} onClick={() => handleFilterChange('dateOption', 'thisMonth')} />
                            <FilterButton label={t('lastMonth')} isActive={filters.dateOption === 'lastMonth'} onClick={() => handleFilterChange('dateOption', 'lastMonth')} />
                             <FilterButton label={t('custom_range')} isActive={filters.dateOption === 'custom'} onClick={() => handleFilterChange('dateOption', 'custom')} />
                         </div>
                         {filters.dateOption === 'custom' && (
                             <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-3">
                                <div>
                                    <label className="block text-xs font-medium mb-1">{t('startDate')}</label>
                                    <DatePicker value={filters.startDate} onChange={(v) => handleFilterChange('startDate', v)} required />
                                </div>
                                <div>
                                    <label className="block text-xs font-medium mb-1">{t('endDate')}</label>
                                    <DatePicker value={filters.endDate} onChange={(v) => handleFilterChange('endDate', v)} required />
                                </div>
                            </div>
                         )}
                    </div>
                    
                    <div>
                         <p className="text-sm font-semibold text-light-on-surface-secondary dark:text-dark-on-surface-secondary mb-2">{t('by_type')}</p>
                         <div className="grid grid-cols-3 gap-2">
                            <FilterButton label={t('all')} isActive={filters.type === 'all'} onClick={() => handleFilterChange('type', 'all')} />
                            <FilterButton label={t('income')} isActive={filters.type === 'income'} onClick={() => handleFilterChange('type', 'income')} />
                            <FilterButton label={t('expense')} isActive={filters.type === 'expense'} onClick={() => handleFilterChange('type', 'expense')} />
                         </div>
                    </div>
                     <div className="flex justify-end pt-2">
                        <button onClick={resetFilters} className="text-sm font-semibold text-light-primary dark:text-dark-primary hover:underline">{t('reset')}</button>
                     </div>
                </div>
            )}


            <div className="grid grid-cols-3 gap-2 text-center">
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-3 rounded-lg">
                    <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary truncate">{t('totalIncome')}</p>
                    <p className="text-xl font-bold text-brand-green">{formatCurrency(totalIncome)}</p>
                </div>
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-3 rounded-lg">
                    <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary truncate">{t('totalExpense')}</p>
                    <p className="text-xl font-bold text-brand-red">{formatCurrency(totalExpense)}</p>
                </div>
                <div className="bg-light-surface dark:bg-dark-surface ring-1 ring-black/5 dark:ring-white/10 p-3 rounded-lg">
                    <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary truncate">{t('netFlow')}</p>
                    <p className={`text-xl font-bold ${netFlow >= 0 ? 'text-light-primary dark:text-dark-primary' : 'text-orange-500'}`}>{formatCurrency(netFlow)}</p>
                </div>
            </div>

            <div ref={parentRef} className="overflow-auto h-[calc(100vh-340px)]">
                {allCashTransactions.length === 0 ? (
                     <EmptyState
                        Icon={Archive}
                        title={t('cashbook_empty_title')}
                        message={t('cashbook_empty_message')}
                    />
                ) : filteredCashTransactions.length === 0 ? (
                     <EmptyState
                        Icon={Filter}
                        title={t('filter_no_results_title')}
                        message={t('filter_no_results_message')}
                    />
                ) : (
                    <div style={{ height: `${rowVirtualizer.getTotalSize()}px`, width: '100%', position: 'relative' }}>
                        {rowVirtualizer.getVirtualItems().map(virtualItem => {
                            const transaction = filteredCashTransactions[virtualItem.index];
                            return (
                                <div
                                    key={virtualItem.key}
                                    style={{
                                        position: 'absolute',
                                        top: 0,
                                        left: 0,
                                        width: '100%',
                                        transform: `translateY(${virtualItem.start}px)`,
                                        paddingBottom: '0.75rem',
                                    }}
                                >
                                    <TransactionListItem transaction={transaction} onEdit={() => handleOpenForm(transaction)} onDelete={() => setDeletingTransactionId(transaction.id)} />
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>

            <button onClick={() => handleOpenForm(null)} className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110">
                <Plus className="w-6 h-6" />
            </button>
            
            <Modal isOpen={isFormOpen} onClose={handleCloseForm} title={editingTransaction ? t('editEntry') : t('addEntry')}>
                <CashTransactionForm entry={editingTransaction} onSave={handleSaveTransaction} onCancel={handleCloseForm} />
            </Modal>
            
            <Modal isOpen={!!deletingTransactionId} onClose={() => setDeletingTransactionId(null)} title={t('confirmDeletion')}>
                 <div className="p-4 space-y-4">
                    <p>{t('areYouSureDelete')}</p>
                    <div className="flex justify-end gap-2">
                        <button onClick={() => setDeletingTransactionId(null)} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                        <button onClick={handleDeleteConfirm} className="px-4 py-2 rounded-lg font-semibold bg-brand-red text-white hover:bg-red-600">{t('delete')}</button>
                    </div>
                </div>
            </Modal>
        </div>
    );
};

export default CashbookScreen;