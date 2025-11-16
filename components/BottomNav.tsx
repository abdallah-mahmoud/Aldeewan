
import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import type { Screen } from '../types';
import { Home, BookOpen, Landmark, PieChart, Settings } from 'lucide-react';

interface BottomNavProps {
    activeScreen: Screen;
    setActiveScreen: (screen: Screen) => void;
}

const BottomNav: React.FC<BottomNavProps> = ({ activeScreen, setActiveScreen }) => {
    const { t } = useLocalization();

    const navItems: { screen: Screen; label: string; Icon: React.ElementType }[] = [
        { screen: 'home', label: t('home'), Icon: Home },
        { screen: 'ledger', label: t('ledger'), Icon: BookOpen },
        { screen: 'cashbook', label: t('cashbook'), Icon: Landmark },
        { screen: 'reports', label: t('reports'), Icon: PieChart },
        { screen: 'settings', label: t('settings'), Icon: Settings },
    ];

    return (
        <nav className="fixed bottom-0 left-0 right-0 bg-light-surface dark:bg-dark-surface border-t border-black/5 dark:border-white/5 shadow-lg">
            <div className="container mx-auto flex justify-around">
                {navItems.map((item) => {
                    const isActive = activeScreen === item.screen;
                    return (
                        <button
                            key={item.screen}
                            onClick={() => setActiveScreen(item.screen)}
                            className={`flex flex-col items-center justify-center w-full pt-2 pb-1 text-sm transition-colors duration-200 relative ${
                                isActive
                                    ? 'text-light-primary dark:text-dark-primary font-bold'
                                    : 'text-light-on-surface-secondary dark:text-dark-on-surface-secondary hover:text-light-primary dark:hover:text-dark-primary'
                            }`}
                        >
                             {isActive && <div className="absolute top-0 h-1 w-10 bg-light-primary dark:bg-dark-primary rounded-b-full"></div>}
                            <item.Icon className="w-6 h-6 mb-1" strokeWidth={isActive ? 2.5 : 2} />
                            <span>{item.label}</span>
                        </button>
                    );
                })}
            </div>
        </nav>
    );
};

export default BottomNav;