import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import type { Person } from '../types';
import { PersonRole } from '../types';

interface AddPersonFormProps {
    onSave: (personData: Omit<Person, 'id' | 'createdAt'>) => void;
    onCancel: () => void;
}

const AddPersonForm: React.FC<AddPersonFormProps> = ({ onSave, onCancel }) => {
    const { t } = useLocalization();
    const [name, setName] = useState('');
    const [phone, setPhone] = useState('');
    const [role, setRole] = useState<PersonRole>(PersonRole.CUSTOMER);
    const [nameError, setNameError] = useState('');

    const validate = () => {
        if (name.trim() === '') {
            setNameError(t('error_name_required'));
            return false;
        }
        setNameError('');
        return true;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validate()) {
            onSave({ name, phone: phone || null, role });
        }
    };

    return (
        <form onSubmit={handleSubmit} className="space-y-4 p-4">
            <div>
                <label htmlFor="person-name" className="block text-sm font-medium mb-1">{t('personName')}</label>
                <input 
                    id="person-name"
                    type="text" 
                    value={name} 
                    onChange={e => { setName(e.target.value); if (nameError) setNameError(''); }} 
                    required 
                    className={`w-full p-2 border rounded-lg bg-light-background dark:bg-dark-background outline-none ${
                        nameError 
                        ? 'border-brand-red focus:ring-brand-red' 
                        : 'border-black/10 dark:border-white/10 focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary'
                    }`}
                    placeholder={t('personName')}
                />
                {nameError && <p className="text-sm text-brand-red mt-1">{nameError}</p>}
            </div>
            <div>
                <label htmlFor="person-phone" className="block text-sm font-medium mb-1">{t('phoneOptional')}</label>
                <input 
                    id="person-phone"
                    type="tel" 
                    value={phone} 
                    onChange={e => setPhone(e.target.value)} 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary" 
                    placeholder="05..."
                />
            </div>
             <div>
                <label htmlFor="person-role" className="block text-sm font-medium mb-1">{t('role')}</label>
                <select 
                    id="person-role"
                    value={role} 
                    onChange={e => setRole(e.target.value as PersonRole)} 
                    className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none focus:ring-2 focus:ring-light-primary dark:focus:ring-dark-primary"
                >
                    <option value={PersonRole.CUSTOMER}>{t('customer')}</option>
                    <option value={PersonRole.SUPPLIER}>{t('supplier')}</option>
                </select>
            </div>
            <div className="flex justify-end gap-2 pt-2">
                <button type="button" onClick={onCancel} className="px-4 py-2 rounded-lg font-semibold hover:bg-black/5 dark:hover:bg-white/5">{t('cancel')}</button>
                <button type="submit" className="px-4 py-2 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('save')}</button>
            </div>
        </form>
    );
};

export default AddPersonForm;
