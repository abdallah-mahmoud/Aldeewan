import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import { TestTube, Sparkles } from 'lucide-react';

const OnboardingGuide: React.FC = () => {
    const { t } = useLocalization();
    const { seedDatabase, completeOnboarding } = useData();

    const handleSeed = async () => {
        await seedDatabase();
        completeOnboarding();
    };

    const OptionButton: React.FC<{
        title: string;
        description: string;
        Icon: React.ElementType;
        onClick: () => void;
    }> = ({ title, description, Icon, onClick }) => (
        <button
            onClick={onClick}
            className="w-full text-start bg-light-surface dark:bg-dark-surface rounded-lg shadow-sm p-4 flex items-center gap-4 transition-all ring-1 ring-black/5 dark:ring-white/10 hover:ring-light-primary dark:hover:ring-dark-primary hover:shadow-md"
        >
            <div className="bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary rounded-lg p-3">
                <Icon className="w-7 h-7" />
            </div>
            <div>
                <h3 className="font-bold text-lg text-light-on-surface dark:text-dark-on-surface">{title}</h3>
                <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{description}</p>
            </div>
        </button>
    );

    return (
        <div className="min-h-screen bg-light-background dark:bg-dark-background flex flex-col items-center justify-center p-4 text-center">
             <img src="assets/logo.PNG" alt={t('ALDEEWAN')} className="h-12 w-auto mb-6" />
            <h1 className="text-3xl font-bold mb-2 text-light-on-surface dark:text-dark-on-surface">{t('welcome_title')}</h1>
            <p className="max-w-md mb-10 text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('welcome_message')}</p>

            <div className="w-full max-w-sm space-y-4">
                <OptionButton
                    onClick={handleSeed}
                    title={t('onboarding_seed_title')}
                    description={t('onboarding_seed_desc')}
                    Icon={TestTube}
                />
                <OptionButton
                    onClick={completeOnboarding}
                    title={t('onboarding_fresh_title')}
                    description={t('onboarding_fresh_desc')}
                    Icon={Sparkles}
                />
            </div>

             <footer className="absolute bottom-4 text-xs text-light-on-surface-secondary/50 dark:text-dark-on-surface-secondary/50">
                {t('appName')} &copy; {new Date().getFullYear()}
            </footer>
        </div>
    );
};

export default OnboardingGuide;
