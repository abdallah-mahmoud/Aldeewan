
import React from 'react';
import { useLocalization } from '../context/LocalizationContext';

const Header: React.FC = () => {
    const { language, setLanguage, t } = useLocalization();

    const toggleLanguage = () => {
        setLanguage(language === 'ar' ? 'en' : 'ar');
    };

    return (
        <header className="bg-light-surface dark:bg-dark-surface sticky top-0 z-10 shadow-md">
            <div className="container mx-auto px-4 py-4 flex justify-between items-center">
                 <h1 className="text-xl font-bold text-light-primary dark:text-dark-primary">{t('appName')}</h1>
                <button
                    onClick={toggleLanguage}
                    className="z-10 text-sm font-bold w-8 h-8 flex items-center justify-center rounded-md bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary hover:bg-opacity-20 dark:hover:bg-opacity-20 transition-colors"
                >
                    {language === 'ar' ? 'EN' : 'ع'}
                </button>
            </div>
        </header>
    );
};

export default Header;