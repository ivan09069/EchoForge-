import Head from 'next/head'
import Link from 'next/link'

export default function Home() {
  return (
    <div className="container">
      <Head>
        <title>EchoForge - Secure Portfolio Tracker</title>
        <meta name="description" content="Zero-leakage, biometric-secured portfolio tracker" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="main">
        <h1 className="title">
          Welcome to <span className="brand">EchoForge</span>
        </h1>

        <p className="description">
          Zero-leakage, biometric-secured portfolio tracker
        </p>

        <div className="features">
          <div className="feature-card">
            <h2>🔐 FIDO2 Authentication</h2>
            <p>Secure biometric login with WebAuthn/FIDO2 support</p>
          </div>

          <div className="feature-card">
            <h2>🔒 Local Encryption</h2>
            <p>All data encrypted locally using AES-GCM encryption</p>
          </div>

          <div className="feature-card">
            <h2>📊 Real-time Data</h2>
            <p>Live price feeds for your portfolio tracking</p>
          </div>

          <div className="feature-card">
            <h2>💾 IndexedDB Storage</h2>
            <p>Encrypted local storage with no server dependencies</p>
          </div>
        </div>

        <div className="cta">
          <Link href="/login" className="button primary">
            Get Started
          </Link>
          <Link href="/dashboard" className="button secondary">
            View Demo Dashboard
          </Link>
        </div>

        <div className="architecture">
          <h2>System Architecture</h2>
          <img src="/architecture.svg" alt="EchoForge Architecture" className="architecture-diagram" />
        </div>
      </main>

      <footer className="footer">
        <p>EchoForge - Built with security and privacy in mind</p>
      </footer>
    </div>
  )
}
