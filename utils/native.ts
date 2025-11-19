// This file simulates interaction with a native wrapper like Capacitor.
// It allows the web app to call for native features like status bar control and file system access.

// --- Types for Capacitor Plugins (for type safety) ---
declare global {
  interface Window {
    Capacitor?: any;
    CapacitorPlugins?: {
      StatusBar?: any;
      Filesystem?: any;
      Share?: any;    
  Dialog?: any;
    };
  }
}

/**
 * Updates the status bar style and color to match the app's theme.
 * @param isDark - Whether the dark theme is active.
 */
export const updateStatusBar = (isDark: boolean) => {
    // Check if the Capacitor StatusBar plugin is available
    const StatusBar = window.Capacitor?.Plugins?.StatusBar;
    if (!StatusBar) return;

    // 'DARK' for light backgrounds (dark text/icons), 'LIGHT' for dark backgrounds (light text/icons)
    const style = isDark ? 'LIGHT' : 'DARK';
    const color = isDark ? '#20202F' : '#FFFFFF'; // Matches header surface color

    StatusBar.setStyle({ style });
    StatusBar.setBackgroundColor({ color });

    // Also update the HTML meta theme-color for PWA contexts
    const themeColorMeta = document.querySelector('meta[name=theme-color]');
    if (themeColorMeta) {
      themeColorMeta.setAttribute('content', color);
    }
};

/**
 * Initiates a native sharing dialog.
 * @param options - The content to share.
 * @returns A promise that resolves to true if sharing was initiated, false otherwise.
 */
export const nativeShare = async (options: { title: string; text: string; dialogTitle?: string }): Promise<boolean> => {
    const Share = window.Capacitor?.Plugins?.Share;
    if (!Share) return false;

    try {
        await Share.share({
            title: options.title,
            text: options.text,
            dialogTitle: options.dialogTitle || 'Share',
        });
        return true;
    } catch (e) {
        console.error('Native share failed:', e);
        return false;
    }
};

/**
 * Shows a native alert dialog.
 * @param message - The message to display in the alert.
 */
export const showNativeAlert = async (message: string): Promise<void> => {
    const Dialog = window.Capacitor?.Plugins?.Dialog;
    if (!Dialog) {
        // Fallback for web browser testing
        alert(message);
        return;
    }

    await Dialog.alert({
        title: 'AlDeewan',
        message: message,
        buttonTitle: 'OK',
    });
};

/**
 * Saves a data blob to the device's filesystem (e.g., Downloads folder).
 * @param filename - The name of the file to save.
 * @param data - The Blob data to be saved.
 * @returns A promise that resolves to true on success, false on failure.
 */
export const saveFileToDevice = async (filename: string, data: Blob): Promise<boolean> => {
    // 1. Check if Capacitor is available
    const Filesystem = window.Capacitor?.Plugins?.Filesystem;
    if (!Filesystem) return false;

    try {
        // 2. Convert Blob to Base64
        const reader = new FileReader();
        const base64Data = await new Promise<string>((resolve, reject) => {
            reader.onloadend = () => {
                const res = reader.result as string;
                // Remove the data URL prefix (e.g., "data:text/csv;base64,")
                const base64 = res.includes(',') ? res.split(',')[1] : res;
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(data);
        });

        // 3. Write to the Documents Directory
        // 'DOCUMENTS' is the safest target on Android 10+ for file creation
        await Filesystem.writeFile({
            path: filename,
            data: base64Data,
            directory: 'DOCUMENTS', 
            recursive: true
        });
        
        // 4. Show success message
        await showNativeAlert(`File saved successfully to Documents.\n\nFilename: ${filename}`);
        return true;
    } catch (e: any) {
        console.error('Native file save failed:', e);
        await showNativeAlert(`Error saving file: ${e.message}`);
        return false;
    }
};


/**
 * Sets up a listener for the Android hardware back button.
 * The callback should perform a navigation action and prevent the default app exit.
 * @param callback The function to execute on back button press.
 */
export const handleAndroidBackButton = (callback: () => void) => {
    // In Capacitor, 'backButton' is an event on the App plugin
    const App = window.Capacitor?.Plugins?.App;
    if (!App) return;

    App.addListener('backButton', (e: { canGoBack: boolean }) => {
        // If the WebView can go back, let it. Otherwise, run our custom logic.
        if (!e.canGoBack) {
            callback();
        }
    });
};
