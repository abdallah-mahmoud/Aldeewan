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

interface TransactionListItemProps {
    transaction: Transaction;
    runningBalance: number;
    onEdit: (transaction: Transaction) => void;
    onDelete: (id: string) => void;
}
const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, runningBalance, onEdit, onDelete }) => {
    const { t, formatCurrency, formatDate } = useLocalization();
    const [menuOpen, setMenuOpen] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);

    const debitTypes = [TransactionType.SALE_ON_CREDIT, TransactionType.PURCHASE_ON_CREDIT];
    const isDebit = debitTypes.includes(transaction.type);
    const amountColor = isDebit ? 'text-brand-red' : 'text-brand-green';

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
            <div>
                <p className={`font-bold text-lg ${amountColor}`}>{formatCurrency(transaction.amount)}</p>
                <p className="text-sm text-light-on-surface dark:text-dark-on-surface font-semibold">{t(transaction.type)} - {formatDate(transaction.date)}</p>
                {transaction.note && <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary mt-1">{transaction.note}</p>}
                <p className="text-xs font-mono pt-1 text-light-on-surface-secondary/70 dark:text-dark-on-surface-secondary/70">
                    {t('balance')}: {formatCurrency(runningBalance)}
                </p>
            </div>
            <div className="relative">
                <button onClick={() => setMenuOpen(p => !p)} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5">
                    <MoreVertical className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary"/>
                </button>
                {menuOpen && (
                    <div ref={menuRef} className="absolute top-full end-0 mt-1 w-40 bg-light-surface dark:bg-dark-surface rounded-md shadow-lg ring-1 ring-black/5 dark:ring-white/10 z-20">
                        <button onClick={() => { onEdit(transaction); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm hover:bg-black/5 dark:hover:bg-white/5"><Edit className="w-4 h-4" /> {t('edit')}</button>
                        <button onClick={() => { onDelete(transaction.id); setMenuOpen(false); }} className="w-full text-start flex items-center gap-2 px-3 py-2 text-sm text-brand-red hover:bg-black/5 dark:hover:bg-white/5"><Trash2 className="w-4 h-4" /> {t('delete')}</button>
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
}

const LedgerScreen: React.FC<LedgerScreenProps> = ({ selectedPersonId, setSelectedPersonId }) => {
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
            <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('customersAndSuppliers')}</h1>
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
            
             <div ref={parentRef} className="overflow-auto h-[calc(100vh-320px)]">
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
    
    const handleShareStatement = async () => {
        const transactions = await db.transactions.where('personId').equals(person.id).toArray();
        
        const sortedTransactions = transactions.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        
        let runningBalance = 0;
        const transactionsWithBalance = sortedTransactions.map(transaction => {
            const debitTypes = [TransactionType.SALE_ON_CREDIT, TransactionType.PURCHASE_ON_CREDIT];
            runningBalance += debitTypes.includes(transaction.type) ? transaction.amount : -transaction.amount;
            return { ...transaction, runningBalance };
        });
    
        const header = [ t('statement_header'), `${t('statement_from')}: ${t('appName')}`, `${t('statement_to')}: ${person.name}`, `${t('statement_date')}: ${formatDate(new Date().toISOString())}` ].join('\n');
    
        let finalBalanceLabel = '';
        if (balance > 0) {
            finalBalanceLabel = person.role === PersonRole.CUSTOMER ? t('statement_final_balance_due') : t('statement_final_balance_payable');
        } else if (balance < 0) {
            finalBalanceLabel = t('statement_final_balance_credit');
        }
        
        const summary = [ `\n${t('statement_summary_header')}`, `${finalBalanceLabel}: ${formatCurrency(Math.abs(balance))}` ].join('\n');
    
        const history = transactionsWithBalance.map(tx => {
            let txTypeLabel = '';
            let amountSign = '';
    
            if (person.role === PersonRole.CUSTOMER) {
                if (tx.type === TransactionType.SALE_ON_CREDIT) {
                    txTypeLabel = t('customer_tx_debt');
                    amountSign = '+';
                } else if (tx.type === TransactionType.PAYMENT_RECEIVED) {
                    txTypeLabel = t('customer_tx_payment');
                    amountSign = '-';
                }
            } else {
                if (tx.type === TransactionType.PURCHASE_ON_CREDIT) {
                    txTypeLabel = t('supplier_tx_debt');
                    amountSign = '+';
                } else if (tx.type === TransactionType.PAYMENT_MADE) {
                    txTypeLabel = t('supplier_tx_payment');
                    amountSign = '-';
                }
            }
    
            let entry = `\n🗓️ ${formatDate(tx.date)}\n${txTypeLabel}: ${amountSign} ${formatCurrency(tx.amount)}`;
            if (tx.note) {
                entry += `\n  - ${t('statement_tx_note_prefix')}: ${tx.note}`;
            }
            entry += `\n  - ${t('statement_tx_running_balance_prefix')}: ${formatCurrency(tx.runningBalance)}`;
            
            return entry;
        }).join('\n');
    
        const historySection = `\n\n${t('statement_tx_history_header')}\n--------------------${history}\n--------------------`;
        const footer = `\n\n${t('statement_footer_thanks')}\n${t('statement_footer_generated_by')}`;
        const fullStatement = [header, summary, historySection, footer].join('\n');
    
        if (navigator.share) {
            await navigator.share({ title: `${t('appName')} - ${person.name}`, text: fullStatement });
        } else {
            await navigator.clipboard.writeText(fullStatement);
            showToast(t('toast_copied_clipboard'), 'info');
        }
    };

    const isAsset = (person.role === PersonRole.CUSTOMER && balance > 0) || (person.role === PersonRole.SUPPLIER && balance < 0);
    const balanceAmount = Math.abs(balance);
    const balanceColor = balance === 0 ? 'text-light-on-surface-secondary dark:text-dark-on-surface-secondary' : isAsset ? 'text-brand-green' : 'text-brand-red';
    let balanceLabel = balance === 0 ? t('balance') : person.role === PersonRole.CUSTOMER ? (balance > 0 ? t('receivable') : t('creditBalance')) : (balance > 0 ? t('payable') : t('creditBalance'));

    return (
        <div className="space-y-4">
            <div className="flex items-start justify-between">
                <div className="flex items-center gap-4">
                    <button onClick={onBack} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5"><ArrowLeft/></button>
                    <div>
                        <h1 className="text-xl font-bold text-light-on-surface dark:text-dark-on-surface">{person.name}</h1>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('ledgerOf')} {t(person.role)}</p>
                    </div>
                </div>
                 <div className="flex items-center gap-2">
                    <button onClick={handleShareStatement} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5" aria-label={t('share')}>
                        <Share2 className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary"/>
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
                                    <TransactionListItem 
                                        transaction={txWithBalance} 
                                        runningBalance={txWithBalance.runningBalance}
                                        onEdit={setEditingTransaction} 
                                        onDelete={setDeletingTransactionId} 
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
                <label className="block text-sm font-medium mb-1">{t('type')}</label>
                <select value={type} onChange={e => setType(e.target.value as TransactionType)} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
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
                <label className="block text-sm font-medium mb-1">{t('amount')}</label>
                <input 
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
                <label className="block text-sm font-medium mb-1">{t('date')}</label>
                <DatePicker value={date} onChange={setDate} required />
            </div>
            {isCreditType && (
                <div>
                    <label className="block text-sm font-medium mb-1">{t('dueDate')} ({t('note')})</label>
                    <DatePicker value={dueDate} onChange={setDueDate} />
                </div>
            )}
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

export default LedgerScreen;
