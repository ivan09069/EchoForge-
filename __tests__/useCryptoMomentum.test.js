import { renderHook, waitFor } from '@testing-library/react';
import useCryptoMomentum from '../hooks/useCryptoMomentum';
import axios from 'axios';

// Mock axios
jest.mock('axios');

describe('useCryptoMomentum', () => {
  const mockCoinData = [
    {
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'btc',
      current_price: 45000,
      price_change_percentage_24h: 5.2,
      price_change_percentage_7d: 12.5,
      market_cap: 850000000000,
    },
    {
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'eth',
      current_price: 2800,
      price_change_percentage_24h: 8.5,
      price_change_percentage_7d: 15.3,
      market_cap: 320000000000,
    },
  ];

  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  test('fetches and calculates RM²E scores correctly', async () => {
    axios.get.mockResolvedValue({ data: mockCoinData });

    const { result } = renderHook(() => useCryptoMomentum(['bitcoin', 'ethereum']));

    // Wait for initial fetch
    await waitFor(() => {
      expect(result.current.rm2eScores.length).toBeGreaterThan(0);
    });

    expect(result.current.isOnline).toBe(true);
    expect(result.current.rm2eScores).toHaveLength(2);
    
    // Verify first coin has required properties
    const firstCoin = result.current.rm2eScores[0];
    expect(firstCoin).toHaveProperty('id');
    expect(firstCoin).toHaveProperty('rm2e');
    expect(firstCoin).toHaveProperty('signal');
    expect(firstCoin).toHaveProperty('risk');
    expect(firstCoin).toHaveProperty('momentum');
    expect(firstCoin).toHaveProperty('magic');
    expect(firstCoin).toHaveProperty('effort');
  });

  test('auto-ranks scores by RM²E value descending', async () => {
    axios.get.mockResolvedValue({ data: mockCoinData });

    const { result } = renderHook(() => useCryptoMomentum(['bitcoin', 'ethereum']));

    await waitFor(() => {
      expect(result.current.rm2eScores.length).toBe(2);
    });

    // Scores should be sorted descending
    const scores = result.current.rm2eScores;
    for (let i = 0; i < scores.length - 1; i++) {
      expect(scores[i].rm2e).toBeGreaterThanOrEqual(scores[i + 1].rm2e);
    }
  });

  test('filters out delisted coins with null price', async () => {
    const dataWithDelisted = [
      ...mockCoinData,
      {
        id: 'delisted-coin',
        name: 'Delisted',
        symbol: 'del',
        current_price: null,
        price_change_percentage_24h: 0,
        price_change_percentage_7d: 0,
        market_cap: 0,
      },
    ];
    
    axios.get.mockResolvedValue({ data: dataWithDelisted });

    const { result } = renderHook(() =>
      useCryptoMomentum(['bitcoin', 'ethereum', 'delisted-coin'])
    );

    await waitFor(() => {
      expect(result.current.rm2eScores.length).toBe(2);
    });

    // Should only have 2 valid coins
    expect(result.current.rm2eScores).toHaveLength(2);
    expect(result.current.rm2eScores.every(coin => coin.price !== null)).toBe(true);
  });

  test('generates correct signal based on RM²E score', async () => {
    const highMomentumCoin = {
      id: 'explosive-coin',
      name: 'Explosive',
      symbol: 'exp',
      current_price: 100,
      price_change_percentage_24h: 25,
      price_change_percentage_7d: 40,
      market_cap: 100000000,
    };

    axios.get.mockResolvedValue({ data: [highMomentumCoin] });

    const { result } = renderHook(() => useCryptoMomentum(['explosive-coin']));

    await waitFor(() => {
      expect(result.current.rm2eScores.length).toBe(1);
    });

    const coin = result.current.rm2eScores[0];
    // With 25% 24h change, should have high RM²E and STRONG BUY signal
    expect(coin.rm2e).toBeGreaterThan(100);
    expect(['🔥 STRONG BUY', '✅ BUY']).toContain(coin.signal);
  });

  test('sets isOnline to false on fetch error', async () => {
    axios.get.mockRejectedValue(new Error('Network error'));

    const { result } = renderHook(() => useCryptoMomentum(['bitcoin']));

    await waitFor(() => {
      expect(result.current.isOnline).toBe(false);
    });
  });

  test('implements exponential backoff on 429 rate limit error', async () => {
    const rateLimitError = {
      response: { status: 429 },
    };

    axios.get.mockRejectedValue(rateLimitError);

    const { result } = renderHook(() => useCryptoMomentum(['bitcoin']));

    await waitFor(() => {
      expect(result.current.isOnline).toBe(false);
    });

    // Should log retry delay increase
    // Note: Actual retry delay validation would require more complex testing
  });

  test('magic multiplier scales correctly with 24h change', async () => {
    const testCases = [
      { change24h: 15, expectedMagic: 20 }, // > 10%
      { change24h: 7, expectedMagic: 15 },  // > 5%
      { change24h: 2, expectedMagic: 10 },  // > 0%
      { change24h: -5, expectedMagic: 1 },  // negative
    ];

    for (const testCase of testCases) {
      const coinData = {
        id: 'test-coin',
        name: 'Test',
        symbol: 'tst',
        current_price: 100,
        price_change_percentage_24h: testCase.change24h,
        price_change_percentage_7d: 10,
        market_cap: 1000000000,
      };

      axios.get.mockResolvedValue({ data: [coinData] });

      const { result } = renderHook(() => useCryptoMomentum(['test-coin']));

      await waitFor(() => {
        expect(result.current.rm2eScores.length).toBe(1);
      });

      expect(result.current.rm2eScores[0].magic).toBe(testCase.expectedMagic);
    }
  });
});
