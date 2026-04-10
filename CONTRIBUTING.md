# Contributing to PrecisionCalc

We love contributions! To keep the "Relentless Architect" standards high, please follow these guidelines.

## How to Contribute

### 1. Reporting Bugs
- Use the GitHub Issues tab.
- Provide clear steps to reproduce the bug.
- Include your device model (e.g., OPPO A3x) and Android version.

### 2. Suggesting Features
- Open an issue with the tag [Feature Request].
- Explain why the feature is needed and how it fits the "Precision" logic.

### 3. Pull Requests
- Fork the repository.
- Create a feature branch (\`git checkout -b feature/AmazingFeature\`).
- Ensure your code follows the **Clean Architecture** patterns used in the project.
- Use meaningful commit messages.
- Push to the branch and open a Pull Request.

## Coding Standards
- **Formatting:** Always run \`flutter format .\` before committing.
- **State Management:** Use BLoC for all UI logic. No exceptions.
- **Precision:** Use the \`decimal\` package for any math logic. Never use standard \`double\` for final results.
- **UI:** Ensure all widgets are wrapped in the \`Responsive\` utility to maintain adaptability.

## Community
Be kind and professional. We are here to build high-performance tools together.
