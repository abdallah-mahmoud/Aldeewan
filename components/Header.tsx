
import React from 'react';
import { useLocalization } from '../context/LocalizationContext';

const Header: React.FC = () => {
    const { language, setLanguage, t } = useLocalization();

    const toggleLanguage = () => {
        setLanguage(language === 'ar' ? 'en' : 'ar');
    };

    return (
        <header className="bg-light-surface dark:bg-dark-surface sticky top-0 z-10 shadow-md">
            <div className="container mx-auto px-4 py-3 flex justify-between items-center">
                 <img src="assets/logo.PNG" alt={t('ALDEEWAN')} className="h-8 w-auto" />
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
