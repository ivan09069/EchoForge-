import PriceFeed from './PriceFeed';

export default function Dashboard() {
  const holdings = [
    { symbol: 'BTC', label: 'Golden Star', amount: 1.2 },
    { symbol: 'ETH', label: 'Swirling Nebula', amount: 5.7 },
  ];

  return (
    <section aria-label="Portfolio overview" tabIndex={0}>
      <h2>Your Universe of Assets</h2>
      <ul>
        {holdings.map(asset => (
          <li key={asset.symbol} aria-label={`Asset: ${asset.symbol}, cosmic type: ${asset.label}, amount ${asset.amount}`}> 
            <span role="img" aria-label={asset.label}>
              {asset.symbol === 'BTC' ? '🌟' : '💫'}
            </span>
            <strong>{asset.symbol} ({asset.label})</strong>: {asset.amount}
          </li>
        ))}
      </ul>
      <PriceFeed symbols={holdings.map(h => h.symbol)} />
    </section>
  );
}
