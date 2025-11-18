import React, { useState } from 'react';
import { useLocalization } from '../context/LocalizationContext';
import { useData } from '../context/DataContext';
import { useToast } from '../context/ToastContext';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db';
import { exportToCsv } from '../utils/csv';
import type { Person, Transaction } from '../types';
import DatePicker from '../components/DatePicker';
import { ArrowLeft, BookUser, BarChart3, Database, ChevronRight, Share2, Sheet } from 'lucide-react';
import { calculatePersonBalance } from '../utils/calculations';
import { calculateCashFlowReport, generatePersonStatementText } from '../utils/reporting';
import { nativeShare } from '../utils/native';

export type ReportType = 'person' | 'cashflow' | 'export';

// --- Reusable Components ---
const ReportCard: React.FC<{ title: string; description: string; Icon: React.ElementType; onClick: () => void; }> = ({ title, description, Icon, onClick }) => (
    <button onClick={onClick} className="w-full bg-light-surface dark:bg-dark-surface p-4 rounded-lg shadow-sm ring-1 ring-black/5 dark:ring-white/10 flex items-center gap-4 text-start hover:ring-light-primary dark:hover:ring-dark-primary transition-all">
        <div className="bg-light-primary-muted dark:bg-dark-primary-muted text-light-primary dark:text-dark-primary p-3 rounded-lg">
            <Icon className="w-6 h-6" />
        </div>
        <div className="flex-grow">
            <h3 className="font-bold text-light-on-surface dark:text-dark-on-surface">{title}</h3>
            <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{description}</p>
        </div>
        <ChevronRight className="w-5 h-5 text-light-on-surface-secondary dark:text-dark-on-surface-secondary" />
    </button>
);

const DateRangePicker: React.FC<{ startDate: string, setStartDate: (d: string) => void, endDate: string, setEndDate: (d: string) => void }> = ({ startDate, setStartDate, endDate, setEndDate }) => {
    const { t } = useLocalization();

    const setDateRange = (start: Date, end: Date) => {
        setStartDate(start.toISOString().split('T')[0]);
        setEndDate(end.toISOString().split('T')[0]);
    };

    const setThisMonth = () => {
        const now = new Date();
        const start = new Date(now.getFullYear(), now.getMonth(), 1);
        const end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        setDateRange(start, end);
    };

    const setLastMonth = () => {
        const now = new Date();
        const start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
        const end = new Date(now.getFullYear(), now.getMonth(), 0);
        setDateRange(start, end);
    };
    
    const setThisQuarter = () => {
        const now = new Date();
        const quarter = Math.floor(now.getMonth() / 3);
        const start = new Date(now.getFullYear(), quarter * 3, 1);
        const end = new Date(now.getFullYear(), quarter * 3 + 3, 0);
        setDateRange(start, end);
    };

    return (
        <div className="space-y-3 p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10">
            <div className="grid grid-cols-3 gap-2">
                <button onClick={setThisMonth} className="text-sm py-1 px-2 rounded-md bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10">{t('thisMonth')}</button>
                <button onClick={setLastMonth} className="text-sm py-1 px-2 rounded-md bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10">{t('lastMonth')}</button>
                <button onClick={setThisQuarter} className="text-sm py-1 px-2 rounded-md bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10">{t('thisQuarter')}</button>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label className="block text-sm font-medium mb-1">{t('startDate')}</label>
                    <DatePicker value={startDate} onChange={setStartDate} required />
                </div>
                <div>
                    <label className="block text-sm font-medium mb-1">{t('endDate')}</label>
                    <DatePicker value={endDate} onChange={setEndDate} required />
                </div>
            </div>
        </div>
    );
};


// --- Report Components ---

const PersonStatementReport: React.FC<{ onBack: () => void }> = ({ onBack }) => {
    const { t, getTodayDateString, formatDate, formatCurrency } = useLocalization();
    const { showToast } = useToast();
    
    const persons = useLiveQuery(() => db.persons.toArray(), []) || [];
    const transactions = useLiveQuery(() => db.transactions.toArray(), []) || [];

    const [personId, setPersonId] = useState('');
    const [startDate, setStartDate] = useState(() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return d.toISOString().split('T')[0]; });
    const [endDate, setEndDate] = useState(getTodayDateString());
    const [statement, setStatement] = useState<string | null>(null);
    const [statementTransactions, setStatementTransactions] = useState<Transaction[]>([]);

    const generateStatement = async () => {
        if (!personId) return;
        const person = persons.find(p => p.id === personId);
        if (!person) return;

        const allTransactionsForPerson = transactions.filter(t => t.personId === personId);
        const transactionsInDateRange = allTransactionsForPerson.filter(t => new Date(t.date) >= new Date(`${startDate}T00:00:00Z`) && new Date(t.date) <= new Date(`${endDate}T23:59:59Z`));
        setStatementTransactions(transactionsInDateRange);
        
        const balanceBroughtForwardTransactions = allTransactionsForPerson.filter(t => new Date(t.date) < new Date(`${startDate}T00:00:00Z`));
        const balanceBroughtForward = calculatePersonBalance(person, balanceBroughtForwardTransactions);

        const statementText = generatePersonStatementText({
            person,
            transactionsInDateRange,
            balanceBroughtForward,
            t,
            formatDate,
            formatCurrency
        });
        
        setStatement(statementText);
    };

    const handleShare = async () => {
        if (!statement) return;

        const shareTitle = t('appName');

        // 1. TRY NATIVE SHARE FIRST
        const sharedNatively = await nativeShare({
            title: shareTitle,
            text: statement,
            dialogTitle: t('share'),
        });

        // 2. FALLBACK TO WEB SHARE / CLIPBOARD if native share fails
        if (!sharedNatively) {
            if (navigator.share) {
                await navigator.share({ title: shareTitle, text: statement });
            } else {
                await navigator.clipboard.writeText(statement);
                showToast(t('toast_copied_clipboard'), 'info');
            }
        }
    };
    
    const handleExportCsv = () => {
        const person = persons.find(p => p.id === personId);
        if(!person || statementTransactions.length === 0) return;
        
        const rows = statementTransactions.map(tx => ({
            date: formatDate(tx.date),
            type: t(tx.type),
            note: tx.note || '',
            amount: tx.amount
        }));
        
        exportToCsv(`${person.name}_statement_${startDate}_to_${endDate}.csv`, rows);
    }

    return (
        <div className="space-y-4">
             <div className="flex items-center gap-2">
                <button onClick={onBack} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5" aria-label={t('back')}><ArrowLeft/></button>
                <h2 className="text-xl font-bold">{t('personStatement')}</h2>
            </div>
            <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-3">
                <label className="block text-sm font-medium">{t('selectPerson')}</label>
                 <select value={personId} onChange={e => setPersonId(e.target.value)} required className="w-full p-2 border border-black/10 dark:border-white/10 rounded-lg bg-light-background dark:bg-dark-background outline-none">
                    <option value="" disabled>{`-- ${t('selectPerson')} --`}</option>
                    {persons.map(p => <option key={p.id} value={p.id}>{p.name} ({t(p.role)})</option>)}
                </select>
            </div>
            <DateRangePicker startDate={startDate} setStartDate={setStartDate} endDate={endDate} setEndDate={setEndDate} />
            <button onClick={generateStatement} disabled={!personId} className="w-full py-3 px-4 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed">{t('generate')}</button>
            
            {statement && (
                <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-4">
                    <pre className="whitespace-pre-wrap text-sm font-mono bg-light-background dark:bg-dark-background p-3 rounded-md overflow-x-auto">{statement}</pre>
                    <div className="flex gap-2">
                        <button onClick={handleShare} className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 font-bold py-2 px-4 rounded-lg"><Share2 className="w-4 h-4" /> {t('share')}</button>
                        <button onClick={handleExportCsv} className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 font-bold py-2 px-4 rounded-lg"><Sheet className="w-4 h-4" /> {t('exportAsCSV')}</button>
                    </div>
                </div>
            )}
        </div>
    );
};

const CashFlowReport: React.FC<{ onBack: () => void }> = ({ onBack }) => {
    const { t, getTodayDateString, formatCurrency } = useLocalization();
    const { getTransactionsByDateRange } = useData();
    const [startDate, setStartDate] = useState(() => { const d = new Date(); d.setDate(1); return d.toISOString().split('T')[0]; });
    const [endDate, setEndDate] = useState(getTodayDateString());
    const [reportData, setReportData] = useState<any | null>(null);

    const generateReport = async () => {
        const transactions = await getTransactionsByDateRange(startDate, endDate);
        const data = calculateCashFlowReport(transactions, t);
        setReportData(data);
    };
    
    const handleExportCsv = () => {
        if(!reportData || reportData.categories.length === 0) return;
        const rows = reportData.categories.map((cat: any) => ({
            category: cat.name,
            income: cat.income,
            expense: cat.expense
        }));
        exportToCsv(`cash_flow_${startDate}_to_${endDate}.csv`, rows);
    };

    return (
        <div className="space-y-4">
            <div className="flex items-center gap-2">
                <button onClick={onBack} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5" aria-label={t('back')}><ArrowLeft/></button>
                <h2 className="text-xl font-bold">{t('cashFlowReport')}</h2>
            </div>
            <DateRangePicker startDate={startDate} setStartDate={setStartDate} endDate={endDate} setEndDate={setEndDate} />
            <button onClick={generateReport} className="w-full py-3 px-4 rounded-lg font-semibold bg-light-primary dark:bg-dark-primary text-white dark:text-dark-background hover:opacity-90">{t('generate')}</button>
            
            {reportData && (
                 reportData.categories.length === 0 ? (
                    <p className="text-center p-8 text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('noDataForPeriod')}</p>
                 ) : (
                <div className="space-y-4">
                    {reportData.profitLoss && (
                         <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-3">
                            <h3 className="font-bold text-lg">{t('profitLoss')}</h3>
                            <div className="grid grid-cols-2 gap-4 text-center">
                                <div>
                                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalCashIn')}</p>
                                    <p className="text-xl font-bold text-brand-green">{formatCurrency(reportData.profitLoss.cashIn)}</p>
                                </div>
                                 <div>
                                    <p className="text-sm text-light-on-surface-secondary dark:text-dark-on-surface-secondary">{t('totalCashOut')}</p>
                                    <p className="text-xl font-bold text-brand-red">{formatCurrency(reportData.profitLoss.cashOut)}</p>
                                </div>
                            </div>
                            <div className="text-center pt-2 border-t border-black/5 dark:border-white/10">
                                 <p className="text-sm font-bold">{reportData.profitLoss.profit >= 0 ? t('profit') : t('loss')}</p>
                                 <p className={`text-2xl font-bold ${reportData.profitLoss.profit >= 0 ? 'text-brand-green' : 'text-brand-red'}`}>{formatCurrency(Math.abs(reportData.profitLoss.profit))}</p>
                            </div>
                        </div>
                    )}
                    <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-3">
                        <div className="flex justify-between items-center">
                            <h3 className="font-bold text-lg">{t('incomeAndExpenses')}</h3>
                            <button onClick={handleExportCsv} className="flex items-center gap-1 text-xs text-light-primary dark:text-dark-primary font-semibold"><Sheet className="w-4 h-4"/>{t('exportAsCSV')}</button>
                        </div>
                        <div className="divide-y divide-black/5 dark:divide-white/5">
                            <div className="flex justify-between font-bold text-sm py-2">
                                <span className="flex-1">{t('category')}</span>
                                <span className="w-24 text-end">{t('income')}</span>
                                <span className="w-24 text-end">{t('expense')}</span>
                            </div>
                            {reportData.categories.map((cat: any) => (
                                <div key={cat.name} className="flex justify-between items-center py-2 text-sm">
                                    <span className="flex-1 font-semibold truncate pr-2">{cat.name}</span>
                                    <span className="w-24 text-end text-brand-green">{cat.income > 0 ? formatCurrency(cat.income) : '-'}</span>
                                    <span className="w-24 text-end text-brand-red">{cat.expense > 0 ? formatCurrency(cat.expense) : '-'}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            ))}
        </div>
    );
};

const DataExportReport: React.FC<{ onBack: () => void }> = ({ onBack }) => {
    const { t } = useLocalization();
    const persons = useLiveQuery(() => db.persons.toArray(), []) || [];
    const transactions = useLiveQuery(() => db.transactions.toArray(), []) || [];

    const exportAllTransactions = () => {
        const rows = transactions.map(tx => ({ ...tx }));
        exportToCsv(`aldeewan_all_transactions_${new Date().toISOString().split('T')[0]}.csv`, rows);
    };

    const exportAllPersons = () => {
        const rows = persons.map(p => ({ ...p }));
        exportToCsv(`aldeewan_all_persons_${new Date().toISOString().split('T')[0]}.csv`, rows);
    };

    return (
        <div className="space-y-4">
            <div className="flex items-center gap-2">
                <button onClick={onBack} className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5" aria-label={t('back')}><ArrowLeft/></button>
                <h2 className="text-xl font-bold">{t('fullDataExport')}</h2>
            </div>
             <div className="p-4 bg-light-surface dark:bg-dark-surface rounded-lg ring-1 ring-black/5 dark:ring-white/10 space-y-3">
                 <button onClick={exportAllTransactions} className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 font-bold py-3 px-4 rounded-lg hover:bg-black/10 dark:hover:bg-white/10">
                    <Sheet className="w-5 h-5" />
                    {t('exportTransactions')} ({transactions.length})
                </button>
                 <button onClick={exportAllPersons} className="w-full flex items-center justify-center gap-2 bg-black/5 dark:bg-white/5 font-bold py-3 px-4 rounded-lg hover:bg-black/10 dark:hover:bg-white/10">
                    <Sheet className="w-5 h-5" />
                    {t('exportPersons')} ({persons.length})
                </button>
            </div>
        </div>
    );
};


// --- Main Screen Component ---
interface ReportsScreenProps {
    activeReport: ReportType | null;
    setActiveReport: (report: ReportType | null) => void;
}

const ReportsScreen: React.FC<ReportsScreenProps> = ({ activeReport, setActiveReport }) => {
    const { t } = useLocalization();

    if (activeReport === 'person') {
        return <PersonStatementReport onBack={() => setActiveReport(null)} />;
    }
    if (activeReport === 'cashflow') {
        return <CashFlowReport onBack={() => setActiveReport(null)} />;
    }
    if (activeReport === 'export') {
        return <DataExportReport onBack={() => setActiveReport(null)} />;
    }

    return (
        <div className="space-y-4">
            <h1 className="text-2xl font-bold text-light-on-surface dark:text-dark-on-surface">{t('generateReports')}</h1>
             <p className="text-light-on-surface-secondary dark:text-dark-on-surface-secondary">
                {t('selectReportType')}
            </p>
            <div className="space-y-3">
                 <ReportCard title={t('personStatement')} description={t('generateStatementFor')} Icon={BookUser} onClick={() => setActiveReport('person')} />
                 <ReportCard title={t('cashFlowReport')} description={t('viewIncomeVsExpense')} Icon={BarChart3} onClick={() => setActiveReport('cashflow')} />
                 <ReportCard title={t('fullDataExport')} description={t('exportAllYourData')} Icon={Database} onClick={() => setActiveReport('export')} />
            </div>
        </div>
    );
};

export default ReportsScreen;
