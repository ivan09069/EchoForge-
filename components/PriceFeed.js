import { useEffect, useState } from 'react';

export default function PriceFeed({ symbols }) {
  const [prices, setPrices] = useState({});

  useEffect(() => {
    // Simulated real-time prices
    const interval = setInterval(() => {
      setPrices(Object.fromEntries(symbols.map(sym => [sym, (Math.random() * 10000 + 200).toFixed(2)])));
      // In production, cosmic chime + speech can be triggered here
    }, 2500);
    return () => clearInterval(interval);
  }, [symbols]);

  return (
    <div aria-label="Real-time cosmic prices" tabIndex={0}>
      <h3>Real-Time Cosmic Prices</h3>
      <ul>
        {symbols.map(sym => (
          <li key={sym} aria-label={`Price for ${sym}: ${prices[sym] || 'Loading'}`}>  
            <strong>{sym}:</strong> {prices[sym] ? `${prices[sym]} universal credits` : 'Loading...'}
          </li>
        ))}
      </ul>
    </div>
  );
}
