import React from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { Calendar } from 'lucide-react';

interface DatePickerProps {
    value: string; // Expects 'YYYY-MM-DD'
    onChange: (value: string) => void;
    required?: boolean;
}

const DatePicker: React.FC<DatePickerProps> = ({ value, onChange, required = false }) => {
    const { formatDate } = useLocalization();

    let displayDate = 'Select a date';
    try {
        if (value) {
            displayDate = formatDate(value);
        }
    } catch (e) {
        console.error("Invalid date value for DatePicker:", value);
    }

    return (
        <label className="relative block">
            {/* This div provides the visual styling of a button/input field. */}
            <div
                className="w-full p-2 text-start border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none flex justify-between items-center cursor-pointer"
                aria-hidden="true"
            >
                <span>{displayDate}</span>
                <Calendar className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
            </div>
            {/* The actual input is visually hidden but interactive. Clicking the label activates it. */}
            <input
                type="date"
                value={value}
                onChange={(e) => onChange(e.target.value)}
                required={required}
                className="opacity-0 absolute top-0 left-0 w-full h-full cursor-pointer"
                // Add focus styles to the parent label for accessibility
                onFocus={(e) => e.currentTarget.parentElement?.classList.add('ring-2', 'ring-light-primary', 'dark:ring-dark-primary')}
                onBlur={(e) => e.currentTarget.parentElement?.classList.remove('ring-2', 'ring-light-primary', 'dark:ring-dark-primary')}
            />
        </label>
    );
};

export default DatePicker;
