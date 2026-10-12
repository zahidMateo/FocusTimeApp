/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./web/**/*.{html,js}",
    "./src/**/*.{js,ts,jsx,tsx,html}",
  ],
  theme: {
    extend: {
      colors: {
        focus: {
          primary: '#2563eb',
          'primary-soft': '#eff6ff',
          'primary-dark': '#004ac6',
          bg: '#faf8ff',
          canvas: '#f8fafc',
          surface: '#ffffff',
          'surface-container': '#eaedff',
          text: '#0f172a',
          'text-muted': '#475569',
          border: '#e2e8f0',
          'border-medium': '#cbd5e1',
          success: '#10b981',
          'success-soft': '#ecfdf5',
          destructive: '#ef4444',
          'destructive-soft': '#fee2e2',
        },
      },
      fontFamily: {
        outfit: ['Outfit', 'sans-serif'],
        inter: ['Inter', 'sans-serif'],
      },
      fontSize: {
        'display-timer': ['64px', { lineHeight: '72px', letterSpacing: '-0.03em', fontWeight: '600' }],
        'display-timer-mobile': ['56px', { lineHeight: '64px', letterSpacing: '-0.03em', fontWeight: '600' }],
        'headline-lg': ['32px', { lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '600' }],
        'headline-md': ['24px', { lineHeight: '32px', letterSpacing: '-0.01em', fontWeight: '600' }],
        'headline-sm': ['20px', { lineHeight: '28px', fontWeight: '600' }],
        'label-lg': ['14px', { lineHeight: '20px', letterSpacing: '0.01em', fontWeight: '600' }],
        'label-md': ['12px', { lineHeight: '16px', letterSpacing: '0.02em', fontWeight: '500' }],
        'label-sm': ['11px', { lineHeight: '14px', letterSpacing: '0.03em', fontWeight: '500' }],
      },
      borderRadius: {
        'card': '16px',
        'input': '12px',
        'checkbox': '6px',
      },
      boxShadow: {
        'level-1': '0px 2px 8px rgba(15, 23, 42, 0.04)',
        'level-2': '0px 8px 24px rgba(15, 23, 42, 0.08)',
        'nav-bottom': '0px -4px 16px rgba(15, 23, 42, 0.03)',
      },
      spacing: {
        'space-xs': '0.25rem',
        'space-sm': '0.5rem',
        'space-md': '1rem',
        'space-lg': '1.5rem',
        'space-xl': '2rem',
      },
    },
  },
  plugins: [],
};
