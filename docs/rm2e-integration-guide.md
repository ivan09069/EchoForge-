# RM²E Crypto Momentum Integration Example

This document provides a quick start guide for using the new RM²E crypto momentum tracking features.

## Basic Usage

### 1. Using the Hook Directly

```javascript
import useCryptoMomentum from '../hooks/useCryptoMomentum';

function MyComponent() {
  const { data, rm2eScores, isOnline } = useCryptoMomentum(
    ['bitcoin', 'ethereum', 'solana'],
    2500 // polling interval in ms
  );

  return (
    <div>
      <h2>Momentum Scores</h2>
      {rm2eScores.map(coin => (
        <div key={coin.id}>
          <h3>{coin.name} ({coin.symbol})</h3>
          <p>RM²E Score: {coin.rm2e}</p>
          <p>Signal: {coin.signal}</p>
          <p>Price: ${coin.price.toLocaleString()}</p>
          <p>24h Change: {coin.change24h.toFixed(2)}%</p>
        </div>
      ))}
    </div>
  );
}
```

### 2. Using the CryptoSparks Component

```javascript
import CryptoSparks from '../components/CryptoSparks';

function Dashboard() {
  return (
    <div>
      <h1>My Portfolio</h1>
      <CryptoSparks 
        symbols={['bitcoin', 'ethereum', 'solana', 'cardano']}
        pollingInterval={2500}
      />
    </div>
  );
}
```

## RM²E Score Interpretation

The RM²E algorithm returns a score that helps identify momentum opportunities:

### Score Ranges
- **< 50**: Stagnant - avoid
- **50-100**: Normal momentum - HOLD
- **100-150**: Heating up - BUY
- **150+**: Explosive - STRONG BUY
- **> 300**: Parabolic - consider taking profits

### Signal Badges
The component automatically generates signal badges:
- 🔥 **STRONG BUY**: RM²E > 150
- ✅ **BUY**: RM²E > 80
- ⏳ **HOLD**: RM²E ≤ 80

## Advanced Configuration

### Custom Polling Interval

```javascript
// Update every 5 seconds (be mindful of API rate limits)
<CryptoSparks 
  symbols={['bitcoin', 'ethereum']}
  pollingInterval={5000}
/>
```

### Tracking Specific Coins

Use CoinGecko coin IDs (not ticker symbols):

```javascript
const myCoins = [
  'bitcoin',      // BTC
  'ethereum',     // ETH
  'solana',       // SOL
  'cardano',      // ADA
  'polkadot',     // DOT
  'chainlink',    // LINK
];

<CryptoSparks symbols={myCoins} />
```

### Accessing Raw Data

```javascript
const { data, rm2eScores, isOnline } = useCryptoMomentum(['bitcoin']);

// data: Raw CoinGecko API response
console.log(data);

// rm2eScores: Calculated RM²E scores with components
console.log(rm2eScores[0].risk);      // Risk score
console.log(rm2eScores[0].momentum);  // Momentum score
console.log(rm2eScores[0].magic);     // Magic multiplier
console.log(rm2eScores[0].effort);    // Effort penalty

// isOnline: API connectivity status
console.log(isOnline ? 'Connected' : 'Offline');
```

## API Rate Limiting

The hook implements automatic exponential backoff:

- **Base delay**: 2500ms
- **On 429 error**: Delay doubles (2500ms → 5000ms → 10000ms → ...)
- **Max delay**: 60000ms (60 seconds)
- **Reset**: Returns to 2500ms on successful fetch

### CoinGecko Free Tier Limits
- 50 calls per minute
- Current default polling creates ~24 calls/min (safe margin)

## Error Handling

### Network Errors
When the API is unreachable:
- `isOnline` becomes `false`
- Component shows offline indicator (red gradient)
- Polling continues with exponential backoff

### Delisted Coins
Coins with `null` prices are automatically filtered out from results.

## Testing

Run tests with:

```bash
npm test -- useCryptoMomentum
npm test -- CryptoSparks
```

See `__tests__/useCryptoMomentum.test.js` and `__tests__/CryptoSparks.test.js` for examples.

## Dependencies

Required dependencies:
- `react` (hooks support)
- `axios` (HTTP requests)

The component uses inline styles, no additional CSS dependencies required.
