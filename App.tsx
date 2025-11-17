import React, { useState, useMemo, useEffect } from 'react';
import { LocalizationProvider, useLocalization } from './context/LocalizationContext';
import { ThemeProvider } from './context/ThemeContext';
import { DataProvider, useData } from './context/DataContext';
import { ToastProvider, useToast } from './context/ToastContext';
import HomeScreen from './screens/HomeScreen';
import LedgerScreen from './screens/LedgerScreen';
import CashbookScreen from './screens/CashbookScreen';
import ReportsScreen, { ReportType } from './screens/ReportsScreen';
import SettingsScreen from './screens/SettingsScreen';
import AboutScreen from './screens/AboutScreen';
import Header from './components/Header';
import BottomNav from './components/BottomNav';
import Modal from './components/Modal';
import { CashTransactionForm } from './components/CashEntryForm';
import { PersonTransactionForm } from './components/AddLedgerEntryForm';
import type { Screen, LedgerFlowType, Transaction } from './types';
import OnboardingGuide from './components/OnboardingGuide';
import { handleAndroidBackButton } from './utils/native';

const AppContent: React.FC = () => {
    const [activeScreen, setActiveScreen] = useState<Screen>('home');
    const { dir, t } = useLocalization();
    const { addTransaction } = useData();
    const { showToast } = useToast();

    // --- Centralized Navigation State for Native-like Back Button ---
    const [selectedPersonId, setSelectedPersonId] = useState<string | null>(null);
    const [activeReport, setActiveReport] = useState<ReportType | null>(null);
    const [isCashTransactionModalOpen, setCashTransactionModalOpen] = useState(false);
    const [personTransactionFlow, setPersonTransactionFlow] = useState<LedgerFlowType | null>(null);

    // Effect for handling the Android back button
    useEffect(() => {
        handleAndroidBackButton(() => {
            // Priority: Modals -> Detail Views -> Screen Navigation
            if (isCashTransactionModalOpen) {
                setCashTransactionModalOpen(false);
            } else if (personTransactionFlow) {
                setPersonTransactionFlow(null);
            } else if (selectedPersonId) {
                setSelectedPersonId(null);
            } else if (activeReport) {
                setActiveReport(null);
            } else if (activeScreen === 'about') {
                setActiveScreen('settings');
            } else if (activeScreen !== 'home') {
                setActiveScreen('home');
            } else {
                // If on home screen, allow default behavior (exit app)
                // In a real Capacitor app, you might call `App.exitApp();`
            }
        });
    }, [activeScreen, selectedPersonId, activeReport, isCashTransactionModalOpen, personTransactionFlow]);

    const ScreenComponent = useMemo(() => {
        switch (activeScreen) {
            case 'ledger':
                return <LedgerScreen selectedPersonId={selectedPersonId} setSelectedPersonId={setSelectedPersonId} />;
            case 'cashbook':
                return <CashbookScreen />;
            case 'reports':
                return <ReportsScreen activeReport={activeReport} setActiveReport={setActiveReport} />;
            case 'settings':
                return <SettingsScreen setActiveScreen={setActiveScreen} />;
            case 'about':
                return <AboutScreen setActiveScreen={setActiveScreen} />;
            case 'home':
            default:
                return <HomeScreen 
                    setActiveScreen={setActiveScreen}
                    onAddCashEntry={() => setCashTransactionModalOpen(true)}
                    onAddLedgerEntry={(type) => setPersonTransactionFlow(type)}
                />;
        }
    }, [activeScreen, selectedPersonId, activeReport]);
    
    const handleSaveNewTransaction = (transactionData: Omit<Transaction, 'id'>) => {
        addTransaction(transactionData);
        setCashTransactionModalOpen(false);
        setPersonTransactionFlow(null);
        showToast(t('toast_saved_successfully'), 'success');
    };

    return (
        <div dir={dir} className="bg-light-background dark:bg-dark-background text-light-on-surface dark:text-dark-on-surface min-h-screen flex flex-col">
            <Header />
            <main className="flex-grow container mx-auto p-4 pb-24">
                {ScreenComponent}
            </main>
            <BottomNav 
                activeScreen={activeScreen === 'about' ? 'settings' : activeScreen} 
                setActiveScreen={setActiveScreen} 
            />

            <Modal isOpen={isCashTransactionModalOpen} onClose={() => setCashTransactionModalOpen(false)} title={t('addCashEntry')}>
                <CashTransactionForm entry={null} onSave={handleSaveNewTransaction} onCancel={() => setCashTransactionModalOpen(false)} />
            </Modal>
            
            <Modal isOpen={!!personTransactionFlow} onClose={() => setPersonTransactionFlow(null)} title={t(personTransactionFlow === 'debt' ? 'addDebt' : 'recordPayment')}>
                {personTransactionFlow && (
                    <PersonTransactionForm 
                        flowType={personTransactionFlow}
                        onSave={handleSaveNewTransaction} 
                        onCancel={() => setPersonTransactionFlow(null)} 
                    />
                )}
            </Modal>
        </div>
    );
};

const AppRouter: React.FC = () => {
    const { isAppLoading, needsOnboarding } = useData();

    if (isAppLoading) {
        return (
            <div className="min-h-screen bg-light-background dark:bg-dark-background flex items-center justify-center">
                 <svg className="animate-spin h-8 w-8 text-light-primary dark:text-dark-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
            </div>
        );
    }

    if (needsOnboarding) {
        return <OnboardingGuide />;
    }

    return <AppContent />;
}


const App: React.FC = () => {
    return (
        <LocalizationProvider>
            <ThemeProvider>
                <DataProvider>
                    <ToastProvider>
                        <AppRouter />
                    </ToastProvider>
                </DataProvider>
            </ThemeProvider>
        </LocalizationProvider>
    );
};

export default App;
