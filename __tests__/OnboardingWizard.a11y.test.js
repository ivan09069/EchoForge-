import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import OnboardingWizard from '../components/OnboardingWizard';

expect.extend(toHaveNoViolations);

test('should have no accessibility violations', async () => {
  const { container } = render(<OnboardingWizard onFinish={() => {}} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});