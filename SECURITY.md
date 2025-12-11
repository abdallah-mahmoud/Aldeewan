# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an e-mail to the developer at [contact@example.com](mailto:contact@example.com). All security vulnerabilities will be promptly addressed.

## Security Measures

### 1. Environment Variables
We use `.env` files to manage sensitive configuration.
- **NEVER** commit `.env` to version control.
- Use `.env.example` as a template.

### 2. Secure Storage
We use `flutter_secure_storage` to store sensitive data like API tokens and encryption keys on the device.
- **Android:** EncryptedSharedPreferences
- **iOS:** Keychain

### 3. Local Database Encryption
The Realm database is encrypted using a key stored securely in `flutter_secure_storage`.

### 4. Code Obfuscation
When building for release, we use code obfuscation to make reverse engineering more difficult.
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

### 5. Network Security
- All network communication should be over HTTPS.
- Certificate pinning is recommended for high-security environments (not yet implemented).
