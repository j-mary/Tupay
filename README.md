# Tupay Assessment Mobile App

Flutter assessment implementation for a secure fintech dashboard and transfer flow.

## Architecture

The app uses a feature-first structure:

- `lib/core`: navigation, theme, security, privacy overlay, isolate parsing.
- `lib/features/dashboard`: dashboard state, mock transaction loading, wallet and transaction UI.
- `lib/features/transactions`: transfer domain entities, async state machine, amount, payment, and review screens.

State is managed with Riverpod `AsyncNotifierProvider`s:

- `transactionProvider` restores secure transaction progress before `GoRouter` is initialized, then exposes sealed UI states such as `TransactionConfiguring`, `TransactionSelectingPaymentMethod`, and `TransactionReviewing`.
- `dashboardProvider` keeps dashboard loading/error explicit while preserving the existing `DashboardState` UI model.

## State Restoration

Transaction drafts are serialized as JSON into `flutter_secure_storage`. The matching route is stored beside the draft so app startup can restore deterministically to:

- `/transfer` for amount and recipient entry.
- `/transfer/payment` for payment method selection.
- `/transfer/review` for review, processing, or success state.

Demo steps:

1. Start a transfer from the dashboard Pay action.
2. Enter a valid amount and recipient, continue to payment, then select a payment method.
3. Kill and relaunch the app.
4. The app opens directly on the restored review step with the same transaction details.

Back buttons update both provider state and `GoRouter` location. Invalid amount or recipient data blocks forward navigation and keeps the user on `/transfer`.

## Security And Privacy

Sensitive transaction drafts and transaction IDs use `flutter_secure_storage`, not shared preferences. `PrivacyOverlay` wraps the app and obscures content when the app is backgrounded, reducing exposure in app switchers.

## Isolate Parsing

`MockTransactionPayloadGenerator` creates a deterministic transaction JSON payload of about 5MB in memory. `TransactionParser.parseLargeJsonBackground` parses and filters that payload through `Isolate.run`, then limits the mapped dashboard list so the visible UI remains fast.

## UI Coverage

The implemented scope focuses on the required assessment surfaces:

- Tupay-style dashboard branding, profile treatment, wallet/action sections, recent transactions, and bottom navigation labels.
- Transfer amount, payment method, review receipt, CTA bars, and success state.
- Centralized colors in `AppColors` and `AppTheme`.

## Testing

Run static analysis:

```bash
flutter analyze
```

Run all tests:

```bash
flutter test
```

Update goldens after intentional UI changes:

```bash
flutter test --update-goldens
```

Assessment coverage checklist:

- Transaction serialization and restoration for payment/review steps.
- Startup route selection from restored transaction state.
- Back navigation state transitions.
- Validation blocking invalid forward navigation.
- Isolate-backed large JSON generation/parsing.
- Dashboard and transfer summary goldens.
- Widget coverage for restored review screen rendering.

Responsive layout work lives on the `responsive-shell` branch. That branch contains the shared responsive shell and its widget coverage for mobile, tablet, and desktop breakpoints.

## Android Emulator Recording

The submission video is a 2-minute screen recording from an Android emulator.

1. Show dashboard, wallet cards, quick actions, recent transactions, and bottom nav.
2. Scroll through the content to show the page stays responsive.
3. Tap Pay, enter the transfer amount and recipient details, and show the inline validation and currency switching.
4. Continue to payment, choose a payment method, and review the transfer.
5. Kill/restart the app and show direct restoration to the review route.
6. Submit transfer and show the success state, then return home.
7. When the app is hidden/backgrounded the blur effect kicks in, masking sensitive content in app switchers.

## Demo Video

[Android emulator recording](https://github.com/user-attachments/assets/2575a85b-0c0d-4d08-a3ec-a925b70c05aa)
