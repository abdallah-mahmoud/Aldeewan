//
// File: utils/csv.ts
//

import { saveFileToDevice } from './native';

export async function exportToCsv(filename: string, rows: object[]) {
    if (!rows || rows.length === 0) {
        // In a native context, alert can be disruptive. console.warn is better.
        console.warn("No data to export.");
        return;
    }
    const separator = ',';
    const keys = Object.keys(rows[0]);
    
    // Add UTF-8 BOM for Excel compatibility with non-English characters
    const csvContent = '\uFEFF' +
        keys.join(separator) +
        '\n' +
        rows.map(row => {
            return keys.map(k => {
                let cell = (row as any)[k] === null || (row as any)[k] === undefined ? '' : (row as any)[k];
                cell = cell instanceof Date
                    ? cell.toLocaleString()
                    : cell.toString().replace(/"/g, '""');
                if (cell.search(/("|,|\n)/g) >= 0) {
                    cell = `"${cell}"`;
                }
                return cell;
            }).join(separator);
        }).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    
    // --- START OF CHANGES ---

    // 1. TRY NATIVE SAVE FIRST
    const nativeSaveSuccess = await saveFileToDevice(filename, blob);

    // 2. FALLBACK TO WEB DOWNLOAD if native save fails or is not available
    if (!nativeSaveSuccess) {
        const link = document.createElement('a');
        if (link.download !== undefined) {
            const url = URL.createObjectURL(blob);
            link.setAttribute('href', url);
            link.setAttribute('download', filename);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
    
    // --- END OF CHANGES ---
}