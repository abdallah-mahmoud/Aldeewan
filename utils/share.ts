import { Share } from '@capacitor/share';
import { Filesystem, Directory } from '@capacitor/filesystem';

export async function shareCsvFile(
  filename: string,
  title: string = 'Exported CSV',
  message: string = 'Here is your exported CSV file.'
) {
  try {
    const file = await Filesystem.readFile({
      path: filename,
      directory: Directory.Data,
    });

    const blob = new Blob([file.data], { type: 'text/csv;charset=utf-8' });
    const fileToShare = new File([blob], filename, { type: 'text/csv' });

    if (navigator.canShare && navigator.canShare({ files: [fileToShare] })) {
      await navigator.share({
        title,
        text: message,
        files: [fileToShare],
      });
    } else {
      alert('Sharing not supported on this device.');
    }
  } catch (err) {
    console.error('Share failed:', err);
    alert('Failed to share file: ' + (err as any).message);
  }
}