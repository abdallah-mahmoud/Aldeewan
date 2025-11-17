import React, { createContext, useContext, useCallback, useEffect, useState } from 'react';
import { db } from '../db';
import type { Person, Transaction } from '../types';
import { mockPersons, mockTransactions } from '../data/mockData';

interface DataContextType {
    addPerson: (data: Omit<Person, 'id' | 'createdAt'>) => Promise<string>;
    addTransaction: (data: Omit<Transaction, 'id'>) => Promise<void>;
    updateTransaction: (id: string, data: Partial<Omit<Transaction, 'id'>>) => Promise<void>;
    deleteTransaction: (id: string) => Promise<void>;
    getTransactionsByDateRange: (startDate: string, endDate: string) => Promise<Transaction[]>;
    isAppLoading: boolean;
    needsOnboarding: boolean;
    seedDatabase: () => Promise<void>;
    completeOnboarding: () => void;
}

const DataContext = createContext<DataContextType | undefined>(undefined);

export const DataProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [isAppLoading, setIsAppLoading] = useState(true);
    const [needsOnboarding, setNeedsOnboarding] = useState(false);

    useEffect(() => {
        const checkFirstLaunch = async () => {
            try {
                const personCount = await db.persons.count();
                if (personCount === 0) {
                    setNeedsOnboarding(true);
                }
            } catch (error) {
                console.error("Failed to check database:", error);
            } finally {
                setIsAppLoading(false);
            }
        };
        checkFirstLaunch();
    }, []);

    const seedDatabase = useCallback(async () => {
        try {
            await db.transaction('rw', db.persons, db.transactions, async () => {
                await db.persons.bulkAdd(mockPersons);
                await db.transactions.bulkAdd(mockTransactions);
            });
            console.log("Database seeded with mock data.");
        } catch (error) {
            console.error("Failed to seed database:", error);
        }
    }, []);

    const completeOnboarding = useCallback(() => {
        setNeedsOnboarding(false);
    }, []);
    
    const addPerson = useCallback(async (data: Omit<Person, 'id' | 'createdAt'>): Promise<string> => {
        const newPerson: Person = {
            ...data,
            id: crypto.randomUUID(),
            createdAt: new Date().toISOString(),
        };
        await db.persons.add(newPerson);
        return newPerson.id;
    }, []);

    const addTransaction = useCallback(async (data: Omit<Transaction, 'id'>) => {
        const newTransaction: Transaction = {
            ...data,
            id: crypto.randomUUID(),
        };
        await db.transactions.add(newTransaction);
    }, []);
    
    const updateTransaction = useCallback(async (id: string, data: Partial<Omit<Transaction, 'id'>>) => {
        await db.transactions.update(id, data);
    }, []);

    const deleteTransaction = useCallback(async (id: string) => {
        await db.transactions.delete(id);
    }, []);

    const getTransactionsByDateRange = useCallback(async (startDate: string, endDate: string) => {
        const start = new Date(`${startDate}T00:00:00Z`).toISOString();
        const end = new Date(`${endDate}T23:59:59Z`).toISOString();
        return db.transactions.where('date').between(start, end).toArray();
    }, []);

    const value: DataContextType = {
        addPerson,
        addTransaction,
        updateTransaction,
        deleteTransaction,
        getTransactionsByDateRange,
        isAppLoading,
        needsOnboarding,
        seedDatabase,
        completeOnboarding,
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