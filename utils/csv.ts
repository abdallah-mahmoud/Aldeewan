//
// File: utils/csv.ts
//

// utils/csv.ts
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem';
import { shareCsvFile } from './share';

export async function exportToCsv(
  filename: string,
  rows: Record<string, any>[],
  shouldShare: boolean = false,
  shareTitle: string = 'Exported CSV',
  shareMessage: string = 'Here is your exported CSV file.'
) {
  if (!rows || rows.length === 0) {
    alert("No data to export.");
    return;
  }

  const separator = ',';
  const keys = Object.keys(rows[0]);

  const csvContent = '\uFEFF' +
    keys.join(separator) + '\n' +
    rows.map(row => {
      return keys.map(k => {
        let cell = row[k] == null ? '' : row[k];
        cell = cell instanceof Date
          ? cell.toLocaleString()
          : cell.toString().replace(/"/g, '""');
        if (cell.search(/("|,|\n)/g) >= 0) {
          cell = `"${cell}"`;
        }
        return cell;
      }).join(separator);
    }).join('\n');

  try {
    await Filesystem.writeFile({
      path: filename,
      data: csvContent,
      directory: Directory.Data,
      encoding: Encoding.UTF8,
    });

    alert(`CSV saved to app storage as "${filename}"`);

    const result = await Filesystem.readdir({
      path: '',
      directory: Directory.Data,
    });
    console.log('Files in Directory.Data:', result.files);

    if (shouldShare) {
      await shareCsvFile(filename, shareTitle, shareMessage);
    }

  } catch (err) {
    console.error('Filesystem.writeFile error:', err);
    alert('Failed to save CSV: ' + (err as any).message);
  }
}