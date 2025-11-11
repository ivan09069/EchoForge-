import { render, screen } from '@testing-library/react';
import TransactionTimeline from '../components/TransactionTimeline';

const events = [
  { date: '2025-11-11', type: 'receive', description: 'NFT from Alice', highlight: true },
  { date: '2025-11-10', type: 'transfer', description: 'Sent 0.5 ETH to Bob', highlight: false },
];

describe('TransactionTimeline', () => {
  test('renders events list', () => {
    render(<TransactionTimeline events={events} />);
    expect(screen.getByText(/NFT from Alice/i)).toBeInTheDocument();
    expect(screen.getByText(/sent 0.5 eth to bob/i)).toBeInTheDocument();
  });
  test('shows empty message for no events', () => {
    render(<TransactionTimeline events={[]} />);
    expect(screen.getByText(/no transactions found/i)).toBeInTheDocument();
  });
});