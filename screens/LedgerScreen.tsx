import React, { useState, useMemo, useEffect, useRef } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import type { Person, LedgerEntry } from '../types';
import { PersonRole, LedgerEntryType } from '../types';
import { Search, UserPlus, MoreVertical, Edit, Trash2, ArrowLeft, Plus } from 'lucide-react';
import Modal from '../components/Modal';
import DatePicker from '../components/DatePicker';

const PersonListItem: React.FC<{ person: Person, balance: number, onClick: () => void }> = ({ person, balance, onClick }) => {
    const { t, formatCurrency } = useLocalization();
    
    const isCredit = (person.role === PersonRole.CUSTOMER && balance < 0) || (person.role === PersonRole.SUPPLIER && balance > 0);
    const balanceAmount = Math.abs(balance);
    const balanceColor = balance === 0 ? 'text-light-on-surface-secondary dark:text-dark-on-surface-secondary' : isCredit ? 'text-brand-green' : 'text-brand-red';
    
    let balanceLabel = '';
    if (balance !== 0) {
        if (person.role === PersonRole.CUSTOMER) {
            balanceLabel = balance > 0 ? t('theyOwe') : t('youOwe');
        } else { // Supplier
            balanceLabel = balance > 0 ? t('youOwe') : t('theyOwe');
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

const LedgerEntryListItem: React.FC<{ entry: LedgerEntry, onEdit: (entry: LedgerEntry) => void, onDelete: (id: string) => void }> = ({ entry, onEdit, onDelete }) => {
    const { t, formatCurrency, formatDate } = useLocalization();
    const [menuOpen, setMenuOpen] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);

    const isDebt = entry.type === LedgerEntryType.DEBT;
    const amountColor = isDebt ? 'text-brand-red' : 'text-brand-green';

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
                <p className={`font-bold text-lg ${amountColor}`}>{formatCurrency(entry.amount)}</p>
                <p className="text-sm text-light-on-surface dark:text-dark-on-surface font-semibold">{t(entry.type)} - {formatDate(entry.date)}</p>
                {entry.note && <p className="text-xs text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{entry.note}</p>}
            </div>
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
    );
}

const LedgerScreen: React.FC = () => {
    const { t } = useLocalization();
    const { persons, ledgerEntries, addPerson, addLedgerEntry, updateLedgerEntry, deleteLedgerEntry, getPersonBalance } = useData();
    
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedPersonId, setSelectedPersonId] = useState<string | null>(null);
    
    const [isAddEntryModalOpen, setIsAddEntryModalOpen] = useState(false);
    const [editingEntry, setEditingEntry] = useState<LedgerEntry | null>(null);
    const [deletingEntryId, setDeletingEntryId] = useState<string | null>(null);
    const [isAddPersonModalOpen, setIsAddPersonModalOpen] = useState(false);

    const personBalances = useMemo(() => {
        return persons.map(person => ({
            person,
            balance: getPersonBalance(person.id)
        }));
    }, [persons, getPersonBalance]);

    const filteredPersons = useMemo(() => {
        return personBalances.filter(({ person }) =>
            person.name.toLowerCase().includes(searchTerm.toLowerCase())
        );
    }, [personBalances, searchTerm]);

    const handleSaveEntry = (entryData: Omit<LedgerEntry, 'id' | 'personId'>) => {
        if (editingEntry) { // Editing existing entry
            updateLedgerEntry(editingEntry.id, entryData);
        } else { // Adding new entry from detail screen
            addLedgerEntry({ ...entryData, personId: selectedPersonId! });
        }
        setEditingEntry(null);
        setIsAddEntryModalOpen(false);
    };
    
    const handleDeleteConfirm = () => {
        if (deletingEntryId) {
            deleteLedgerEntry(deletingEntryId);
            setDeletingEntryId(null);
        }
    };
    
    const selectedPerson = useMemo(() => {
        if (!selectedPersonId) return null;
        return personBalances.find(({ person }) => person.id === selectedPersonId);
    }, [selectedPersonId, personBalances]);
    
    if (selectedPerson) {
        const personEntries = ledgerEntries.filter(e => e.personId === selectedPerson.person.id).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

        return (
            <div className="space-y-4">
                <div className="flex items-center gap-4">
                    <button onClick={() => setSelectedPersonId(null)} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5"><ArrowLeft/></button>
                    <div>
                        <h1 className="text-xl font-bold text-light-on-surface dark:text-dark-on-surface">{selectedPerson.person.name}</h1>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('ledgerOf')} {t(selectedPerson.person.role)}</p>
                    </div>
                </div>
                <div className="space-y-3">
                    {personEntries.map(entry => (
                        <LedgerEntryListItem key={entry.id} entry={entry} onEdit={setEditingEntry} onDelete={setDeletingEntryId} />
                    ))}
                     {personEntries.length === 0 && (
                        <p className="text-center text-light-on-surface-secondary dark:text-dark-on-surface-secondary pt-8">{t('No entries yet.')}</p>
                     )}
                </div>
                
                <button 
                    onClick={() => setIsAddEntryModalOpen(true)}
                    className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110"
                    aria-label={t('addEntry')}
                >
                    <Plus className="w-6 h-6" />
                </button>
                
                 <Modal isOpen={isAddEntryModalOpen || !!editingEntry} onClose={() => { setIsAddEntryModalOpen(false); setEditingEntry(null); }} title={editingEntry ? t('editEntry') : t('addEntry')}>
                    <LedgerEntryForm entry={editingEntry} onSave={handleSaveEntry} onCancel={() => { setIsAddEntryModalOpen(false); setEditingEntry(null); }} />
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
        )
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
            <div className="space-y-3">
                {filteredPersons.map(({ person, balance }) => (
                    <PersonListItem key={person.id} person={person} balance={balance} onClick={() => setSelectedPersonId(person.id)} />
                ))}
            </div>
            <button 
                onClick={() => setIsAddPersonModalOpen(true)}
                className="fixed bottom-24 end-4 bg-light-primary dark:bg-dark-primary hover:opacity-90 text-white dark:text-dark-background rounded-full p-4 shadow-lg z-10 transition-transform hover:scale-110"
                aria-label={t('addCustomerOrSupplier')}
            >
                <UserPlus className="w-6 h-6" />
            </button>
            <Modal isOpen={isAddPersonModalOpen} onClose={() => setIsAddPersonModalOpen(false)} title={t('addPerson')}>
                <AddPersonForm onSave={addPerson} onCancel={() => setIsAddPersonModalOpen(false)} />
            </Modal>
        </div>
    );
};

interface LedgerEntryFormProps {
    entry: LedgerEntry | null;
    onSave: (entryData: Omit<LedgerEntry, 'id' | 'personId'>) => void;
    onCancel: () => void;
}
const LedgerEntryForm: React.FC<LedgerEntryFormProps> = ({ entry, onSave, onCancel }) => {
    const { t } = useLocalization();
    const [amount, setAmount] = useState(entry?.amount || '');
    const [date, setDate] = useState(entry ? new Date(entry.date).toISOString().split('T')[0] : new Date().toISOString().split('T')[0]);
    const [type, setType] = useState(entry?.type || LedgerEntryType.DEBT);
    const [note, setNote] = useState(entry?.note || '');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSave({ amount: Number(amount), date: new Date(date).toISOString(), type, note });
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label className="block text-sm font-medium mb-1">{t('type')}</label>
                <select value={type} onChange={e => setType(e.target.value as LedgerEntryType)} className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                    <option value={LedgerEntryType.DEBT}>{t('debt')}</option>
                    <option value={LedgerEntryType.PAYMENT}>{t('payment')}</option>
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

interface AddPersonFormProps {
    onSave: (personData: Omit<Person, 'id' | 'createdAt'>) => void;
    onCancel: () => void;
}

const AddPersonForm: React.FC<AddPersonFormProps> = ({ onSave, onCancel }) => {
    const { t } = useLocalization();
    const [name, setName] = useState('');
    const [phone, setPhone] = useState('');
    const [role, setRole] = useState<PersonRole>(PersonRole.CUSTOMER);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (name.trim() === '') return;
        onSave({ name, phone: phone || null, role });
        onCancel();
    };

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label htmlFor="person-name" className="block text-sm font-medium mb-1">{t('personName')}</label>
                <input 
                    id="person-name"
                    type="text" 
                    value={name} 
                    onChange={e => setName(e.target.value)} 
                    required 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary" 
                    placeholder={t('personName')}
                />
            </div>
            <div>
                <label htmlFor="person-phone" className="block text-sm font-medium mb-1">{t('phoneOptional')}</label>
                <input 
                    id="person-phone"
                    type="tel" 
                    value={phone} 
                    onChange={e => setPhone(e.target.value)} 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary" 
                    placeholder="05..."
                />
            </div>
             <div>
                <label htmlFor="person-role" className="block text-sm font-medium mb-1">{t('role')}</label>
                <select 
                    id="person-role"
                    value={role} 
                    onChange={e => setRole(e.target.value as PersonRole)} 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary"
                >
                    <option value={PersonRole.CUSTOMER}>{t('customer')}</option>
                    <option value={PersonRole.SUPPLIER}>{t('supplier')}</option>
                </select>
            </div>
            <div className="flex justify-end gap-2 pt-2">
                <button type="button" onClick={onCancel} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                <button type="submit" className="px-4 py-2 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('save')}</button>
            </div>
        </form>
    );
};


export default LedgerScreen;