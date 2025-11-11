import Dashboard from '../components/Dashboard';

export default function DashboardPage() {
  return (
    <main className="cosmic-bg" aria-label="Dashboard page" tabIndex={0}>
      <header>
        <h1 aria-label="Your cosmic portfolio">🪐 Cosmic Dashboard</h1>
      </header>
      <section style={{ marginTop: 24 }}>
        <Dashboard />
      </section>
    </main>
  );
}
