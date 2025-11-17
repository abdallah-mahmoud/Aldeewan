// This file simulates interaction with a native wrapper like Capacitor.
// It allows the web app to call for native features like status bar control and file system access.

// --- Types for Capacitor Plugins (for type safety) ---
declare global {
  interface Window {
    Capacitor?: any;
    CapacitorPlugins?: {
      StatusBar?: any;
      Filesystem?: any;
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
 * Saves a data blob to the device's filesystem (e.g., Downloads folder).
 * @param filename - The name of the file to save.
 * @param data - The Blob data to be saved.
 * @returns A promise that resolves to true on success, false on failure.
 */
export const saveFileToDevice = async (filename: string, data: Blob): Promise<boolean> => {
    // Check if the Capacitor Filesystem plugin is available
    const Filesystem = window.Capacitor?.Plugins?.Filesystem;
    if (!Filesystem) return false;

    try {
        // Convert Blob to Base64
        const reader = new FileReader();
        const base64Data = await new Promise<string>((resolve, reject) => {
            reader.onloadend = () => resolve(reader.result as string);
            reader.onerror = reject;
            reader.readAsDataURL(data);
        });

        await Filesystem.writeFile({
            path: filename,
            data: base64Data,
            directory: 'DOWNLOADS', // Standard directory for user files
        });
        return true;
    } catch (e) {
        console.error('Native file save failed:', e);
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
