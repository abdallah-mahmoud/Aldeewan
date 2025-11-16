import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useTheme } from '../context/ThemeContext';

const currencyOptions = [
  { code: 'SDG', nameKey: 'sdg' },
  { code: 'SAR', nameKey: 'sar' },
  { code: 'AED', nameKey: 'aed' },
  { code: 'EGP', nameKey: 'egp' },
];

const SettingsScreen: React.FC = () => {
    const { t, appCurrency, setAppCurrency } = useLocalization();
    const { theme, setTheme } = useTheme();

    type ThemeOption = {
        value: 'light' | 'dark' | 'system';
        label: string;
    };

    const themeOptions: ThemeOption[] = [
        { value: 'light', label: t('light') },
        { value: 'dark', label: t('dark') },
        { value: 'system', label: t('system') },
    ];

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('settings')}</h1>
            
            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 ring-1 ring-black/5 dark:ring-white/10">
                <h2 className="text-lg font-semibold mb-3 text-light-on-surface dark:text-dark-on-surface">{t('theme')}</h2>
                <div className="flex flex-row space-x-2 rtl:space-x-reverse bg-light-background dark:bg-dark-background p-1 rounded-lg">
                    {themeOptions.map((option) => (
                        <button
                            key={option.value}
                            onClick={() => setTheme(option.value)}
                            className={`w-full py-2 px-4 rounded-md font-semibold transition-colors
                            ${
                                theme === option.value
                                    ? 'bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background shadow'
                                    : 'hover:bg-black/5 dark:hover:bg-white/5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary'
                            }`}
                            aria-pressed={theme === option.value}
                        >
                            {option.label}
                        </button>
                    ))}
                </div>
            </div>

             <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 ring-1 ring-black/5 dark:ring-white/10">
                <h2 className="text-lg font-semibold mb-3 text-light-on-surface dark:text-dark-on-surface">{t('currency')}</h2>
                <select
                    value={appCurrency}
                    onChange={(e) => setAppCurrency(e.target.value)}
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary"
                    aria-label={t('currency')}
                >
                    {currencyOptions.map(c => (
                        <option key={c.code} value={c.code}>{t(c.nameKey)}</option>
                    ))}
                </select>
            </div>
        </div>
    );
};

export default SettingsScreen;