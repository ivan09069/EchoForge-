import Link from 'next/link';

export default function Home() {
  return (
    <main className="cosmic-bg" aria-label="Welcome page" tabIndex={0}>
      <header>
        <h1 tabIndex={0} aria-label="EchoForge cosmic portfolio tracker">
          EchoForge – Secure your galaxy of assets
        </h1>
        <img
          src="/cosmic_background.svg"
          alt="Decorative nebula with stars and swirls"
          aria-hidden="true"
          style={{ width: '100%', maxWidth: 500, margin: '32px auto', display: 'block' }}
        />
      </header>
      <nav style={{ marginTop: "2rem" }} aria-label="Main navigation">
        <Link href="/login" legacyBehavior>
          <button className="cosmic-btn" aria-label="Stellar Login" tabIndex={0}>
            🌠 Stellar Login (Biometric)
          </button>
        </Link>
        <Link href="/dashboard" legacyBehavior>
          <button className="cosmic-btn" aria-label="Cosmic Dashboard" style={{ marginLeft: 12 }} tabIndex={0}>
            🪐 Cosmic Dashboard
          </button>
        </Link>
      </nav>
      <section aria-label="Cosmic description" tabIndex={0} style={{ marginTop: 32 }}>
        <p>
          Welcome, cosmic traveler! Experience galactic security with FIDO2 biometrics, encrypted storage, and real-time cosmic asset updates. 
          Our interface is fully accessible and responds to keyboard, sound, and touch cues.
        </p>
        <p>
          <strong>Options:</strong> Adjust colors, sound, or animation — press Tab to explore.
        </p>
      </section>
    </main>
  );
}