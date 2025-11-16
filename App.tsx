import React, { useState, useMemo } from 'react';
import { LocalizationProvider, useLocalization } from './context/LocalizationContext';
import { ThemeProvider } from './context/ThemeContext';
import { DataProvider, useData } from './context/DataContext';
import HomeScreen from './screens/HomeScreen';
import LedgerScreen from './screens/LedgerScreen';
import CashbookScreen from './screens/CashbookScreen';
import ReportsScreen from './screens/ReportsScreen';
import SettingsScreen from './screens/SettingsScreen';
import Header from './components/Header';
import BottomNav from './components/BottomNav';
import Modal from './components/Modal';
import CashEntryForm from './components/CashEntryForm';
import AddLedgerEntryForm from './components/AddLedgerEntryForm';
import type { Screen, LedgerEntryType } from './types';
import { CashEntryType as CET } from './types';

const AppContent: React.FC = () => {
    const [activeScreen, setActiveScreen] = useState<Screen>('home');
    const { dir, t } = useLocalization();
    const { addCashEntry, addLedgerEntry } = useData();

    // Global modal states
    const [isAddCashEntryModalOpen, setAddCashEntryModalOpen] = useState(false);
    const [addLedgerEntryType, setAddLedgerEntryType] = useState<LedgerEntryType | null>(null);

    const ScreenComponent = useMemo(() => {
        switch (activeScreen) {
            case 'ledger':
                return <LedgerScreen />;
            case 'cashbook':
                return <CashbookScreen />;
            case 'reports':
                return <ReportsScreen />;
            case 'settings':
                return <SettingsScreen />;
            case 'home':
            default:
                return <HomeScreen 
                    setActiveScreen={setActiveScreen}
                    onAddCashEntry={() => setAddCashEntryModalOpen(true)}
                    onAddLedgerEntry={(type) => setAddLedgerEntryType(type)}
                />;
        }
    }, [activeScreen]);
    
    const handleSaveNewCashEntry = (entryData: Omit<import('./types').CashEntry, 'id'>) => {
        addCashEntry(entryData);
        setAddCashEntryModalOpen(false);
    };

    const handleSaveNewLedgerEntry = (entryData: Omit<import('./types').LedgerEntry, 'id'>) => {
        addLedgerEntry(entryData);
        setAddLedgerEntryType(null);
    };

    return (
        <div dir={dir} className="bg-light-background dark:bg-dark-background text-light-on-surface dark:text-dark-on-surface min-h-screen flex flex-col">
            <Header />
            <main className="flex-grow container mx-auto p-4 pb-24">
                {ScreenComponent}
            </main>
            <BottomNav activeScreen={activeScreen} setActiveScreen={setActiveScreen} />

            <Modal isOpen={isAddCashEntryModalOpen} onClose={() => setAddCashEntryModalOpen(false)} title={t('addCashEntry')}>
                <CashEntryForm entry={null} onSave={handleSaveNewCashEntry} onCancel={() => setAddCashEntryModalOpen(false)} />
            </Modal>
            
            <Modal isOpen={!!addLedgerEntryType} onClose={() => setAddLedgerEntryType(null)} title={t(addLedgerEntryType === 'debt' ? 'addDebt' : 'recordPayment')}>
                {addLedgerEntryType && (
                    <AddLedgerEntryForm 
                        type={addLedgerEntryType} 
                        onSave={handleSaveNewLedgerEntry} 
                        onCancel={() => setAddLedgerEntryType(null)} 
                    />
                )}
            </Modal>
        </div>
    );
};

const App: React.FC = () => {
    return (
        <LocalizationProvider>
            <ThemeProvider>
                <DataProvider>
                    <AppContent />
                </DataProvider>
            </ThemeProvider>
        </LocalizationProvider>
    );
};

export default App;
