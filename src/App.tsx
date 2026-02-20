import { Route, Routes } from "react-router-dom";
import { AppShell } from "./components/layout/AppShell";
import { HomePage } from "./pages/Home";

export function App() {
  return (
    <AppShell>
      <Routes>
        <Route element={<HomePage />} path="/" />
      </Routes>
    </AppShell>
  );
}
