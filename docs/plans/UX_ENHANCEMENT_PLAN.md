# UX Enhancement Plan: SFX & Advanced Animations

**Goal:** Elevate the user experience of Aldeewan Mobile by integrating "Fintech-style" sound effects (SFX) and fluid animations. The aim is to make the app feel alive, responsive, and premium without compromising performance.

## 1. Design Philosophy: "Modern Fintech"
*   **Visuals:** Smooth, physics-based motions. No abrupt cuts. Elements should slide, fade, and scale with purpose.
*   **Audio:** Subtle, crisp, and non-intrusive. Think "glassy" clicks, soft "whooshes," and satisfying "confirm" chimes. Avoid cartoony or 8-bit sounds.
*   **Haptics:** Taptic feedback should accompany sounds for a tactile feel.

## 2. Sound Effects (SFX) Strategy

### 2.1. Sound Palette
We need a cohesive set of sounds.
*   **Primary Click:** Soft, high-frequency "tick" (for navigation, tab switching).
*   **Action Success:** A rising, harmonious chord (for saving a transaction, completing a backup).
*   **Action Delete/Cancel:** A subtle, lower-pitch "crumple" or "pop" sound.
*   **Money In:** A satisfying "coin drop" or "cash register" inspired sound (modernized).
*   **Money Out:** A quick "swoosh" or "paper slip" sound.
*   **Refresh:** A "spring" or "slide" sound when pulling to refresh.

### 2.2. Implementation Plan
*   **Package:** `audioplayers` (Low latency mode) or `soundpool` (better for short, repetitive SFX).
*   **Architecture:** `SoundService` class managed by Riverpod (`soundServiceProvider`).
*   **Settings:**
    *   Add a "Sounds & Haptics" section in Settings.
    *   Toggle: "App Sounds" (On/Off).
    *   Toggle: "Haptic Feedback" (On/Off).

### 2.3. Integration Points
| Trigger | Sound Type | Description |
| :--- | :--- | :--- |
| Tab Bar Switch | Primary Click | Very subtle tick. |
| Floating Action Button (FAB) | Pop/Open | Distinct activation sound. |
| Save Transaction | Success Chime | Rewarding sound confirming entry. |
| Delete Item | Delete/Trash | Feedback for destructive action. |
| Pull to Refresh | Slide/Spring | Mechanical feedback. |
| Toggle Switch | Click (On/Off) | Physical switch sound. |

## 3. Animation Strategy

### 3.1. Technology Stack
*   **Package:** `flutter_animate` (For declarative, chainable animations).
*   **Package:** `lottie` (For complex vector animations like success checks or empty states).
*   **Core Flutter:** `Hero`, `AnimatedContainer`, `AnimatedSwitcher`.

### 3.2. Global Animations
*   **Page Transitions:**
    *   Use `CupertinoPageTransition` (Slide from right) for standard navigation.
    *   Use `FadeUpwards` or `Zoom` for modal dialogs.
*   **List Items:**
    *   **Staggered Entrance:** When a list loads, items should slide in one by one (milliseconds delay).
    *   **Swipe Actions:** Smooth reveal of "Edit/Delete" options behind the tile.

### 3.3. Screen-Specific Enhancements

#### A. Home Dashboard
*   **Net Position Card:**
    *   **Entry:** Slide down + Fade in.
    *   **Numbers:** "Rolling numbers" animation (Counter) when balance updates. e.g., 0 -> 1,500.
*   **Charts:**
    *   Bars should grow from bottom up on load.
    *   Lines should draw from left to right.
*   **Recent Transactions:**
    *   Staggered list fade-in.

#### B. Transaction Entry Form
*   **Input Focus:** Slight scale up or border glow when a field is active.
*   **Validation Error:** "Shake" animation (horizontal vibration) of the input field.
*   **Submit Button:**
    *   On Tap: Scale down (0.95x).
    *   On Loading: Morph into circular loader.
    *   On Success: Morph into a green checkmark (Lottie).

#### C. Ledger / Person Details
*   **Hero Transitions:**
    *   Avatar/Name from List -> Detail Header.
    *   Balance amount from List -> Detail Summary.
*   **Empty State:**
    *   Lottie animation of a floating document or empty wallet instead of static icon.

#### D. Splash Screen
*   **Logo:** Animated logo reveal (Fade + Scale + Blur removal).
*   **Content:** Added Quran verse (2:282) with elegant typography and animation.

## 4. Implementation Roadmap

### Phase 1: Foundation & Assets (Day 1)
- [x] Add dependencies: `flutter_animate`, `audioplayers`, `lottie`, `vibration` (or `haptic_feedback`).
- [x] Create `assets/audio/` and `assets/animations/` folders.
- [x] Source/Generate SFX files (mp3/wav).
- [x] Source Lottie files (json).
- [x] Implement `SoundService` with Riverpod.
- [x] Implement `HapticService`.

### Phase 2: Core UI Animations (Day 2)
- [x] Wrap main lists with `AnimateList` (flutter_animate) for staggered entry.
- [x] Implement "Rolling Numbers" widget for balances.
- [x] Add "Shake" animation extension for error states.
- [x] Update `AppButton` to have scale-on-press and loading state morphing.

### Phase 3: Sound Integration (Day 3)
- [x] Wire up `SoundService` to `GoRouter` observer (for navigation clicks).
- [x] Wire up `SoundService` to `TransactionRepository` (for success/delete sounds).
- [x] Add "Sounds" toggle in Settings Screen.

### Phase 4: Polish & Review (Day 4)
- [x] Fine-tune animation durations (keep them under 300ms for UI, 500ms for transitions).
- [x] Ensure sounds are not annoying (volume balancing).
- [ ] Test performance on older devices (disable animations if low FPS detected).

## 5. Recommended Assets List
*   `click_soft.mp3`
*   `success_chime.mp3`
*   `delete_pop.mp3`
*   `cash_register.mp3`
*   `lottie_success_check.json`
*   `lottie_empty_box.json`
*   `lottie_loading_spinner.json`
