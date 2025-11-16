import React, { createContext, useState, useContext, useMemo, useCallback } from 'react';
import type { Person, LedgerEntry, CashEntry } from '../types';
import { PersonRole, LedgerEntryType, CashEntryType } from '../types';
import { mockPersons, mockLedgerEntries, mockCashEntries } from '../data/mockData';

interface DataContextType {
    persons: Person[];
    ledgerEntries: LedgerEntry[];
    cashEntries: CashEntry[];
    addPerson: (data: Omit<Person, 'id' | 'createdAt'>) => void;
    addLedgerEntry: (data: Omit<LedgerEntry, 'id'>) => void;
    updateLedgerEntry: (id: string, data: Partial<Omit<LedgerEntry, 'id' | 'personId'>>) => void;
    deleteLedgerEntry: (id: string) => void;
    addCashEntry: (data: Omit<CashEntry, 'id'>) => void;
    updateCashEntry: (id: string, data: Partial<Omit<CashEntry, 'id'>>) => void;
    deleteCashEntry: (id: string) => void;
    getPersonBalance: (personId: string) => number;
    homeScreenTotals: { 
        totalReceivable: number, 
        totalPayable: number,
        monthlyIncome: number,
        monthlyExpense: number,
    };
}

const DataContext = createContext<DataContextType | undefined>(undefined);

export const DataProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [persons, setPersons] = useState<Person[]>(mockPersons);
    const [ledgerEntries, setLedgerEntries] = useState<LedgerEntry[]>(mockLedgerEntries);
    const [cashEntries, setCashEntries] = useState<CashEntry[]>(mockCashEntries);

    const addPerson = useCallback((data: Omit<Person, 'id' | 'createdAt'>) => {
        const newPerson: Person = {
            ...data,
            id: `p${Date.now()}`,
            createdAt: new Date().toISOString(),
        };
        setPersons(prev => [newPerson, ...prev]);
    }, []);

    const addLedgerEntry = useCallback((data: Omit<LedgerEntry, 'id'>) => {
        const newEntry: LedgerEntry = {
            ...data,
            id: `l${Date.now()}`,
        };
        setLedgerEntries(prev => [newEntry, ...prev]);
    }, []);
    
    const updateLedgerEntry = useCallback((id: string, data: Partial<Omit<LedgerEntry, 'id' | 'personId'>>) => {
        setLedgerEntries(prev => prev.map(e => e.id === id ? { ...e, ...data } : e));
    }, []);

    const deleteLedgerEntry = useCallback((id: string) => {
        setLedgerEntries(prev => prev.filter(e => e.id !== id));
    }, []);

    const addCashEntry = useCallback((data: Omit<CashEntry, 'id'>) => {
        const newEntry: CashEntry = {
            ...data,
            id: `c${Date.now()}`,
        };
        setCashEntries(prev => [newEntry, ...prev]);
    }, []);

    const updateCashEntry = useCallback((id: string, data: Partial<Omit<CashEntry, 'id'>>) => {
        setCashEntries(prev => prev.map(e => e.id === id ? { ...e, ...data } : e));
    }, []);

    const deleteCashEntry = useCallback((id: string) => {
        setCashEntries(prev => prev.filter(e => e.id !== id));
    }, []);

    const getPersonBalance = useCallback((personId: string) => {
        return ledgerEntries
            .filter(entry => entry.personId === personId)
            .reduce((balance, entry) => {
                if (entry.type === LedgerEntryType.DEBT) {
                    return balance + entry.amount;
                } else if (entry.type === LedgerEntryType.PAYMENT) {
                    return balance - entry.amount;
                }
                return balance;
            }, 0);
    }, [ledgerEntries]);
    
    const homeScreenTotals = useMemo(() => {
        let totalReceivable = 0;
        let totalPayable = 0;

        persons.forEach(person => {
            const balance = getPersonBalance(person.id);
            if (person.role === PersonRole.CUSTOMER && balance > 0) {
                totalReceivable += balance;
            } else if (person.role === PersonRole.SUPPLIER && balance > 0) {
                totalPayable += balance;
            }
        });
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();

        let monthlyIncome = 0;
        let monthlyExpense = 0;

        cashEntries.forEach(entry => {
            const entryDate = new Date(entry.date);
            if (entryDate.getMonth() === currentMonth && entryDate.getFullYear() === currentYear) {
                if (entry.type === CashEntryType.INCOME) {
                    monthlyIncome += entry.amount;
                } else if (entry.type === CashEntryType.EXPENSE) {
                    monthlyExpense += entry.amount;
                }
            }
        });

        return { totalReceivable, totalPayable, monthlyIncome, monthlyExpense };
    }, [persons, cashEntries, getPersonBalance]);


    const value = {
        persons,
        ledgerEntries,
        cashEntries,
        addPerson,
        addLedgerEntry,
        updateLedgerEntry,
        deleteLedgerEntry,
        addCashEntry,
        updateCashEntry,
        deleteCashEntry,
        getPersonBalance,
        homeScreenTotals,
    };

    return <DataContext.Provider value={value}>{children}</DataContext.Provider>;
}

export const useData = (): DataContextType => {
    const context = useContext(DataContext);
    if (context === undefined) {
        throw new Error('useData must be used within a DataProvider');
    }
    return context;
}