# Receipt Scanning & OCR Implementation Tasks

Based on [RECEIPT_SCANNING_PLAN.md](../plans/RECEIPT_SCANNING_PLAN.md).

## Phase 1: Setup & Configuration
- [x] **Step 1.1: Add Dependencies**
    - Add `image_picker` and `google_mlkit_text_recognition` to `pubspec.yaml`.
- [x] **Step 1.2: Configure Android Permissions**
    - Add Camera and Storage permissions to `android/app/src/main/AndroidManifest.xml`.
- [x] **Step 1.3: Configure iOS Permissions**
    - Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist`.

## Phase 2: Core Logic Implementation
- [x] **Step 2.1: Create ReceiptScannerService**
    - Implement `lib/data/services/receipt_scanner_service.dart` to handle image picking and ML Kit interaction.
- [x] **Step 2.2: Create ReceiptParser**
    - Implement `lib/domain/utils/receipt_parser.dart` with Regex logic for Amount, Date, and Transaction ID.
- [x] **Step 2.3: Register Provider**
    - Register `receiptScannerServiceProvider` in a new or existing provider file.

## Phase 3: UI Integration
- [x] **Step 3.1: Update TransactionForm**
    - Modify `TransactionForm` (or `AddTransactionScreen`) to accept optional initial values for `amount`, `date`, and `note`.
- [x] **Step 3.2: Add Scan Entry Point**
    - Add a "Scan Receipt" button to `QuickActions` widget in `HomeScreen`.
- [x] **Step 3.3: Implement Scanning Flow**
    - Connect the "Scan Receipt" button to the service.
    - Show a loading indicator during processing.
    - Navigate to `TransactionForm` with the extracted data.

## Phase 4: Testing & Refinement
- [ ] **Step 4.1: Manual Testing**
    - Test with a sample receipt image (gallery).
    - Test with camera capture.
- [ ] **Step 4.2: Parser Refinement**
    - Adjust Regex patterns based on test results (e.g., handling "SDG" vs "£").
