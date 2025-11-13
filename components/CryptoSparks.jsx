import useCryptoMomentum from '../hooks/useCryptoMomentum';

/**
 * Production-grade crypto momentum tracking UI with RM²E scoring
 * Features: offline indicator, ranked display, color-coded changes, signal badges
 */
export default function CryptoSparks({ symbols, pollingInterval = 2500 }) {
  const { rm2eScores, isOnline } = useCryptoMomentum(symbols, pollingInterval);

  return (
    <div
      style={{
        background: isOnline
          ? 'linear-gradient(135deg, #1a1a2e, #16213e)'
          : 'linear-gradient(135deg, #2e1a1a, #3e1621)',
        borderRadius: '12px',
        padding: '24px',
        color: '#fff',
        fontFamily: 'system-ui, -apple-system, sans-serif',
        transition: 'background 0.5s ease',
      }}
      role="region"
      aria-label="Crypto momentum tracker"
    >
      {/* Header with offline indicator */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '20px',
        }}
      >
        <h2 style={{ margin: 0, fontSize: '24px', fontWeight: 'bold' }}>
          ⚡ Crypto Momentum Tracker
        </h2>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            fontSize: '14px',
            fontWeight: '600',
          }}
        >
          <span
            style={{
              width: '10px',
              height: '10px',
              borderRadius: '50%',
              backgroundColor: isOnline ? '#00ff88' : '#ff4444',
              boxShadow: isOnline
                ? '0 0 10px rgba(0, 255, 136, 0.6)'
                : '0 0 10px rgba(255, 68, 68, 0.6)',
            }}
            aria-hidden="true"
          />
          <span>{isOnline ? 'ONLINE' : 'OFFLINE'}</span>
        </div>
      </div>

      {/* Ranked list display */}
      {rm2eScores.length === 0 ? (
        <div
          style={{
            textAlign: 'center',
            padding: '40px 20px',
            color: 'rgba(255, 255, 255, 0.6)',
          }}
        >
          Loading momentum data...
        </div>
      ) : (
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
          }}
        >
          {rm2eScores.map((coin, index) => (
            <div
              key={coin.id}
              style={{
                background: 'rgba(255, 255, 255, 0.05)',
                borderRadius: '8px',
                padding: '16px',
                display: 'flex',
                flexDirection: 'column',
                gap: '8px',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
              }}
              role="article"
              aria-label={`${coin.name} momentum data`}
            >
              {/* Coin header with rank */}
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'flex-start',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span
                    style={{
                      fontSize: '18px',
                      fontWeight: 'bold',
                      color: 'rgba(255, 255, 255, 0.5)',
                      minWidth: '30px',
                    }}
                  >
                    #{index + 1}
                  </span>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '18px', fontWeight: 'bold' }}>
                      {coin.name}
                    </h3>
                    <p
                      style={{
                        margin: 0,
                        fontSize: '14px',
                        color: 'rgba(255, 255, 255, 0.6)',
                      }}
                    >
                      {coin.symbol} • ${coin.price.toLocaleString()}
                    </p>
                  </div>
                </div>

                {/* Signal badge */}
                <div
                  style={{
                    padding: '6px 12px',
                    borderRadius: '6px',
                    fontSize: '12px',
                    fontWeight: 'bold',
                    backgroundColor:
                      coin.signal === '🔥 STRONG BUY'
                        ? 'rgba(255, 107, 0, 0.2)'
                        : coin.signal === '✅ BUY'
                        ? 'rgba(0, 255, 136, 0.2)'
                        : 'rgba(255, 255, 255, 0.1)',
                    border: `1px solid ${
                      coin.signal === '🔥 STRONG BUY'
                        ? 'rgba(255, 107, 0, 0.5)'
                        : coin.signal === '✅ BUY'
                        ? 'rgba(0, 255, 136, 0.5)'
                        : 'rgba(255, 255, 255, 0.3)'
                    }`,
                    whiteSpace: 'nowrap',
                  }}
                  role="status"
                  aria-label={`Signal: ${coin.signal}`}
                >
                  {coin.signal}
                </div>
              </div>

              {/* Metrics row */}
              <div
                style={{
                  display: 'flex',
                  flexWrap: 'wrap',
                  gap: '16px',
                  fontSize: '14px',
                }}
              >
                <div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>RM²E: </span>
                  <span style={{ fontWeight: 'bold', fontSize: '16px' }}>
                    {coin.rm2e.toFixed(2)}
                  </span>
                </div>
                <div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>24h: </span>
                  <span
                    style={{
                      color: coin.change24h >= 0 ? '#00ff88' : '#ff4444',
                      fontWeight: 'bold',
                    }}
                  >
                    {coin.change24h >= 0 ? '+' : ''}
                    {coin.change24h.toFixed(2)}%
                  </span>
                </div>
                <div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>7d: </span>
                  <span
                    style={{
                      color: coin.change7d >= 0 ? '#00ff88' : '#ff4444',
                      fontWeight: 'bold',
                    }}
                  >
                    {coin.change7d >= 0 ? '+' : ''}
                    {coin.change7d.toFixed(2)}%
                  </span>
                </div>
                <div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>
                    Market Cap:{' '}
                  </span>
                  <span style={{ fontWeight: '500' }}>
                    ${(coin.marketCap / 1e9).toFixed(2)}B
                  </span>
                </div>
              </div>

              {/* RM²E breakdown (collapsible details) */}
              <details style={{ fontSize: '12px', marginTop: '4px' }}>
                <summary
                  style={{
                    cursor: 'pointer',
                    color: 'rgba(255, 255, 255, 0.5)',
                    userSelect: 'none',
                  }}
                >
                  Show RM²E breakdown
                </summary>
                <div
                  style={{
                    marginTop: '8px',
                    padding: '8px',
                    background: 'rgba(0, 0, 0, 0.2)',
                    borderRadius: '4px',
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))',
                    gap: '8px',
                  }}
                >
                  <div>
                    <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>Risk: </span>
                    {coin.risk}
                  </div>
                  <div>
                    <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>
                      Momentum:{' '}
                    </span>
                    {coin.momentum}
                  </div>
                  <div>
                    <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>Magic: </span>
                    {coin.magic}x
                  </div>
                  <div>
                    <span style={{ color: 'rgba(255, 255, 255, 0.6)' }}>
                      Effort:{' '}
                    </span>
                    {coin.effort}
                  </div>
                </div>
              </details>
            </div>
          ))}
        </div>
      )}

      {/* Footer with refresh info */}
      <div
        style={{
          marginTop: '16px',
          textAlign: 'center',
          fontSize: '12px',
          color: 'rgba(255, 255, 255, 0.4)',
        }}
      >
        Auto-refreshing every {(pollingInterval / 1000).toFixed(1)}s • Powered by
        CoinGecko API
      </div>
    </div>
  );
}
