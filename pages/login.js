import LoginFIDO2 from '../components/LoginFIDO2';

export default function LoginPage() {
  return (
    <main className="cosmic-bg" aria-label="Login page" tabIndex={0}>
      <header>
        <h1 aria-label="Cosmic biometric login">🌠 Stellar Login</h1>
      </header>
      <section style={{ marginTop: 24 }}>
        <LoginFIDO2 />
      </section>
      <section aria-label="Login information" style={{ marginTop: 40 }}>
        <p>This secure portal uses FIDO2 biometrics. Accessible—screen reader and keyboard friendly. Audio and tactile feedback provided for all major events. </p>
      </section>
    </main>
  );
}
