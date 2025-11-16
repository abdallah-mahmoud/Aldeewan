import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import type { Screen, LedgerEntryType } from '../types';
import { FilePlus2, CreditCard, PlusCircle, Scale } from 'lucide-react';


interface ActionButtonProps {
    label: string;
    Icon: React.ElementType;
    onClick: () => void;
}

const ActionButton: React.FC<ActionButtonProps> = ({ label, Icon, onClick }) => (
    <button
        onClick={onClick}
        className="bg-light-surface dark:bg-dark-surface rounded-lg p-4 flex flex-col items-center justify-center text-center ring-1 ring-black/5 dark:ring-white/10 hover:ring-light-primary dark:hover:ring-dark-primary transition-all duration-200"
    >
        <div className="bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary rounded-full p-3 mb-3">
            <Icon className="w-7 h-7" />
        </div>
        <span className="font-semibold text-sm text-light-on-surface dark:text-dark-on-surface">{label}</span>
    </button>
);

interface HomeScreenProps {
    setActiveScreen: (screen: Screen) => void;
    onAddCashEntry: () => void;
    onAddLedgerEntry: (type: LedgerEntryType) => void;
}

const HomeScreen: React.FC<HomeScreenProps> = ({ setActiveScreen, onAddCashEntry, onAddLedgerEntry }) => {
    const { t, formatCurrency } = useLocalization();
    const { homeScreenTotals } = useData();
    const { totalReceivable, totalPayable } = homeScreenTotals;

    return (
        <div className="space-y-6">
            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 ring-1 ring-black/5 dark:ring-white/10">
                 <h2 className="text-base font-semibold mb-3 text-light-on-surface-secondary dark:text-dark-on-surface-secondary text-center">{t('tagline')}</h2>
                 <div className="grid grid-cols-2 gap-4 text-center">
                    <div>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalReceivable')}</p>
                        <p className="text-2xl font-bold text-brand-green">{formatCurrency(totalReceivable)}</p>
                    </div>
                    <div>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalPayable')}</p>
                        <p className="text-2xl font-bold text-brand-red">{formatCurrency(totalPayable)}</p>
                    </div>
                 </div>
            </div>

            <div>
                <h2 className="text-lg font-bold mb-3 text-light-on-surface dark:text-dark-on-surface">{t('quickActions')}</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <ActionButton label={t('addDebt')} Icon={FilePlus2} onClick={() => onAddLedgerEntry('debt')} />
                    <ActionButton label={t('recordPayment')} Icon={CreditCard} onClick={() => onAddLedgerEntry('payment')} />
                    <ActionButton label={t('addCashEntry')} Icon={PlusCircle} onClick={onAddCashEntry} />
                    <ActionButton label={t('viewBalances')} Icon={Scale} onClick={() => setActiveScreen('ledger')} />
                </div>
            </div>
        </div>
    );
};

export default HomeScreen;
