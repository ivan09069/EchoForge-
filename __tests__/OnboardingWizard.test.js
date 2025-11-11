import { render, screen, fireEvent } from '@testing-library/react';
import OnboardingWizard from '../components/OnboardingWizard';

describe('OnboardingWizard', () => {
  test('renders welcome step and navigates', () => {
    render(<OnboardingWizard onFinish={() => {}} />);
    expect(screen.getByText(/welcome to echoforge/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /next/i }));
    expect(screen.getByText(/secure your assets/i)).toBeInTheDocument();
  });
  test('finish calls onFinish', () => {
    const onFinish = jest.fn();
    render(<OnboardingWizard onFinish={onFinish} />);
    fireEvent.click(screen.getByRole('button', { name: /next/i }));
    fireEvent.click(screen.getByRole('button', { name: /finish/i }));
    expect(onFinish).toHaveBeenCalled();
  });
});