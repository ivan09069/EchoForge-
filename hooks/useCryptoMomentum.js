import { useState, useEffect, useRef } from 'react';
import axios from 'axios';

/**
 * Enhanced crypto momentum tracking with RM²E (Risk-Momentum-Magic-Effort) scoring
 * @param {Array} symbols - Array of CoinGecko coin IDs (e.g., ['bitcoin', 'ethereum', 'solana'])
 * @param {number} pollingInterval - Update interval in milliseconds (default: 2500)
 * @returns {Object} { data, rm2eScores, isOnline }
 */
export default function useCryptoMomentum(
  symbols = ['bitcoin', 'ethereum', 'solana'],
  pollingInterval = 2500
) {
  const [data, setData] = useState([]);
  const [rm2eScores, setRm2eScores] = useState([]);
  const [isOnline, setIsOnline] = useState(true);
  const retryDelayRef = useRef(2500);

  useEffect(() => {
    let intervalId;

    const fetchData = async () => {
      try {
        const response = await axios.get(
          `https://api.coingecko.com/api/v3/coins/markets`,
          {
            params: {
              vs_currency: 'usd',
              ids: symbols.join(','),
              order: 'market_cap_desc',
              per_page: symbols.length,
              page: 1,
              sparkline: false,
              price_change_percentage: '24h,7d',
              include_market_cap: true,
            },
            timeout: 5000,
          }
        );

        // Filter out delisted coins (null price)
        const validCoins = response.data.filter(coin => coin.current_price !== null);

        // Calculate RM²E scores
        const scores = validCoins.map(coin => {
          const change24h = coin.price_change_percentage_24h || 0;
          const change7d = coin.price_change_percentage_7d || 0;
          const marketCap = coin.market_cap || 1;

          // Enhanced Risk Calculation (volatility-based with floor)
          const volatility = Math.sqrt(
            Math.pow(change24h, 2) + Math.pow(change7d / 7, 2)
          ) / 10;
          const risk = Math.max(0.1, volatility);

          // Improved Momentum Scoring (weighted recent changes, positive only)
          const rawMomentum = change24h * 0.7 + change7d * 0.3;
          const momentum = Math.max(0, rawMomentum);

          // Progressive Magic Multiplier
          let magic;
          if (change24h > 10) {
            magic = 20;
          } else if (change24h > 5) {
            magic = 15;
          } else if (change24h > 0) {
            magic = 10;
          } else {
            magic = 1;
          }

          // Liquidity-Weighted Effort (larger cap = easier entry = lower effort)
          const effort = Math.max(1, 100 / Math.log10(marketCap + 10));

          // RM²E Formula: (momentum × magic) / (risk × effort) × 100
          const rm2e = ((momentum * magic) / (risk * effort)) * 100;

          // Signal Generation
          let signal;
          if (rm2e > 150) {
            signal = '🔥 STRONG BUY';
          } else if (rm2e > 80) {
            signal = '✅ BUY';
          } else {
            signal = '⏳ HOLD';
          }

          return {
            id: coin.id,
            name: coin.name,
            symbol: coin.symbol.toUpperCase(),
            price: coin.current_price,
            change24h: change24h,
            change7d: change7d,
            marketCap: marketCap,
            rm2e: parseFloat(rm2e.toFixed(2)),
            signal: signal,
            risk: parseFloat(risk.toFixed(2)),
            momentum: parseFloat(momentum.toFixed(2)),
            magic: magic,
            effort: parseFloat(effort.toFixed(2)),
          };
        });

        // Auto-rank by RM²E score (descending)
        const rankedScores = scores.sort((a, b) => b.rm2e - a.rm2e);

        setData(validCoins);
        setRm2eScores(rankedScores);
        setIsOnline(true);

        // Reset retry delay on success
        retryDelayRef.current = 2500;
      } catch (error) {
        console.error('Error fetching crypto data:', error);

        // Handle rate limiting (429 error)
        if (error.response && error.response.status === 429) {
          // Double delay up to 60000ms max
          retryDelayRef.current = Math.min(retryDelayRef.current * 2, 60000);
          console.warn(`Rate limited. Retry delay increased to ${retryDelayRef.current}ms`);
        }

        // Mark as offline on error
        setIsOnline(false);
      }
    };

    // Initial fetch
    fetchData();

    // Set up polling with current retry delay
    intervalId = setInterval(fetchData, pollingInterval);

    return () => {
      if (intervalId) {
        clearInterval(intervalId);
      }
    };
  }, [symbols, pollingInterval]);

  return { data, rm2eScores, isOnline };
}
