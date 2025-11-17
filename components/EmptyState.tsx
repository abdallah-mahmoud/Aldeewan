import React from 'react';

interface EmptyStateProps {
    Icon: React.ElementType;
    title: string;
    message: string;
}

const EmptyState: React.FC<EmptyStateProps> = ({ Icon, title, message }) => {
    return (
        <div className="text-center p-8 flex flex-col items-center justify-center rounded-lg bg-light-surface dark:bg-dark-surface mt-4 ring-1 ring-black/5 dark:ring-white/10">
            <div className="bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary rounded-full p-4 mb-4">
                <Icon className="w-12 h-12" />
            </div>
            <h3 className="text-xl font-bold text-light-on-surface dark:text-dark-on-surface mb-2">{title}</h3>
            <p className="max-w-xs mx-auto text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{message}</p>
        </div>
    );
};

export default EmptyState;
