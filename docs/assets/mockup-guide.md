# EchoForge Asset & Mockup Guide

**Purpose**: Specifications for creating screenshots, mockups, and branding assets  
**Target**: Designers, contributors, and marketing team  
**Last Updated**: November 2024

---

## Table of Contents
1. [Overview](#overview)
2. [Screenshot Specifications](#screenshot-specifications)
3. [Branding Guidelines](#branding-guidelines)
4. [Demo Video Script](#demo-video-script)
5. [Asset Naming Conventions](#asset-naming-conventions)
6. [Design Tools & Resources](#design-tools--resources)

---

## Overview

EchoForge requires high-quality visual assets for:
- README.md hero section
- Social media sharing (Open Graph)
- ProductHunt launch gallery
- Documentation illustrations
- Marketing materials

All assets should communicate **security, privacy, and cosmic theme**.

---

## Screenshot Specifications

### 1. Dashboard Preview (Primary Hero)

**Filename**: `dashboard-preview.png`  
**Dimensions**: 1200x630px (optimal for Open Graph)  
**Format**: PNG (for transparency), JPEG alternative for smaller file size  
**DPI**: 72 (web-optimized)

**Content Requirements**:
- [ ] Main portfolio overview (total value, asset allocation)
- [ ] At least 3 asset rows (BTC, ETH, one stock/real estate)
- [ ] Real-time price indicators (green/red arrows)
- [ ] Cosmic emoji theme (🌟, 💫, 🚀)
- [ ] Accessible UI (high contrast, large fonts)
- [ ] Dark mode aesthetic (matches privacy theme)

**Key UI Elements to Show**:
```
┌────────────────────────────────────────────────────┐
│  🔐 EchoForge                      [Profile] [🔒]   │
├────────────────────────────────────────────────────┤
│                                                    │
│  Your Universe of Assets                          │
│  Total Value: $287,450.32  ▲ +5.2% (24h)         │
│                                                    │
│  🌟 BTC (Golden Star)                             │
│  1.2000 BTC × $43,250 = $51,900.00  ▲ +2.3%      │
│                                                    │
│  💫 ETH (Swirling Nebula)                         │
│  5.7000 ETH × $2,280 = $12,996.00  ▼ -1.2%       │
│                                                    │
│  📈 AAPL (Quantum Tree)                           │
│  150 shares × $178.50 = $26,775.00  ▲ +0.8%      │
│                                                    │
│  [Real-Time Cosmic Prices]                        │
│  Last updated: 2 seconds ago                      │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Design Notes**:
- Use **#1a1a2e** (dark navy) for background
- Use **#0f3460** (darker blue) for cards
- Use **#16213e** (medium blue) for borders
- Accent colors: **#00d9ff** (cyan), **#7c4dff** (purple), **#00ff88** (green)
- Font: Inter or Roboto (sans-serif, high readability)

**Privacy Indicators**:
- Add small 🔒 icon in header (indicates local storage)
- Include tooltip: "Your data never leaves this device"

---

### 2. FIDO2 Authentication Flow

**Filename**: `fido2-auth-flow.png`  
**Dimensions**: 1200x630px  
**Format**: PNG

**Content Requirements**:
- [ ] Login screen with biometric prompt
- [ ] FIDO2 button (🚀 Login with Biometrics)
- [ ] Browser security indicators (padlock, domain)
- [ ] Optional: Fingerprint/Face ID animation mockup

**Storyboard** (3-panel layout):
```
┌────────────┬────────────┬────────────┐
│  Panel 1   │  Panel 2   │  Panel 3   │
│            │            │            │
│  Login     │  Biometric │  Dashboard │
│  Button    │  Prompt    │  Unlocked  │
│  [🚀]      │  [👆/😐]   │  [✅]      │
└────────────┴────────────┴────────────┘
```

**Panel 1: Initial Login Screen**
```
┌─────────────────────────────────────┐
│                                     │
│         🔐 EchoForge                │
│    Zero-Knowledge Portfolio         │
│                                     │
│  [🚀 Login with Biometrics]         │
│                                     │
│  No passwords. No phishing.         │
│  No surveillance.                   │
│                                     │
└─────────────────────────────────────┘
```

**Panel 2: Browser Biometric Prompt**
```
┌─────────────────────────────────────┐
│  🔐 echoforge.io wants to use       │
│  your security key                  │
│                                     │
│  [Fingerprint Icon]                 │
│  Touch your fingerprint sensor      │
│                                     │
│  [Cancel]              [Approve]    │
└─────────────────────────────────────┘
```

**Panel 3: Success State**
```
┌─────────────────────────────────────┐
│  ✅ Authentication Successful        │
│                                     │
│  Cosmic gate unlocked!              │
│  Welcome aboard, explorer.          │
│                                     │
│  [Redirecting to Dashboard...]      │
└─────────────────────────────────────┘
```

**Technical Accuracy**:
- Show actual browser WebAuthn prompt (Chrome/Firefox/Safari)
- Include URL bar with HTTPS padlock
- Use real device names (e.g., "Touch ID", "Windows Hello")

---

### 3. Price Feed Interface

**Filename**: `price-feed-interface.png`  
**Dimensions**: 1200x630px  
**Format**: PNG

**Content Requirements**:
- [ ] Real-time price updates (simulated)
- [ ] Multiple assets (min 5)
- [ ] Timestamp indicator ("Last updated: X seconds ago")
- [ ] Visual indicators (green ▲, red ▼)
- [ ] Cosmic theme integration

**Layout**:
```
┌────────────────────────────────────────────────────┐
│  Real-Time Cosmic Prices                   [🔄]    │
├────────────────────────────────────────────────────┤
│                                                    │
│  BTC: $43,250.00  ▲ +2.3%  (Updated 2s ago)       │
│  ──────────────────────────────────────────────    │
│  │█████████████████░░░░░░░░│ 24h Range           │
│                                                    │
│  ETH: $2,280.50   ▼ -1.2%  (Updated 3s ago)       │
│  ──────────────────────────────────────────────    │
│  │██████████████░░░░░░░░░░░│ 24h Range           │
│                                                    │
│  AAPL: $178.50    ▲ +0.8%  (Updated 1s ago)       │
│  ──────────────────────────────────────────────    │
│  │████████████████████░░░░░│ 24h Range           │
│                                                    │
│  [🔊 Enable Audio Alerts]                          │
│  [♿ Enable Speech Announcements]                  │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Animation (Optional)**:
- GIF showing prices updating in real-time
- Duration: 5 seconds, looping
- Show 2-3 price changes

**Accessibility Indicators**:
- ARIA labels visible on hover
- Screen reader icon (♿)
- Keyboard navigation hints (Tab, Arrow keys)

---

### 4. Security Architecture Diagram

**Filename**: `security-architecture-diagram.png`  
**Dimensions**: 1200x800px (taller for vertical flow)  
**Format**: PNG with transparent background

**Content Requirements**:
- [ ] Three-layer defense model
- [ ] Data flow arrows
- [ ] Technology labels (AES-256, PBKDF2, FIDO2)
- [ ] Threat mitigation notes

**Diagram Structure**:
```
┌──────────────────────────────────────────────────┐
│  USER                                            │
│  👤 Fingerprint / Face ID                        │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│  LAYER 1: FIDO2 BIOMETRIC AUTH                   │
│  • WebAuthn standard (W3C)                       │
│  • Device-bound keys                             │
│  • Phishing-resistant                            │
│  🛡️ PREVENTS: Credential theft, phishing         │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│  LAYER 2: CLIENT-SIDE ENCRYPTION                 │
│  • AES-256-GCM (NIST approved)                   │
│  • PBKDF2 (600k iterations)                      │
│  • Web Crypto API                                │
│  🛡️ PREVENTS: Data interception, server breach   │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│  LAYER 3: OFFLINE STORAGE                        │
│  • IndexedDB (browser-native)                    │
│  • No cloud transmission                         │
│  • Origin-isolated                               │
│  🛡️ PREVENTS: Network attacks, cloud breaches    │
└──────────────────────────────────────────────────┘
```

**Color Coding**:
- Layer 1: Blue (#00d9ff)
- Layer 2: Purple (#7c4dff)
- Layer 3: Green (#00ff88)
- User: Yellow (#ffeb3b)

**Icon Usage**:
- 🔐 for encryption
- 👤 for user
- 🛡️ for protection
- ⚠️ for threats (crossed out)

---

### 5. Competitor Comparison Table (Infographic)

**Filename**: `competitor-comparison-infographic.png`  
**Dimensions**: 1200x1600px (tall, for scrolling)  
**Format**: PNG

**Content**: Visual representation of competitor comparison table from docs

**Key Metrics to Highlight**:
- Privacy score (pie charts or stars)
- Cost (bar chart)
- Features (checkmark grid)
- Security (shield icons)

**Design Style**: Clean, minimalist, data-focused (inspired by Stripe or Linear)

---

## Branding Guidelines

### Color Palette

**Primary Colors**:
```css
--cosmic-dark:     #1a1a2e;  /* Background */
--cosmic-darker:   #0f3460;  /* Cards */
--cosmic-medium:   #16213e;  /* Borders */
```

**Accent Colors**:
```css
--cosmic-cyan:     #00d9ff;  /* Links, highlights */
--cosmic-purple:   #7c4dff;  /* CTAs, premium */
--cosmic-green:    #00ff88;  /* Success, positive */
--cosmic-red:      #ff4757;  /* Errors, negative */
--cosmic-yellow:   #ffa502;  /* Warnings, alerts */
```

**Text Colors**:
```css
--text-primary:    #ffffff;  /* Headings */
--text-secondary:  #b8b8d1;  /* Body text */
--text-muted:      #7a7a96;  /* Labels */
```

### Typography

**Font Stack**:
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 
             Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
```

**Sizes**:
- **Heading 1**: 48px, bold (hero titles)
- **Heading 2**: 36px, semibold (section titles)
- **Heading 3**: 24px, semibold (subsections)
- **Body**: 16px, regular (paragraphs)
- **Small**: 14px, regular (labels, captions)

**Line Height**:
- Headings: 1.2
- Body: 1.6 (accessibility-optimized)

### Logo Concept

**Text-based logo**:
```
🔐 EchoForge
```

**Variations**:
- Full: "🔐 EchoForge" (with emoji)
- Short: "EF" monogram
- Text-only: "EchoForge" (sans emoji, for formal contexts)

**Logo Usage**:
- Always use **Inter Bold** or **Roboto Bold**
- Lock icon (🔐) is non-negotiable (brand identity)
- Color: White (#ffffff) on dark, Dark (#1a1a2e) on light

### Iconography

**Cosmic Theme Icons**:
- 🌟 = Bitcoin, gold, premium
- 💫 = Ethereum, nebula, movement
- 🚀 = Launch, speed, innovation
- 🔐 = Security, encryption, privacy
- 🔒 = Locked, protected
- 🔓 = Unlocked, accessible
- 📊 = Analytics, charts
- ⚡ = Speed, real-time
- 🛡️ = Protection, security

**Accessibility Note**: Always provide text alternatives for emoji (aria-label)

---

## Demo Video Script

**Title**: "EchoForge: Privacy-First Portfolio Tracking in 2 Minutes"  
**Duration**: 2:00 (120 seconds)  
**Format**: 1920x1080 (YouTube/Vimeo), 1080x1920 (TikTok/Reels)  
**Voiceover**: Optional (closed captions mandatory)

### Script Breakdown

**[0:00-0:15] Hook (15 seconds)**
```
VISUAL: Animated text on dark background
TEXT: "Mint sells your data. Personal Capital charges fees. 
       CoinTracker costs $999/year."

VISUAL: Red X appears over each logo

TEXT: "There's a better way."

VISUAL: EchoForge logo fades in with 🔐 animation
```

---

**[0:15-0:30] Problem (15 seconds)**
```
VISUAL: Screen recording of typical portfolio tracker
VOICEOVER: "Traditional portfolio trackers store your financial 
            data on their servers. One breach = game over."

VISUAL: Simulated data breach news headline
HEADLINE: "Major Portfolio Tracker Hacked: 2M Users Affected"

VISUAL: Fade to black
```

---

**[0:30-0:50] Solution (20 seconds)**
```
VISUAL: EchoForge login screen appears
TEXT: "EchoForge: Zero-knowledge architecture"

VISUAL: Click "🚀 Login with Biometrics" button
VISUAL: Browser fingerprint prompt (realistic mockup)
VISUAL: Dashboard unlocks with smooth animation

VOICEOVER: "Your data is encrypted on YOUR device. We literally 
            can't see it, even if we wanted to."

VISUAL: Highlight IndexedDB in browser DevTools
```

---

**[0:50-1:10] Features (20 seconds)**
```
VISUAL: Dashboard tour (screen recording)
- Scroll through asset list (BTC, ETH, stocks)
- Show real-time price updates (green/red arrows)
- Click "Add Asset" button (modal appears)
- Enter custom holding (real estate, NFT)

TEXT OVERLAYS:
• "5000+ assets supported"
• "Real-time price feeds"
• "Offline-first design"
• "Accessibility-focused"
```

---

**[1:10-1:30] Security (20 seconds)**
```
VISUAL: Animated security architecture diagram
VISUAL: Three layers appear sequentially:
1. FIDO2 biometric auth (animated fingerprint)
2. AES-256-GCM encryption (lock icon + data flow)
3. Offline storage (browser icon + shield)

VOICEOVER: "Three layers of defense. FIDO2 biometric auth, 
            AES-256 encryption, and offline storage."

TEXT: "Open source. MIT License. Community-auditable."
```

---

**[1:30-1:50] Comparison (20 seconds)**
```
VISUAL: Side-by-side comparison table (animated)

| Feature          | EchoForge | Competitors |
|------------------|-----------|-------------|
| Data Privacy     | ✅ 10/10  | ❌ 2-5/10   |
| Cost             | ✅ FREE   | ❌ $59-999  |
| Open Source      | ✅ MIT    | ❌ Proprietary |
| Biometric Auth   | ✅ FIDO2  | ❌ Password |

VOICEOVER: "EchoForge vs the rest. No contest."
```

---

**[1:50-2:00] CTA (10 seconds)**
```
VISUAL: GitHub repository page (quick tour)
VISUAL: Scroll through README stars, issues, PRs

TEXT: "⭐ Star on GitHub: github.com/ivan09069/EchoForge"
TEXT: "📖 Docs: ivan09069.github.io/EchoForge"
TEXT: "🚀 Try Demo: [demo link]"

VOICEOVER: "Start tracking privately today. It's free. Forever."

VISUAL: EchoForge logo + lock animation (outro)
```

---

### Video Production Notes

**Equipment**:
- Screen recording: OBS Studio (free) or ScreenFlow (Mac)
- Editing: DaVinci Resolve (free) or Adobe Premiere Pro
- Graphics: Figma (free) or Canva Pro
- Voiceover: Blue Yeti mic or smartphone with Rode app

**Style**:
- Dark mode aesthetics throughout
- Smooth transitions (fade, slide, zoom)
- Subtle background music (royalty-free from Epidemic Sound)
- Closed captions (mandatory for accessibility)
- 60 FPS (for smooth animations)

**Distribution**:
- YouTube (main channel)
- Twitter (native video, 2:20 max)
- LinkedIn (native video, caption emphasis)
- ProductHunt (embedded in gallery)
- GitHub README (GIF preview, link to full video)

---

## Asset Naming Conventions

### File Naming Format
```
[type]-[description]-[size].[format]

Examples:
- screenshot-dashboard-1200x630.png
- diagram-security-architecture-1200x800.png
- video-demo-2min-1920x1080.mp4
- logo-full-color-512x512.png
- icon-biometric-auth-64x64.svg
```

### Directory Structure
```
docs/assets/
├── screenshots/
│   ├── dashboard-preview.png
│   ├── fido2-auth-flow.png
│   └── price-feed-interface.png
├── diagrams/
│   ├── security-architecture-diagram.png
│   └── competitor-comparison-infographic.png
├── videos/
│   ├── demo-2min-youtube.mp4
│   └── demo-30sec-social.mp4
├── logos/
│   ├── echoforge-logo-full.png
│   ├── echoforge-logo-icon-only.png
│   └── echoforge-logo-monochrome.svg
└── social/
    ├── og-image-1200x630.png (Open Graph)
    ├── twitter-card-1200x675.png
    └── linkedin-banner-1584x396.png
```

### Version Control
- Use Git LFS for large binary files (videos, high-res images)
- Keep PNG/JPEG under 500KB (use TinyPNG or ImageOptim)
- Provide both light and dark mode versions when applicable
- Include source files (Figma, Sketch, PSD) in separate `/src` folder

---

## Design Tools & Resources

### Recommended Tools

**Screen Recording**:
- [OBS Studio](https://obsproject.com/) - Free, cross-platform
- [Loom](https://www.loom.com/) - Quick screen + webcam recording
- [ScreenFlow](https://www.telestream.net/screenflow/) - Mac only, $169

**Design & Mockups**:
- [Figma](https://www.figma.com/) - Free tier available, browser-based
- [Canva Pro](https://www.canva.com/pro/) - $12.99/month, templates included
- [Sketch](https://www.sketch.com/) - Mac only, $99/year

**Diagram Tools**:
- [Excalidraw](https://excalidraw.com/) - Free, hand-drawn style
- [Lucidchart](https://www.lucidchart.com/) - Professional diagrams
- [draw.io](https://app.diagrams.net/) - Free, open source

**Image Optimization**:
- [TinyPNG](https://tinypng.com/) - Compress PNG/JPEG
- [ImageOptim](https://imageoptim.com/) - Mac batch optimization
- [Squoosh](https://squoosh.app/) - Google's web-based optimizer

**Video Editing**:
- [DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) - Free, professional-grade
- [iMovie](https://www.apple.com/imovie/) - Mac/iOS, free
- [Kdenlive](https://kdenlive.org/) - Open source, Linux/Windows/Mac

### Free Asset Libraries

**Icons**:
- [Heroicons](https://heroicons.com/) - MIT License, React-optimized
- [Feather Icons](https://feathericons.com/) - MIT License, minimalist
- [Phosphor Icons](https://phosphoricons.com/) - MIT License, 6000+ icons

**Fonts**:
- [Inter](https://rsms.me/inter/) - Open font license, UI-optimized
- [Roboto](https://fonts.google.com/specimen/Roboto) - Apache 2.0
- [Poppins](https://fonts.google.com/specimen/Poppins) - Open Font License

**Stock Photos** (if needed):
- [Unsplash](https://unsplash.com/) - Free, high quality
- [Pexels](https://www.pexels.com/) - Free, no attribution required
- [Pixabay](https://pixabay.com/) - Free, CC0 license

**Music** (for videos):
- [Epidemic Sound](https://www.epidemicsound.com/) - $15/month, huge library
- [YouTube Audio Library](https://studio.youtube.com/channel/UC/music) - Free
- [Free Music Archive](https://freemusicarchive.org/) - CC-licensed

---

## Contribution Guidelines

### Submitting New Assets

1. **Create asset** following specifications above
2. **Optimize file size** (use TinyPNG, ImageOptim)
3. **Add to correct directory** (see naming conventions)
4. **Update this guide** if adding new asset type
5. **Submit PR** with preview images in description

### Asset Review Checklist

- [ ] Meets dimensional requirements
- [ ] File size under 500KB (unless video)
- [ ] Follows branding guidelines (colors, fonts)
- [ ] Includes accessibility metadata (alt text)
- [ ] Optimized for web (compression, format)
- [ ] Source files included (Figma, Sketch)
- [ ] Git LFS used for large files (>5MB)

---

## Frequently Asked Questions

**Q: Can I use EchoForge assets in my blog post?**  
A: Yes! MIT License allows reuse. Attribution appreciated but not required.

**Q: What if I don't have design skills?**  
A: Use Canva templates or request help in GitHub Discussions.

**Q: Can I create memes with EchoForge branding?**  
A: Absolutely! Share them with #EchoForge tag.

**Q: What about video subtitles?**  
A: Use [Rev.com](https://www.rev.com/) ($1.25/min) or YouTube auto-captions (free but less accurate).

**Q: How do I create animated GIFs?**  
A: Use [Gifox](https://gifox.io/) (Mac), [ScreenToGif](https://www.screentogif.com/) (Windows), or [Peek](https://github.com/phw/peek) (Linux).

---

## Roadmap

### Current Status (v1.0)
- [x] Screenshot specifications defined
- [x] Branding guidelines established
- [x] Demo video script written
- [ ] Assets created (need designer help!)

### Upcoming
- [ ] Hire designer (via GitHub Sponsors or Upwork)
- [ ] Create all screenshots (Week 1)
- [ ] Produce demo video (Week 2)
- [ ] Launch social media graphics (Week 3)
- [ ] Update README with assets (Week 4)

### Future
- [ ] Animated logo (Lottie files)
- [ ] Dark/light mode asset variants
- [ ] Localized assets (Spanish, Chinese, etc.)
- [ ] Press kit (for journalists)

---

**Document Maintainer**: Ivan (github0906@gmail.com)  
**Design Lead**: [Looking for volunteer designer!]  
**Last Updated**: November 2024

*Need help creating assets? Open a [GitHub Issue](https://github.com/ivan09069/EchoForge/issues) with "design" label.*
