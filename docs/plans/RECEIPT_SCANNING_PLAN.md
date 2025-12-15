# Receipt Scanning & OCR Integration Plan

## 1. Overview
**Objective:** Enable users to automatically create transactions by scanning bank receipts (images or camera) using on-device Optical Character Recognition (OCR).
**Goal:** Reduce manual data entry and improve user convenience.

## 2. Technical Stack & Dependencies

### Dependencies
We will use the following packages:
1.  **`image_picker`**: For accessing the camera and photo gallery.
2.  **`google_mlkit_text_recognition`**: For high-performance, on-device text recognition (Android/iOS).
    *   *Why ML Kit?* It works offline (Local-First), is free, and offers superior accuracy compared to Tesseract for mobile.

### Permissions
**Android (`android/app/src/main/AndroidManifest.xml`):**
*   `<uses-permission android:name="android.permission.CAMERA"/>`
*   `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>` (Android < 13)
*   `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>` (Android 13+)

**iOS (`ios/Runner/Info.plist`):**
*   `NSCameraUsageDescription`: "We need camera access to scan receipts."
*   `NSPhotoLibraryUsageDescription`: "We need gallery access to select receipt images."

## 3. Architecture & Components

### 3.1. Service Layer: `ReceiptScannerService`
*   **Responsibility:** Handle interaction with `image_picker` and `google_mlkit_text_recognition`.
*   **Methods:**
    *   `Future<File?> pickReceiptImage(ImageSource source)`
    *   `Future<String> extractTextFromImage(File image)`

### 3.2. Domain Logic: `ReceiptParser`
*   **Responsibility:** Parse the raw text string to extract structured data.
*   **Logic:** Use Regex patterns to identify:
    *   **Amount:** Look for currency symbols (SDG, £, etc.) and number patterns (e.g., `1,250.00`).
    *   **Date:** Look for date patterns (e.g., `dd/MM/yyyy`, `yyyy-MM-dd`).
    *   **Transaction ID:** Look for "Ref:", "Txn ID:", "Operation No:".
    *   **Bank Name:** Match against a list of known local banks (e.g., "Bank of Khartoum", "Faisal Islamic Bank").
*   **Output:** A `DraftTransaction` object or a `Map<String, dynamic>` containing extracted fields.

### 3.3. UI Integration
*   **Entry Point:**
    *   Add a "Scan Receipt" button in `QuickActions` (Home Screen).
    *   Add a "Scan" icon in the `TransactionForm` app bar.
*   **Flow:**
    1.  User taps "Scan Receipt".
    2.  Selects Camera or Gallery.
    3.  Show a loading indicator ("Analyzing Receipt...").
    4.  Navigate to `TransactionForm` with fields pre-filled (Amount, Date, Note).
    5.  User reviews and saves.

## 4. Implementation Steps

### Phase 1: Setup
- [ ] Add dependencies to `pubspec.yaml`.
- [ ] Configure Android & iOS permissions.

### Phase 2: Core Logic
- [ ] Create `lib/data/services/receipt_scanner_service.dart`.
- [ ] Create `lib/domain/utils/receipt_parser.dart`.
- [ ] Write unit tests for `ReceiptParser` using sample receipt text.

### Phase 3: UI Integration
- [ ] Update `TransactionForm` to accept initial data.
- [ ] Add "Scan" button to `QuickActions` widget.
- [ ] Implement the scanning flow in the UI.

## 5. Privacy & Security
*   **On-Device Processing:** All OCR processing happens locally on the device using ML Kit. No images are uploaded to any server.
*   **Temporary Storage:** Images picked are temporary and should not be permanently stored unless the user explicitly attaches them to the transaction (future feature).

## 6. Known Limitations
*   **Handwriting:** ML Kit is optimized for printed text. Handwritten receipts may have lower accuracy.
*   **Layouts:** Complex receipt layouts might confuse the parser. We will start with support for standard bank transfer screenshots (e.g., Bankak).
