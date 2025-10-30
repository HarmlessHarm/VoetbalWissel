import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "VoetbalWissels - Football Team Management",
  description: "Manage your football team, create lineups, and track substitutions",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
