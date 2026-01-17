# MyWallet

A Flutter loyalty card wallet that supports Apple Wallet (`.pkpass`) files.

## Features

- **Import `.pkpass` files**: Easily add your loyalty cards from local files.
- **Balance Tracking**: Automatically parses and displays loyalty points/balance from card headers.
- **Dynamic Updates**: Supports standard Apple PassKit web services to refresh balance via pull-to-refresh.
- **QR Code Support**: Displays high-quality QR codes for scanning at checkouts.
- **Offline First**: All cards are stored locally on your device.

## Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Connect your device and run `flutter run`.

## Firebase Setup

This project uses Firebase for authentication and cloud features.

### First-time setup:

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Generate Firebase configuration files:
   ```bash
   flutterfire configure --project=mywallet-e9b75
   ```
   
   This will automatically create:
   - `lib/firebase_options.dart` (Flutter SDK config)
   - `android/app/google-services.json` (Android SDK config)
   - `ios/Runner/GoogleService-Info.plist` (iOS SDK config)
   - `macos/Runner/GoogleService-Info.plist` (macOS SDK config)

These files contain your Firebase API keys and are already listed in `.gitignore`.

## Screenshots

<p align="center">
  <img src="screenshots/5431515745784368157_121.jpg" width="200" />
  <img src="screenshots/5431515745784368158_121.jpg" width="200" />
  <img src="screenshots/5431515745784368159_121.jpg" width="200" />
  <img src="screenshots/5431515745784368160_121.jpg" width="200" />
</p>
