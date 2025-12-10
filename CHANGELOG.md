# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-10

### Added
- Initial documented baseline of Aldeewan Mobile in this repository.
- Dashboard (Home) with summary cards, recent activity, and quick actions.
- Ledger management for customers and suppliers with per-person balances.
- Cashbook screen for cash-related transactions.
- Reports screen with person statement and cash flow reports.
- Settings screen for theme, language, and currency configuration.
- Data management features: backup to JSON, restore from JSON, export persons and transactions to CSV.
- About developer screen with contact links and GitHub repository.

### Changed
- Updated theming in `lib/config/theme.dart` and removed unused color constants to satisfy Dart analysis.
- Replaced the default Flutter README with project-specific documentation.

### Known Issues
- Limited automated test coverage; core logic (ledger calculations, backup/restore) should be covered by unit tests in future versions.
- Backup/restore currently performs a merge-style restore; full wipe-and-restore with confirmation and migration support can be added in later releases.

[1.1.0]: https://github.com/abdallah-mahmoud/Aldeewan/releases/tag/v1.1.0

