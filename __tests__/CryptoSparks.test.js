import { render, screen } from '@testing-library/react';
import CryptoSparks from '../components/CryptoSparks';
import useCryptoMomentum from '../hooks/useCryptoMomentum';

// Mock the hook
jest.mock('../hooks/useCryptoMomentum');

describe('CryptoSparks', () => {
  const mockRm2eScores = [
    {
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 45000,
      change24h: 5.2,
      change7d: 12.5,
      marketCap: 850000000000,
      rm2e: 125.5,
      signal: '✅ BUY',
      risk: 1.2,
      momentum: 6.39,
      magic: 15,
      effort: 2.5,
    },
    {
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      price: 2800,
      change24h: 8.5,
      change7d: 15.3,
      marketCap: 320000000000,
      rm2e: 180.2,
      signal: '🔥 STRONG BUY',
      risk: 1.5,
      momentum: 10.54,
      magic: 15,
      effort: 2.8,
    },
  ];

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders component title', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    expect(screen.getByText(/crypto momentum tracker/i)).toBeInTheDocument();
  });

  test('displays online status when connected', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    expect(screen.getByText('ONLINE')).toBeInTheDocument();
  });

  test('displays offline status when disconnected', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: [],
      isOnline: false,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    expect(screen.getByText('OFFLINE')).toBeInTheDocument();
  });

  test('shows loading message when no scores available', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: [],
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin']} />);
    expect(screen.getByText(/loading momentum data/i)).toBeInTheDocument();
  });

  test('renders all coin data correctly', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    
    // Check coin names
    expect(screen.getByText('Bitcoin')).toBeInTheDocument();
    expect(screen.getByText('Ethereum')).toBeInTheDocument();
    
    // Check symbols
    expect(screen.getByText(/BTC/)).toBeInTheDocument();
    expect(screen.getByText(/ETH/)).toBeInTheDocument();
  });

  test('displays signal badges correctly', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    
    expect(screen.getByText('✅ BUY')).toBeInTheDocument();
    expect(screen.getByText('🔥 STRONG BUY')).toBeInTheDocument();
  });

  test('renders RM²E scores', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    
    // Check if RM²E scores are displayed
    expect(screen.getByText(/125.50/)).toBeInTheDocument();
    expect(screen.getByText(/180.20/)).toBeInTheDocument();
  });

  test('displays percentage changes with correct formatting', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    
    // Should show positive changes with + sign
    expect(screen.getByText(/\+5.20%/)).toBeInTheDocument();
    expect(screen.getByText(/\+8.50%/)).toBeInTheDocument();
  });

  test('shows rank numbers correctly', () => {
    useCryptoMomentum.mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });

    render(<CryptoSparks symbols={['bitcoin', 'ethereum']} />);
    
    // Check for rank indicators
    expect(screen.getByText('#1')).toBeInTheDocument();
    expect(screen.getByText('#2')).toBeInTheDocument();
  });

  test('uses custom polling interval when provided', () => {
    const mockHook = jest.fn().mockReturnValue({
      rm2eScores: mockRm2eScores,
      isOnline: true,
    });
    useCryptoMomentum.mockImplementation(mockHook);

    render(<CryptoSparks symbols={['bitcoin']} pollingInterval={5000} />);
    
    // Verify hook was called with custom interval
    expect(mockHook).toHaveBeenCalledWith(['bitcoin'], 5000);
  });
});
