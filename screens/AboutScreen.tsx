import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { Mail, Phone, Github, ArrowLeft, Camera, ChevronRight } from 'lucide-react';
import BrandIcon from '../components/BrandIcons';
import type { Screen } from '../types';

interface AboutScreenProps {
    setActiveScreen: (screen: Screen) => void;
}

const AboutScreen: React.FC<AboutScreenProps> = ({ setActiveScreen }) => {
    const { t } = useLocalization();

    return (
        <div className="space-y-6 animate-in fade-in-0 duration-300">
            <div className="flex items-center gap-2">
                <button onClick={() => setActiveScreen('settings')} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5">
                    <ArrowLeft />
                </button>
                <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('about_developer')}</h1>
            </div>

            <div className="flex flex-col items-center space-y-4 pt-4">
                <div className="w-28 h-28 rounded-full bg-light-surface dark:bg-dark-surface ring-4 ring-light-background dark:ring-dark-background flex items-center justify-center shadow-md">
                    <Camera className="w-10 h-10 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                </div>
                <div className="text-center">
                    <p className="font-bold text-2xl tracking-wider text-light-on-surface dark:text-dark-on-surface">{t('developer_name')}</p>
                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary mt-1 px-4 max-w-sm">{t('developer_tagline')}</p>
                </div>
            </div>

            <div className="bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm ring-1 ring-black/5 dark:ring-white/10 p-2">
                <div className="divide-y divide-black/5 dark:divide-white/5">
                    <a href="https://www.facebook.com/motaasl8" target="_blank" rel="noopener noreferrer" className="flex items-center gap-3 p-3 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <BrandIcon name="facebook" className="w-6 h-6 text-blue-600" />
                        <span className="font-semibold text-light-on-surface dark:text-dark-on-surface flex-grow">{t('facebook')}</span>
                        <span className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">@motaasl8</span>
                        <ChevronRight className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                    </a>
                    <a href="https://www.instagram.com/motaasl8" target="_blank" rel="noopener noreferrer" className="flex items-center gap-3 p-3 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                         <BrandIcon name="instagram" className="w-6 h-6 text-pink-500" />
                        <span className="font-semibold text-light-on-surface dark:text-dark-on-surface flex-grow">{t('instagram')}</span>
                         <span className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">@motaasl8</span>
                        <ChevronRight className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                    </a>
                    <a href="mailto:abdo13-m.azme@hotmail.com" className="flex items-center gap-3 p-3 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <Mail className="w-6 h-6 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                        <span className="font-semibold text-light-on-surface dark:text-dark-on-surface flex-grow">abdo13-m.azme@hotmail.com</span>
                    </a>
                    <a href="tel:+249111950191" className="flex items-center gap-3 p-3 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <Phone className="w-6 h-6 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                        <span className="font-semibold text-light-on-surface dark:text-dark-on-surface flex-grow">+249 111 950 191</span>
                    </a>
                    <a href="https://github.com/abdallah-mahmoud/Aldeewan" target="_blank" rel="noopener noreferrer" className="flex items-center gap-3 p-3 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
                        <Github className="w-6 h-6 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                        <span className="font-semibold text-light-on-surface dark:text-dark-on-surface flex-grow">{t('open_source_link')}</span>
                        <ChevronRight className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
                    </a>
                </div>
            </div>

            <div className="text-center pt-4 mt-2">
                <p className="font-semibold text-light-primary dark:text-dark-primary">{t('islamic_endowment')}</p>
            </div>

        </div>
    );
};

export default AboutScreen;
