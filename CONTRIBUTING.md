# Contributing to EchoForge

Thank you for your interest in contributing to EchoForge! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive environment for all contributors.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/EchoForge-.git`
3. Install dependencies: `npm install`
4. Create a branch: `git checkout -b feature/your-feature-name`

## Development Workflow

### Running the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view your changes.

### Testing

Always run tests before submitting a PR:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run linting
npm run lint
```

### Building

Ensure the production build works:

```bash
npm run build
npm start
```

## Coding Standards

### Style Guide

- Use 2 spaces for indentation
- Use semicolons
- Follow ESLint rules (extends next/core-web-vitals)
- Write descriptive commit messages

### Component Guidelines

- Use functional components with hooks
- Keep components small and focused
- Add PropTypes or TypeScript types (future enhancement)
- Write reusable, testable code

### File Structure

```
components/     # Reusable UI components
pages/          # Next.js pages (routes)
lib/            # Utility functions and helpers
styles/         # CSS styles
public/         # Static assets
__tests__/      # Test files
```

## Commit Messages

Use clear, descriptive commit messages:

```
feat: Add biometric authentication support
fix: Resolve encryption key derivation issue
docs: Update README with installation instructions
test: Add tests for Dashboard component
style: Format code according to ESLint rules
refactor: Simplify WebSocket connection logic
```

## Pull Request Process

1. **Update your branch** with the latest changes from main
2. **Run tests** and ensure they pass
3. **Run the linter** and fix any issues
4. **Build the project** to ensure no build errors
5. **Write a clear PR description** explaining your changes
6. **Link related issues** if applicable
7. **Request review** from maintainers

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings generated
```

## Reporting Issues

### Bug Reports

Include:
- Clear, descriptive title
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Browser/environment details

### Feature Requests

Include:
- Clear description of the feature
- Use case and benefits
- Potential implementation approach
- Mockups or examples if applicable

## Security

**Do not** report security vulnerabilities in public issues. Email security@echoforge.app instead.

## Questions?

Feel free to:
- Open a discussion on GitHub
- Ask in pull request comments
- Email: support@echoforge.app

Thank you for contributing to EchoForge! 🎉
