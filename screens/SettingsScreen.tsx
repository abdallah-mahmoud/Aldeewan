import React, { useState, useRef, useEffect } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useTheme } from '../context/ThemeContext';
import { useToast } from '../context/ToastContext';
import { db } from '../db';
import Modal from '../components/Modal';
import { ChevronRight } from 'lucide-react';
import type { Screen } from '../types';
import { saveFileToDevice } from '../utils/native';

const currencyOptions = [
  { code: 'SDG', nameKey: 'sdg' },
  { code: 'SAR', nameKey: 'sar' },
  { code: 'QAR', nameKey: 'qar' },
  { code: 'EGP', nameKey: 'egp' },
];

const timezoneOptions = [
    { value: 'Africa/Khartoum', nameKey: 'Africa/Khartoum' },
    { value: 'Africa/Cairo', nameKey: 'Africa/Cairo' },
    { value: 'Asia/Riyadh', nameKey: 'Asia/Riyadh' },
    { value: 'Asia/Qatar', nameKey: 'Asia/Qatar' },
];

interface SettingsScreenProps {
    setActiveScreen: (screen: Screen) => void;
    setHeaderTitle: (title: string) => void;
}

const SettingsScreen: React.FC<SettingsScreenProps> = ({ setActiveScreen, setHeaderTitle }) => {
    const { t, language, setLanguage, appCurrency, setAppCurrency, appTimezone, setAppTimezone } = useLocalization();
    const { theme, setTheme } = useTheme();
    const { showToast } = useToast();

    const [isConfirmModalOpen, setConfirmModalOpen] = useState(false);
    const [importDataContent, setImportDataContent] = useState<string | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    type ThemeOption = {
        value: 'light' | 'dark' | 'system';
        label: string;
    };

    const themeOptions: ThemeOption[] = [
        { value: 'light', label: t('light') },
        { value: 'dark', label: t('dark') },
        { value: 'system', label: t('system') },
    ];

    const handleExport = async () => {
        try {
            const blob = await db.exportDB();
            const filename = `aldeewan_backup_${new Date().toISOString().split('T')[0]}.json`;

            // Try saving natively first
            const nativeSaveSuccess = await saveFileToDevice(filename, blob);
            if (nativeSaveSuccess) {
                showToast("Backup saved to Downloads folder.", 'success');
                return;
            }

            // Fallback to web download
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        } catch (error) {
            console.error("Export failed:", error);
            showToast(t('exportError'), 'error');
        }
    };

    const handleImportClick = () => {
        fileInputRef.current?.click();
    };

    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const content = e.target?.result as string;
                setImportDataContent(content);
                setConfirmModalOpen(true);
            };
            reader.readAsText(file);
        }
        if (event.target) event.target.value = '';
    };

    const handleConfirmImport = async () => {
        if (!importDataContent) return;
        try {
            await db.importDB(importDataContent);
            showToast(t('importSuccess'), 'success');
             // Reload the page to ensure all components refresh with the new data
            window.location.reload();
        } catch (error) {
            console.error("Import failed:", error);
            showToast(t('importError'), 'error');
        } finally {
            setConfirmModalOpen(false);
            setImportDataContent(null);
        }
    };


    useEffect(() => {
    setHeaderTitle(t('settings'));
}, [setHeaderTitle, t]);

    return (
        <div className="space-y-6">
           
            
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
            {/* --- Start of New Language Settings Block --- */}
<div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 ring-1 ring-black/5 dark:ring-white/10">
    <h2 id="language-group-label" className="text-lg font-semibold mb-3 text-light-on-surface dark:text-dark-on-surface">Language / اللغة</h2>
    <div role="group" aria-labelledby="language-group-label" className="flex flex-row space-x-2 rtl:space-x-reverse bg-light-background dark:bg-dark-background p-1 rounded-lg">
        <button
            onClick={() => setLanguage('ar')}
            className={`w-full py-2 px-4 rounded-md font-semibold transition-colors ${
                language === 'ar'
                    ? 'bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background shadow'
                    : 'hover:bg-black/5 dark:hover:bg-white/5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary'
            }`}
            aria-pressed={(language === 'ar').toString()}
        >
            العربية
        </button>
        <button
            onClick={() => setLanguage('en')}
            className={`w-full py-2 px-4 rounded-md font-semibold transition-colors ${
                language === 'en'
                    ? 'bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background shadow'
                    : 'hover:bg-black/5 dark:hover:bg-white/5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary'
            }`}
            aria-pressed={(language === 'en').toString()}
        >
            English
        </button>
    </div>
</div>
{/* --- End of New Language Settings Block --- */}

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

            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 ring-1 ring-black/5 dark:ring-white/10">
                <h2 className="text-lg font-semibold mb-3 text-light-on-surface dark:text-dark-on-surface">{t('timezone')}</h2>
                <select
                    value={appTimezone}
                    onChange={(e) => setAppTimezone(e.target.value)}
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary"
                    aria-label={t('timezone')}
                >
                    {timezoneOptions.map(tz => (
                        <option key={tz.value} value={tz.value}>{t(tz.nameKey)}</option>
                    ))}
                </select>
            </div>

            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm ring-1 ring-black/5 dark:ring-white/10">
                <h2 className="text-lg font-semibold p-4 border-b border-black/5 dark:border-white/10 text-light-on-surface dark:text-dark-on-surface">{t('dataManagement')}</h2>
                <div className="divide-y divide-black/5 dark:divide-white/5">
                    <button onClick={handleExport} className="w-full text-start p-4 hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <p className="font-semibold text-light-on-surface dark:text-dark-on-surface">{t('exportData')}</p>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('exportDataDesc')}</p>
                    </button>
                    <button onClick={handleImportClick} className="w-full text-start p-4 hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <p className="font-semibold text-light-on-surface dark:text-dark-on-surface">{t('importData')}</p>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('importDataDesc')}</p>
                        <input type="file" ref={fileInputRef} onChange={handleFileChange} accept=".json" className="hidden" />
                    </button>
                </div>
            </div>

            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm ring-1 ring-black/5 dark:ring-white/10">
                <button onClick={() => setActiveScreen('about')} className="w-full flex justify-between items-center text-start p-4 hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                    <div>
                        <p className="font-semibold text-light-on-surface dark:text-dark-on-surface">{t('about_developer')}</p>
                        <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('developer_name')}</p>
                    </div>
                    <ChevronRight className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                </button>
            </div>


             <Modal isOpen={isConfirmModalOpen} onClose={() => setConfirmModalOpen(false)} title={t('confirmImportTitle')}>
                <div className="p-4 space-y-4">
                    <p className="text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('confirmImportMessage')}</p>
                    <div className="flex justify-end gap-2">
                        <button onClick={() => { setConfirmModalOpen(false); setImportDataContent(null); }} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                        <button onClick={handleConfirmImport} className="px-4 py-2 rounded-lg font-semibold bg-brand-red text-white hover:bg-red-600">{t('replace')}</button>
                    </div>
                </div>
            </Modal>
        </div>
    );
};

export default SettingsScreen;
