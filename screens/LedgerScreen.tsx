import React, { useState, useMemo, useEffect, useRef } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import { useToast } from '../context/ToastContext';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db';
import type { Person, Transaction } from '../types';
import { PersonRole, TransactionType } from '../types';
import { Search, UserPlus, MoreVertical, Edit, Trash2, ArrowLeft, Plus, Share2, Users, Filter } from 'lucide-react';
import Modal from '../components/Modal';
import DatePicker from '../components/DatePicker';
import AddPersonForm from '../components/AddPersonForm';
import EmptyState from '../components/EmptyState';
import useDebounce from '../hooks/useDebounce';
import { useVirtualizer } from '@tanstack/react-virtual';
import { calculatePersonBalance } from '../utils/calculations';
import { generatePersonStatementText } from '../utils/reporting';
import { nativeShare } from '../utils/native';

const PersonListItem: React.FC<{ person: Person, balance: number, onClick: () => void }> = ({ person, balance, onClick }) => {
    const { t, formatCurrency } = useLocalization();
    
    const isAsset = (person.role === PersonRole.CUSTOMER && balance > 0) || (person.role === PersonRole.SUPPLIER && balance < 0);
    const balanceAmount = Math.abs(balance);
    const balanceColor = balance === 0 ? 'text-light-on-surface-secondary dark:text-dark-on-surface-secondary' : isAsset ? 'text-brand-green' : 'text-brand-red';
    
    let balanceLabel = '';
    if (balance !== 0) {
        if (person.role === PersonRole.CUSTOMER) {
            balanceLabel = balance > 0 ? t('receivable') : t('creditBalance');
        } else { // Supplier
            balanceLabel = balance > 0 ? t('payable') : t('creditBalance');
        }
    }


    return (
        <button onClick={onClick} className="w-full text-start bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 flex items-center justify-between transition-all hover:shadow-md hover:ring-1 hover:ring-light-primary dark:hover:ring-dark-primary ring-1 ring-black/5 dark:ring-white/10">
            <div>
                <p className="font-bold text-lg text-light-on-surface dark:text-dark-on-surface">{person.name}</p>
                <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t(person.role)}</p>
            </div>
            <div className="text-end">
                <p className={`font-bold text-xl ${balanceColor}`}>{formatCurrency(balanceAmount)}</p>
                {balance !== 0 && <p className={`text-xs ${balanceColor}`}>{balanceLabel}</p>}
            </div>
        </button>
    );
};

// --- Correct replacement for LedgerScreen.tsx ---
interface TransactionListItemProps {
    transaction: Transaction;
    runningBalance: number;
    onEdit: (transaction: Transaction) => void;
    onDelete: (id: string) => void;
    isMenuOpen: boolean;
    onToggleMenu: () => void;
}
const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, runningBalance, onEdit, onDelete, isMenuOpen, onToggleMenu }) => {
    const { t, formatCurrency, formatDate } = useLocalization();
    const menuRef = useRef<HTMLDivElement>(null);

    const debitTypes = [TransactionType.SALE_ON_CREDIT, TransactionType.PURCHASE_ON_CREDIT];
    const isDebit = debitTypes.includes(transaction.type);
    const amountColor = isDebit ? 'text-brand-red' : 'text-brand-green';

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
                onToggleMenu();
            }
        };
        if (isMenuOpen) {
            document.addEventListener("mousedown", handleClickOutside);
        }
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, [isMenuOpen, onToggleMenu]);

    return (
        <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-3 flex items-center justify-between ring-1 ring-black/5 dark:ring-white/10">
            <div>
                <p className={`font-bold text-lg ${amountColor}`}>{formatCurrency(transaction.amount)}</p>
                <p className="text-sm text-light-on-surface dark:text-dark-on-surface font-semibold">{t(transaction.type)} - {formatDate(transaction.date)}</p>
                {transaction.note && <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary mt-1">{transaction.note}</p>}
                <p className="text-xs font-mono pt-1 text-light-on-surface-secondary/70 dark:text-dark-on-surface-secondary/70">
                    {t('balance')}: {formatCurrency(runningBalance)}
                </p>
            </div>
            <div className="relative">
                <button onClick={onToggleMenu} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5" aria-label={t('transaction_options')}>
                    <MoreVertical className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary"/>
                </button>
                {isMenuOpen && (
                    <div ref={menuRef} className="absolute top-full end-0 mt-1 w-40 bg-light-surface dark:bg-dark-surface rounded-md shadow-lg ring-1 ring-black/5 dark:ring-white/10 z-20">
                        <button onClick={() => { onEdit(transaction); onToggleMenu(); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm hover:bg-black/5 dark:hover:bg-white/5"><Edit className="w-4 h-4" /> {t('edit')}</button>
                        <button onClick={() => { onDelete(transaction.id); onToggleMenu(); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm text-brand-red hover:bg-black/5 dark:hover:bg-white/5"><Trash2 className="w-4 h-4" /> {t('delete')}</button>
                    </div>
                )}
            </div>
        </div>
    );
}

const FilterButton: React.FC<{ label: string; isActive: boolean; onClick: () => void; }> = ({ label, isActive, onClick }) => (
    <button
        onClick={onClick}
        className={`w-full py-2 px-3 rounded-lg text-sm font-semibold transition-colors ${
            isActive
                ? 'bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background shadow'
                : 'bg-light-surface dark:bg-dark-surface hover:bg-black/5 dark:hover:bg-white/5 ring-1 ring-inset ring-black/10 dark:ring-white/10'
        }`}
    >
        {label}
    </button>
);

interface LedgerScreenProps {
    selectedPersonId: string | null;
    setSelectedPersonId: (id: string | null) => void;
    setHeaderTitle: (title: string) => void; 
}

const LedgerScreen: React.FC<LedgerScreenProps> = ({ selectedPersonId, setSelectedPersonId, setHeaderTitle }) => {
    
    const { t } = useLocalization();
    const { addPerson } = useData();
    const { showToast } = useToast();

    const persons = useLiveQuery(() => db.persons.toArray(), []) || [];
    const transactions = useLiveQuery(() => db.transactions.toArray(), []) || [];
    
    const [searchTerm, setSearchTerm] = useState('');
    const debouncedSearchTerm = useDebounce(searchTerm, 300);
    const [activeFilter, setActiveFilter] = useState<'all' | 'customers' | 'suppliers' | 'overdue'>('all');
    
    const [isAddPersonModalOpen, setIsAddPersonModalOpen] = useState(false);

    const personBalances = useMemo(() => {
        return persons.map(person => ({
            person,
            balance: calculatePersonBalance(person, transactions)
        }));
    }, [persons, transactions]);

    const filteredPersons = useMemo(() => {
        let filtered = personBalances;

        if (activeFilter !== 'all') {
            filtered = personBalances.filter(p => {
                switch (activeFilter) {
                    case 'customers':
                        return p.person.role === PersonRole.CUSTOMER;
                    case 'suppliers':
                        return p.person.role === PersonRole.SUPPLIER;
                    case 'overdue':
                        const now = new Date();
                        return p.person.role === PersonRole.CUSTOMER && p.balance > 0 && transactions.some(
                            tx => tx.personId === p.person.id &&
                                  tx.type === TransactionType.SALE_ON_CREDIT &&
                                  tx.dueDate && new Date(tx.dueDate) < now
                        );
                    default:
                        return true;
                }
            });
        }

        if (!debouncedSearchTerm) return filtered;
        return filtered.filter(({ person }) =>
            person.name.toLowerCase().includes(debouncedSearchTerm.toLowerCase())
        );
    }, [personBalances, debouncedSearchTerm, activeFilter, transactions]);
    
    const handleSavePerson = (data: Omit<Person, 'id' | 'createdAt'>) => {
        addPerson(data);
        setIsAddPersonModalOpen(false);
        showToast(t('toast_person_added'), 'success');
    };
    // Add this block inside the LedgerScreen component
useEffect(() => {
    const person = persons.find(p => p.id === selectedPersonId);
    if (person) {
        setHeaderTitle(`${t('ledgerOf')} ${person.name}`);
    } else {
        setHeaderTitle(t('customersAndSuppliers'));
    }
}, [selectedPersonId, persons, setHeaderTitle, t]);
    
    // Virtualization for main list
    const parentRef = useRef<HTMLDivElement>(null);
    const rowVirtualizer = useVirtualizer({
        count: filteredPersons.length,
        getScrollElement: () => parentRef.current,
        estimateSize: () => 92, // Estimate height of PersonListItem
        overscan: 5,
    });

    const selectedPerson = useMemo(() => {
        if (!selectedPersonId) return null;
        return personBalances.find(({ person }) => person.id === selectedPersonId);
    }, [selectedPersonId, personBalances]);
    
    if (selectedPerson) {
        return <PersonDetailView person={selectedPerson.person} balance={selectedPerson.balance} onBack={() => setSelectedPersonId(null)} />;
    }

    return (
        <div className="space-y-4">
           
            <div className="relative">
                 <input
                    type="text"
                    placeholder={t('searchByName')}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full p-2 ps-10 border border-black/10 dark:border-white/10 rounded-lg bg-light-surface dark:bg-dark-surface focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary outline-none"
                />
                <div className="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
                     <Search className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                </div>
            </div>

            <div>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                    <FilterButton label={t('all')} isActive={activeFilter === 'all'} onClick={() => setActiveFilter('all')} />
                    <FilterButton label={t('customers')} isActive={activeFilter === 'customers'} onClick={() => setActiveFilter('customers')} />
                    <FilterButton label={t('suppliers')} isActive={activeFilter === 'suppliers'} onClick={() => setActiveFilter('suppliers')} />
                    <FilterButton label={t('overdue_balances')} isActive={activeFilter === 'overdue'} onClick={() => setActiveFilter('overdue')} />
                </div>
            </div>
            
             <div ref={parentRef} className="flex-1 overflow-auto">
                {persons.length === 0 ? (
                     <EmptyState
                        Icon={Users}
                        title={t('ledger_empty_title')}
                        message={t('ledger_empty_message')}
                    />
                ) : filteredPersons.length === 0 ? (
                    <EmptyState
                        Icon={Filter}
                        title={t('filter_no_results_title')}
                        message={t('filter_no_results_message')}
                    />
                ) : (
                    <div style={{ height: `${rowVirtualizer.getTotalSize()}px`, width: '100%', position: 'relative' }}>
                        {rowVirtualizer.getVirtualItems().map(virtualItem => {
                            const { person, balance } = filteredPersons[virtualItem.index];
                            return (
                                <div
                                    key={virtualItem.key}
                                    style={{
                                        position: 'absolute',
                                        top: 0,
                                        left: 0,
                                        width: '100%',
                                        transform: `translateY(${virtualItem.start}px)`,
                                        paddingBottom: '0.75rem', /* Add spacing between items */
                                    }}
                                >
                                    <PersonListItem person={person} balance={balance} onClick={() => setSelectedPersonId(person.id)} />
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
            
            <button 
                onClick={() => setIsAddPersonModalOpen(true)}
                className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110"
                aria-label={t('addCustomerOrSupplier')}
            >
                <UserPlus className="w-6 h-6" />
            </button>
            <Modal isOpen={isAddPersonModalOpen} onClose={() => setIsAddPersonModalOpen(false)} title={t('addPerson')}>
                <AddPersonForm onSave={handleSavePerson} onCancel={() => setIsAddPersonModalOpen(false)} />
            </Modal>
        </div>
    );
};

// --- Person Detail View ---
interface PersonDetailViewProps {
    person: Person;
    balance: number;
    onBack: () => void;
}
const PersonDetailView: React.FC<PersonDetailViewProps> = ({ person, balance, onBack }) => {
    const [openMenuId, setOpenMenuId] = useState<string | null>(null);
    const { t, formatCurrency, formatDate } = useLocalization();
    const { addTransaction, updateTransaction, deleteTransaction } = useData();
    const { showToast } = useToast();
    
    const personTransactions = useLiveQuery(() => 
        db.transactions.where('personId').equals(person.id).toArray(), 
        [person.id]
    ) || [];

    const [editingTransaction, setEditingTransaction] = useState<Transaction | null>(null);
    const [deletingTransactionId, setDeletingTransactionId] = useState<string | null>(null);
    const [isAddTransactionModalOpen, setIsAddTransactionModalOpen] = useState(false);

    const personTransactionsWithBalance = useMemo(() => {
        const sortedTransactions = [...personTransactions].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

        let runningBalance = 0;
        const transactionsWithBalance = sortedTransactions.map(transaction => {
            if (person.role === PersonRole.CUSTOMER) {
                if (transaction.type === TransactionType.SALE_ON_CREDIT) runningBalance += transaction.amount;
                else if (transaction.type === TransactionType.PAYMENT_RECEIVED) runningBalance -= transaction.amount;
            } else { // Supplier
                if (transaction.type === TransactionType.PURCHASE_ON_CREDIT) runningBalance += transaction.amount;
                else if (transaction.type === TransactionType.PAYMENT_MADE) runningBalance -= transaction.amount;
            }
            return { ...transaction, runningBalance };
        });

        return transactionsWithBalance.reverse(); // Newest first for display
    }, [personTransactions, person.role]);
    
    const parentRef = useRef<HTMLDivElement>(null);
    const txVirtualizer = useVirtualizer({
        count: personTransactionsWithBalance.length,
        getScrollElement: () => parentRef.current,
        estimateSize: () => 100, // Estimate height of TransactionListItem
        overscan: 5,
    });
    
     const handleSaveTransaction = (transactionData: Omit<Transaction, 'id'>) => {
        if (editingTransaction) {
            updateTransaction(editingTransaction.id, transactionData);
        } else {
            addTransaction(transactionData);
        }
        setEditingTransaction(null);
        setIsAddTransactionModalOpen(false);
        showToast(t('toast_saved_successfully'), 'success');
    };
    
    const handleDeleteConfirm = () => {
        if (deletingTransactionId) {
            deleteTransaction(deletingTransactionId);
            setDeletingTransactionId(null);
            showToast(t('toast_deleted_successfully'), 'success');
        }
    };
       

    // 2. Direct WhatsApp Link (Works on all Androids without special permissions)
    const handleWhatsApp = () => {
        const statementText = generatePersonStatementText({
            person,
            transactionsInDateRange: personTransactions, 
            balanceBroughtForward: 0,
            t, formatDate, formatCurrency
        });
        
        // Encode the text properly for a URL
        const url = `https://wa.me/?text=${encodeURIComponent(statementText)}`;
        
        // Open in new window (triggers WhatsApp app)
        window.open(url, '_blank');
    };

    const isAsset = (person.role === PersonRole.CUSTOMER && balance > 0) || (person.role === PersonRole.SUPPLIER && balance < 0);
    const balanceAmount = Math.abs(balance);
    const balanceColor = balance === 0 ? 'text-light-on-surface-secondary dark:text-dark-on-surface-secondary' : isAsset ? 'text-brand-green' : 'text-brand-red';
    let balanceLabel = balance === 0 ? t('balance') : person.role === PersonRole.CUSTOMER ? (balance > 0 ? t('receivable') : t('creditBalance')) : (balance > 0 ? t('payable') : t('creditBalance'));

    return (
        <div className="space-y-4">
            <div className="flex items-start justify-between">
                <div className="mb-4"> {/* We keep a div for spacing */}
    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('ledgerOf')} {t(person.role)}</p>
</div>
                 <div className="flex items-center gap-2">
                    {/* WhatsApp Button */}
{/* Green Share Icon Button (Triggers WhatsApp) */}
    <button 
        onClick={handleWhatsApp} 
        className="p-2 rounded-full text-brand-green bg-brand-green/10 hover:bg-brand-green/20 transition-colors" 
        aria-label={t('share')}
    >
        <Share2 className="w-5 h-5" />
    </button>
                    <div className="text-end flex-shrink-0">
                        <p className={`font-bold text-2xl ${balanceColor}`}>{formatCurrency(balanceAmount)}</p>
                        <p className={`text-sm font-semibold ${balanceColor}`}>{balanceLabel}</p>
                    </div>
                </div>
            </div>

            <div ref={parentRef} className="overflow-auto h-[calc(100vh-250px)]">
                 {personTransactionsWithBalance.length === 0 ? (
                    <p className="text-center text-light-on-surface-secondary dark:text-dark-on-surface-secondary pt-8">{t('noEntriesYet')}</p>
                 ) : (
                     <div style={{ height: `${txVirtualizer.getTotalSize()}px`, width: '100%', position: 'relative' }}>
                        {txVirtualizer.getVirtualItems().map(virtualItem => {
    const txWithBalance = personTransactionsWithBalance[virtualItem.index];
    
    // --- START: Added Logic ---
    const isMenuOpen = openMenuId === txWithBalance.id;
    const handleToggleMenu = () => {
        setOpenMenuId(isMenuOpen ? null : txWithBalance.id);
    };
    // --- END: Added Logic ---

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
                zIndex: isMenuOpen ? 10 : 1, // <-- THE FIX IS HERE
            }}
        >
            <TransactionListItem 
                transaction={txWithBalance} 
                runningBalance={txWithBalance.runningBalance}
                onEdit={setEditingTransaction} 
                onDelete={setDeletingTransactionId}
                // --- Pass the new props down ---
                isMenuOpen={isMenuOpen}
                onToggleMenu={handleToggleMenu}
            />
        </div>
    )
})}
                     </div>
                 )}
            </div>
            
            <button 
                onClick={() => setIsAddTransactionModalOpen(true)}
                className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110"
                aria-label={t('addEntry')}
            >
                <Plus className="w-6 h-6" />
            </button>
            
             <Modal isOpen={isAddTransactionModalOpen || !!editingTransaction} onClose={() => { setIsAddTransactionModalOpen(false); setEditingTransaction(null); }} title={editingTransaction ? t('editEntry') : t('addEntry')}>
                <PersonTransactionForm transaction={editingTransaction} person={person} onSave={handleSaveTransaction} onCancel={() => { setIsAddTransactionModalOpen(false); setEditingTransaction(null); }} />
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

// --- Transaction Form ---
interface PersonTransactionFormProps {
    transaction: Transaction | null;
    person: Person;
    onSave: (transactionData: Omit<Transaction, 'id'>) => void;
    onCancel: () => void;
}
const PersonTransactionForm: React.FC<PersonTransactionFormProps> = ({ transaction, person, onSave, onCancel }) => {
    const { t, getTodayDateString } = useLocalization();
    
    const getDefaultType = () => {
        if (transaction) return transaction.type;
        return person.role === PersonRole.CUSTOMER ? TransactionType.SALE_ON_CREDIT : TransactionType.PURCHASE_ON_CREDIT;
    };

    const [amount, setAmount] = useState(transaction?.amount || '');
    const [date, setDate] = useState(transaction ? new Date(transaction.date).toISOString().split('T')[0] : getTodayDateString());
    const [type, setType] = useState(getDefaultType());
    const [note, setNote] = useState(transaction?.note || '');
    const [dueDate, setDueDate] = useState(transaction?.dueDate ? new Date(transaction.dueDate).toISOString().split('T')[0] : '');
    const [amountError, setAmountError] = useState('');

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
        if (validate()) {
            const dateToSave = new Date(`${date}T12:00:00Z`).toISOString();
            const dueDateToSave = dueDate ? new Date(`${dueDate}T12:00:00Z`).toISOString() : undefined;
            onSave({ amount: Number(amount), date: dateToSave, type, note, personId: person.id, dueDate: dueDateToSave });
        }
    }
    
    const isCreditType = type === TransactionType.SALE_ON_CREDIT || type === TransactionType.PURCHASE_ON_CREDIT;

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label htmlFor="cash-entry-type" className="block text-sm font-medium mb-1">{t('type')}</label>
                <select id="cash-entry-type" value={type} onChange={e => setType(e.target.value as TransactionType)} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                    {person.role === PersonRole.CUSTOMER ? (
                        <>
                            <option value={TransactionType.SALE_ON_CREDIT}>{t('sale_on_credit')}</option>
                            <option value={TransactionType.PAYMENT_RECEIVED}>{t('payment_received')}</option>
                        </>
                    ) : (
                        <>
                            <option value={TransactionType.PURCHASE_ON_CREDIT}>{t('purchase_on_credit')}</option>
                            <option value={TransactionType.PAYMENT_MADE}>{t('payment_made')}</option>
                        </>
                    )}
                </select>
            </div>
            <div>
                <label htmlFor="ledger-entry-amount" className="block text-sm font-medium mb-1">{t('amount')}</label>
                <input id="ledger-entry-amount" 
                    type="number" 
                    step="any" 
                    value={amount} 
                    onChange={e => { setAmount(e.target.value); if(amountError) setAmountError(''); }} 
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
                <label htmlFor="transaction-date" className="block text-sm font-medium mb-1">{t('date')}</label>
                <DatePicker id="transaction-date" value={date} onChange={setDate} required />
            </div>
            {isCreditType && (
                <div>
                    <label htmlFor="transaction-due-date" className="block text-sm font-medium mb-1">{t('dueDate')} ({t('note')})</label>
                    <DatePicker id="transaction-due-date" value={dueDate} onChange={setDueDate} />
                </div>
            )}
            <div>
                <label htmlFor="ledger-entry-note" className="block text-sm font-medium mb-1">{t('note')}</label>
                <textarea id="ledger-entry-note" value={note} onChange={e => setNote(e.target.value)} rows={2} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none" />
            </div>
            <div className="flex justify-end gap-2 pt-2">
                <button type="button" onClick={onCancel} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                <button type="submit" className="px-4 py-2 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('save')}</button>
            </div>
        </form>
    );
};

export default LedgerScreen;
