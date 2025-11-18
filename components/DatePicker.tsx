import React from 'react';

interface DatePickerProps {
    value: string; // Expects 'YYYY-MM-DD'
    onChange: (value: string) => void;
    required?: boolean;
    id?: string;
}

const DatePicker: React.FC<DatePickerProps> = ({ value, onChange, required = false, id }) => {
    return (
        <input
        id={id}
            type="date"
            value={value}
            onChange={(e) => onChange(e.target.value)}
            required={required}
            className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background text-light-on-surface dark:text-dark-on-surface outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary"
        />
    );
};

export default DatePicker;
