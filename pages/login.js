import Head from 'next/head'
import { useRouter } from 'next/router'
import LoginFIDO2 from '../components/LoginFIDO2'

export default function Login() {
  const router = useRouter()

  const handleLoginSuccess = async (credential) => {
    console.log('Login successful', credential)
    // Navigate to dashboard after successful login
    await router.push('/dashboard')
  }

  const handleLoginError = (error) => {
    console.error('Login failed', error)
    alert('Login failed. Please try again.')
  }

  return (
    <div className="container">
      <Head>
        <title>Login - EchoForge</title>
        <meta name="description" content="Secure biometric login with FIDO2" />
      </Head>

      <main className="main">
        <div className="login-container">
          <h1 className="title">
            Secure <span className="brand">Login</span>
          </h1>

          <p className="description">
            Use your biometric authentication to securely access your portfolio
          </p>

          <LoginFIDO2 
            onSuccess={handleLoginSuccess}
            onError={handleLoginError}
          />

          <div className="login-info">
            <h3>What is FIDO2?</h3>
            <p>
              FIDO2 is a passwordless authentication standard that uses biometrics
              (fingerprint, face recognition) or security keys to keep your account secure.
            </p>
            <ul>
              <li>No passwords to remember</li>
              <li>Resistant to phishing attacks</li>
              <li>Private keys never leave your device</li>
            </ul>
          </div>
        </div>
      </main>
    </div>
  )
}
