# EchoForge 🔐

**Zero-leakage, biometric-secured portfolio tracker with FIDO2 authentication**

A privacy-focused cryptocurrency and finance portfolio tracker that keeps all your data encrypted locally on your device. No servers, no data leaks, complete control.

## ✨ Features

- 🔐 **FIDO2/WebAuthn Authentication** - Passwordless biometric login using fingerprint, face recognition, or security keys
- 🔒 **Client-Side Encryption** - All data encrypted using AES-GCM with Web Crypto API
- 💾 **IndexedDB Storage** - Encrypted local storage with no server dependencies
- 📊 **Real-time Price Feeds** - Live cryptocurrency price updates via WebSocket simulation
- 🎨 **Modern UI** - Clean, responsive interface built with Next.js and React
- ♿ **Accessibility First** - WCAG compliant with keyboard navigation and screen reader support
- 🌙 **Dark Mode Support** - Automatic dark/light theme based on system preferences

## 🏗️ Architecture

EchoForge follows a layered architecture focusing on security and privacy:

```
┌─────────────────────────────────────────┐
│     User Interface Layer (Next.js)      │
│  Landing • Login • Dashboard • Feeds    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Security Layer                  │
│  FIDO2 • AES-GCM • Web Crypto API       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│        Data Storage Layer                │
│  IndexedDB • Encrypted Storage • Cache   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│    External Services (Optional)          │
│  WebSocket Feeds • Price APIs            │
└─────────────────────────────────────────┘
```

See [architecture.svg](/public/architecture.svg) for detailed diagram.

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Modern browser with WebAuthn support (Chrome, Firefox, Safari, Edge)

### Installation

```bash
# Clone the repository
git clone https://github.com/ivan09069/EchoForge-.git
cd EchoForge-

# Install dependencies
npm install

# Run development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

### Building for Production

```bash
# Build optimized production bundle
npm run build

# Start production server
npm start
```

## 📁 Project Structure

```
EchoForge-/
├── pages/
│   ├── index.js          # Landing page
│   ├── login.js          # FIDO2 authentication page
│   ├── dashboard.js      # Portfolio dashboard
│   └── _app.js           # Next.js app wrapper
├── components/
│   ├── LoginFIDO2.js     # FIDO2 login component
│   ├── Dashboard.js      # Portfolio dashboard component
│   └── PriceFeed.js      # Real-time price feed component
├── lib/
│   ├── encrypt.js        # AES-GCM encryption utilities
│   ├── idb.js            # IndexedDB wrapper
│   └── websocket.js      # WebSocket connection manager
├── styles/
│   └── globals.css       # Global styles and themes
├── public/
│   └── architecture.svg  # System architecture diagram
├── __tests__/
│   └── smoke.test.js     # Basic smoke tests
└── .github/
    └── workflows/
        └── ci.yml        # GitHub Actions CI/CD
```

## 🔒 Security Features

### FIDO2/WebAuthn Authentication

EchoForge uses FIDO2 passwordless authentication:

- **Biometric login** - Use fingerprint or face recognition
- **Hardware keys** - Support for YubiKey and similar devices
- **Phishing resistant** - Credentials bound to origin
- **No passwords** - Private keys never leave your device

### Data Encryption

All sensitive data is encrypted before storage:

- **AES-GCM 256-bit** encryption using Web Crypto API
- **PBKDF2** key derivation with 100,000 iterations
- **Unique IVs** for each encryption operation
- **Client-side only** - Keys never transmitted

### Privacy

- ✅ **Zero server dependencies** for core functionality
- ✅ **No tracking or analytics**
- ✅ **No cookies or session storage** (except auth flag)
- ✅ **All data stays on your device**

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run linting
npm run lint
```

## 🔧 Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm test` - Run Jest tests
- `npm run lint` - Run ESLint

### Environment Variables

Create a `.env.local` file for environment-specific settings:

```env
# Optional: Configure external price feed API
NEXT_PUBLIC_PRICE_API_URL=https://api.example.com

# Optional: Enable debug logging
NEXT_PUBLIC_DEBUG=true
```

## 📊 Usage

### 1. Register Your Device

1. Navigate to `/login`
2. Click "Register New Device"
3. Follow biometric authentication prompts
4. Your device is now registered

### 2. Login

1. Click "Login with Biometrics"
2. Authenticate using fingerprint/face/security key
3. Access your encrypted portfolio

### 3. Manage Portfolio

1. Navigate to `/dashboard`
2. Add assets with purchase prices
3. View real-time valuations
4. Track profit/loss

## ♿ Accessibility

EchoForge is built with accessibility in mind:

- ✅ Keyboard navigation support
- ✅ Screen reader compatible
- ✅ ARIA labels and roles
- ✅ High contrast mode support
- ✅ Focus indicators
- ✅ Semantic HTML

We follow WCAG 2.1 Level AA guidelines.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for new features
- Follow existing code style
- Update documentation as needed
- Ensure all tests pass before submitting PR

## 🔐 Security Disclosure

If you discover a security vulnerability, please email security@echoforge.app instead of using the issue tracker.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Next.js team for the excellent framework
- FIDO Alliance for WebAuthn standards
- Web Crypto API for browser-based encryption
- IndexedDB for client-side storage

## 🗺️ Roadmap

- [ ] Multi-device sync via encrypted cloud backup
- [ ] Support for additional authentication methods
- [ ] Integration with real cryptocurrency exchanges
- [ ] Mobile app (React Native)
- [ ] Advanced portfolio analytics
- [ ] Export/import functionality
- [ ] Multi-currency support

## 📞 Support

- 📧 Email: support@echoforge.app
- 💬 Discord: [Join our community](https://discord.gg/echoforge)
- 🐛 Issues: [GitHub Issues](https://github.com/ivan09069/EchoForge-/issues)

## ⚠️ Disclaimer

EchoForge is provided as-is for educational and personal use. Always verify data accuracy and use at your own risk. Not financial advice.

---

Built with 💙 by the EchoForge team | [Website](https://echoforge.app) | [Documentation](https://docs.echoforge.app)
