# Tupay Mobile App

A modern, secure, and performant fintech application built with Flutter. This project is a demonstration of advanced UI fidelity, robust state management, and enterprise-grade architecture.

## Overview

Tupay is designed to provide a seamless payment and transfer experience. It features a responsive dashboard with multi-currency wallets, an interactive transfer flow, and secure state persistence ensuring users never lose their transaction progress.

### Key Features
- **Pixel-Perfect UI**: High-fidelity implementation of Figma designs, utilizing responsive Slivers and custom components for a premium feel.
- **Complex Transaction Flow**: A multi-step transaction process (Amount Entry → Recipient Selection → Review → Success) powered by a robust state machine.
- **Secure State Restoration**: Transaction progress is automatically serialized and securely stored using `flutter_secure_storage`. If the app is killed, the user resumes exactly where they left off.
- **Multi-Currency Support**: Real-time currency conversion rates and wallet summaries.
- **Comprehensive Testing**: Full coverage including Unit tests, Widget tests, and Golden (Snapshot) tests to prevent UI regressions.

## Architecture

The project strictly follows **Feature-First / Clean Architecture**, separating concerns to maximize testability and maintainability.

- **Data Layer**: API clients, local storage services (e.g., `SecureStorageService`).
- **Domain Layer**: Core business logic, models (`Transaction`, `Recipient`, `Currency`), and formatters.
- **Presentation Layer**: UI components, Screens, and State Management.

### State Management
State is managed using **Riverpod**, providing predictable and scalable state propagation.
- `TransactionNotifier` utilizes a sealed class hierarchy (`TransactionState`) to represent the exact phase of a transaction (Idle, AmountEntered, RecipientSelected, Reviewing, Completed).
- State changes trigger an automatic Microtask to persist the state as JSON securely.

## Getting Started

### Prerequisites
- Flutter SDK `^3.11.5` (Compatible with Flutter 3.41.9 via FVM)
- Dart SDK `^3.7.0`

### Installation
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Testing

This project employs a robust testing strategy ensuring both logic correctness and UI consistency.

- **Run Unit and Widget Tests**:
  ```bash
  flutter test
  ```
- **Update Golden Tests** (Mac environment required to match baseline renderings):
  ```bash
  flutter test --update-goldens
  ```
*Note: Font rendering in test environments is overridden and managed locally via mocked channels to ensure stable Golden generation.*

## Design Decisions
- **Typography & Theme**: All styles are centralized in `AppTheme`. Google Fonts is used dynamically with local fallback handling during tests.
- **No Code-Gen**: To keep the build fast and the footprint small, serialization is handled manually without `build_runner` dependencies.
- **Security First**: Instead of standard `SharedPreferences`, `flutter_secure_storage` encrypts state locally, protecting sensitive transaction parameters.

## Contributing
Ensure all commits pass existing static analysis (`flutter analyze`) and tests (`flutter test`) before pushing changes. Golden tests must be regenerated if UI components are modified.
