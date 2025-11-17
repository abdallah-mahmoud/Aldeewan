import React, { useEffect, useState } from 'react';
import { CheckCircle2, XCircle, Info, X } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info';

interface ToastProps {
    message: string;
    type: ToastType;
    onClose: () => void;
}

const toastConfig = {
    success: {
        Icon: CheckCircle2,
        bgClass: 'bg-brand-green',
    },
    error: {
        Icon: XCircle,
        bgClass: 'bg-brand-red',
    },
    info: {
        Icon: Info,
        bgClass: 'bg-blue-500',
    },
};

const Toast: React.FC<ToastProps> = ({ message, type, onClose }) => {
    const [isVisible, setIsVisible] = useState(false);
    const { Icon, bgClass } = toastConfig[type];

    useEffect(() => {
        // Mount animation
        setIsVisible(true);
        // Unmount animation
        const timer = setTimeout(() => {
            setIsVisible(false);
        }, 2700); // Start fade out before onClose is called
        return () => clearTimeout(timer);
    }, []);

    return (
        <div
            className={`fixed bottom-24 sm:bottom-4 left-1/2 -translate-x-1/2 w-auto max-w-sm p-4 rounded-lg shadow-2xl flex items-center gap-3 text-white transition-all duration-300 ease-in-out ${bgClass} ${
                isVisible ? 'animate-in fade-in-0 slide-in-from-bottom-5' : 'animate-out fade-out-0 slide-out-to-bottom-5'
            }`}
            role="alert"
        >
            <Icon className="w-6 h-6 flex-shrink-0" />
            <span className="flex-grow font-semibold">{message}</span>
            <button onClick={onClose} className="p-1 rounded-full hover:bg-white/20 flex-shrink-0">
                <X className="w-5 h-5" />
            </button>
        </div>
    );
};

export default Toast;
