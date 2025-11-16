
import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { PieChart, Download, Sheet } from 'lucide-react';


const ReportsScreen: React.FC = () => {
    const { t } = useLocalization();

    return (
        <div className="flex flex-col items-center justify-center h-full text-center space-y-6 pt-16">
            <div className="text-light-primary dark:text-dark-primary opacity-50">
                <PieChart className="w-24 h-24" strokeWidth={1.5} />
            </div>
            <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('generateReports')}</h1>
            <p className="text-light-on-surface-secondary dark:text-dark-on-surface-secondary max-w-sm">
                {t('featureComingSoon')}
            </p>
            <div className="flex flex-col sm:flex-row gap-4 w-full max-w-xs">
                <button
                    disabled
                    className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary font-bold py-3 px-4 rounded-lg cursor-not-allowed"
                >
                    <Download className="w-5 h-5" />
                    {t('exportAsPDF')}
                </button>
                <button
                    disabled
                    className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary font-bold py-3 px-4 rounded-lg cursor-not-allowed"
                >
                    <Sheet className="w-5 h-5" />
                    {t('exportAsCSV')}
                </button>
            </div>
        </div>
    );
};

export default ReportsScreen;