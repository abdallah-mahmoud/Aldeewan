
import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import logoSrc from '../assets/logo.png';
import { ArrowLeft, ArrowRight } from 'lucide-react';

interface HeaderProps {
    title: string;
     showBackButton: boolean;
    onBackClick: () => void;
}

const Header: React.FC<HeaderProps> = ({ title, showBackButton, onBackClick }) => {
   const { t, dir } = useLocalization();
const BackArrowIcon = dir === 'rtl' ? ArrowRight : ArrowLeft;
   

    return (
        <header className="bg-light-surface dark:bg-dark-surface sticky top-0 z-10 shadow-md pt-[env(safe-area-inset-top)]">
            <div className="container mx-auto px-4 py-3 flex items-center gap-4 h-14">
                {showBackButton ? (
                    <button 
                        onClick={onBackClick} 
                        aria-label={t('back')}
                        className="p-2 -m-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5"
                    >
                        <BackArrowIcon className="w-6 h-6 text-light-on-surface dark:text-dark-on-surface" />
                    </button>
                ) : (
                    <img src={logoSrc} alt={t('appName')} className="h-8 w-auto" />
                )}

                <h1 className="text-xl font-bold text-light-on-surface dark:text-dark-on-surface truncate">
                    {title}
                </h1>
            </div>
        </header>
    );
};

export default Header;
