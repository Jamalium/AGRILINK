import './globals.css';

export const metadata = { title: 'AgriLink', description: 'Farmers to markets.' };

export default function RootLayout({ children }) {
  return <html lang="en"><body>{children}</body></html>;
}
