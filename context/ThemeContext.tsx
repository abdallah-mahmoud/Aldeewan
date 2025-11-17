import React, { createContext, useState, useContext, useEffect } from 'react';
import { updateStatusBar } from '../utils/native';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window !== 'undefined') {
      const storedTheme = localStorage.getItem('theme') as Theme | null;
      return storedTheme || 'system';
    }
    return 'system';
  });

  useEffect(() => {
    const root = window.document.documentElement;
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)');

    const applyTheme = (t: Theme) => {
      localStorage.setItem('theme', t);
      const isDark = t === 'dark' || (t === 'system' && systemPrefersDark.matches);
      
      if (isDark) {
        root.classList.add('dark');
      } else {
        root.classList.remove('dark');
      }
      // Update native status bar
      updateStatusBar(isDark);
    };

    applyTheme(theme);

    const mediaQueryListener = (e: MediaQueryListEvent) => {
      if (theme === 'system') {
        const isDark = e.matches;
        if (isDark) {
            root.classList.add('dark');
        } else {
            root.classList.remove('dark');
        }
        // Update native status bar on system theme change
        updateStatusBar(isDark);
      }
    };

    systemPrefersDark.addEventListener('change', mediaQueryListener);
    
    return () => {
      systemPrefersDark.removeEventListener('change', mediaQueryListener);
    };
  }, [theme]);

  const value = { theme, setTheme };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
