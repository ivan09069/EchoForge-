export default function LoginFIDO2() {
  // Placeholder for actual FIDO2 integration
  function handleLogin() {
    window.alert('Biometric login simulated: Cosmic gate unlocked. Welcome aboard!');
    window.location.href = '/dashboard';
  }
  return (
    <button
      className="cosmic-btn"
      aria-label="Login using biometrics"
      tabIndex={0}
      onClick={handleLogin}
    >
      🚀 Login with Biometrics
    </button>
  );
}
