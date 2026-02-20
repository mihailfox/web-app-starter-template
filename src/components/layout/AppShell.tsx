import type { PropsWithChildren } from "react";

export function AppShell({ children }: PropsWithChildren) {
  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>Web App Starter</h1>
      </header>
      <main className="app-main">{children}</main>
    </div>
  );
}
