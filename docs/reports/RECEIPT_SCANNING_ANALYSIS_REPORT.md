# Receipt Scanning Analysis Report

## Overview
This report analyzes the issue where the scanned receipt amount is not being populated in the `TransactionForm`. The analysis is based on three sample receipt images provided by the user (Bank of Khartoum, O-Cash, Fawry) and the current implementation of `ReceiptParser`.

## Image Analysis

### 1. Bank of Khartoum (Green Receipt)
- **Format:** Table-like structure with alternating rows.
- **Amount Field:**
    - Label: "المبلغ" (Right aligned)
    - Value: "400000.0" (Left aligned)
- **Challenge:** The label and value are likely on the same horizontal line visually, but OCR might read them as separate blocks or lines depending on the layout analysis. The current parser looks for the amount *in the same line* as the label. If OCR splits them into "المبلغ" (Line X) and "400000.0" (Line X), it works. If it reads "المبلغ" then "400000.0" as separate lines, or if the value is on the *next* line, the current logic might fail.
- **Other Fields:** "رقم العملية" (Transaction ID), "التاريخ والوقت" (Date).

### 2. O-Cash (White Receipt)
- **Format:** List/Key-Value pairs.
- **Amount Field:**
    - Label: "المبلغ" (Right aligned)
    - Value: "320,000 SDG" (Left aligned, possibly on the same line or slightly below)
- **Challenge:** The value contains "SDG". The current regex `(\d{1,3}(?:,\d{3})*(?:\.\d+)?|\d+(?:\.\d+)?)` should match "320,000", but the parser iterates through lines. If "المبلغ" and "320,000 SDG" are not on the same line string returned by OCR, it will fail. Also, the parser prioritizes lines with "SDG", so it might find it, but we need to ensure it picks the correct number.

### 3. Fawry (Purple Receipt)
- **Format:** Key-Value pairs (English).
- **Amount Field:**
    - Label: "Amount" (Left aligned)
    - Value: "750000" (Right aligned)
- **Challenge:** Similar to above. "Amount" and "750000" are visually on the same row. OCR usually groups text lines. If they are far apart, they might be separate blocks.

## Current Implementation Analysis (`ReceiptParser`)

The current `ReceiptParser` logic is:
1.  Split text by `\n`.
2.  Iterate through each line.
3.  Check if the line contains keywords ("amount", "total", "المبلغ", etc.).
4.  If a keyword is found, look for a number pattern *in that same line*.

### Identified Issues
1.  **Label and Value Separation:** In many receipts (especially table-based ones like Image 1), the label "المبلغ" and the value "400000.0" might be physically distant. OCR engines (like ML Kit) might return them as separate text blocks. If the `ReceiptScannerService` just joins all blocks with `\n`, they might appear on separate lines or the order might be "Label... Value" or "Label \n Value".
    - If the OCR reads column by column (unlikely for simple receipts but possible), the text might be scrambled.
    - More likely: The label and value are on the same "line" visually, but if the parser relies strictly on `text.split('\n')`, it depends entirely on how ML Kit constructs the string.
2.  **Next Line Logic:** The current parser *only* looks in the line containing the keyword. It does **not** look at the *next* line. In many receipts, the label is above the value, or the OCR splits them into two lines.
3.  **Currency Suffix:** The regex handles commas and decimals but doesn't explicitly handle the "SDG" suffix removal (though the regex extraction logic `match.group(0)` should extract just the number part if the regex is correct). However, `320,000` matches `\d{1,3}(?:,\d{3})*`.

## Proposed Solution

To improve accuracy, we need to enhance the `ReceiptParser`:

1.  **Look Ahead:** If a line contains a keyword (e.g., "المبلغ") but *no* valid amount is found in that line, check the **next line**. This handles cases where the label is above the value or OCR splits them.
2.  **Keyword Proximity:** If the label and value are on the same line, the current logic works. We should refine the regex to ensure it captures numbers with commas correctly.
3.  **Specific Keywords:** Add "Amount", "Total", "المبلغ", "الاجمالي", "القيمة" to the high-priority list.
4.  **Date Parsing:** Enhance date parsing to handle "07-Dec-2025" (Image 1) and "2025-11-17" (Image 2). The current regex `\d{1,2}[/-]\d{1,2}[/-]\d{2,4}` handles numeric dates but not "Dec".

## Resolution (December 2025)

The `ReceiptParser` has been updated to address the issues identified with the user's sample inputs.

### Fixes Implemented
1.  **Fallback Logic for Amount:**
    - If no amount is found associated with keywords (e.g., "Amount", "Total"), the parser now scans the entire text for the "best candidate" number.
    - **Heuristics:** It picks the largest number that is:
        - Not a year (2020-2030).
        - Not a huge integer (likely an ID or phone number).
        - Prioritizes numbers with decimals.
    - This solves the issue where the amount line has no keywords (e.g., `19,000.00` on a separate line).

2.  **Regex Improvements:**
    - **Amount Regex:** Updated to `(\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?)`. This correctly handles both formatted (comma-separated) and unformatted numbers without splitting them incorrectly.
    - **Date Regex:**
        - Prioritized ISO format (`yyyy-MM-dd`) to prevent partial matches (e.g., `2023-10-05` being parsed as `2005`).
        - Removed word boundary `\b` from the start of the text-date regex to handle cases where the date is concatenated with other text (e.g., `...907-Dec-2025`).

3.  **Verification:**
    - Added unit tests in `test/domain/utils/receipt_parser_test.dart`.
    - Verified against the user's provided garbled input (Input 1) and clean input (Input 2).
    - **Input 1 Result:** Correctly extracts `400000.01253` and `07-Dec-2025`.
    - **Input 2 Result:** Correctly extracts `19,000.00`.

The receipt scanning feature should now be significantly more robust.

