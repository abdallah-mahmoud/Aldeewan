# Settings Screen Revamp Plan

## Objective
Redesign the `SettingsScreen` to align with the "Modern Fintech" aesthetic of the Aldeewan Mobile app. The current implementation is functional but lacks the visual polish, card-based layout, and attention to detail present in the rest of the application.

## Design Concept
- **Layout:** Grouped settings style (similar to iOS/modern Android).
- **Components:**
    - **Sections:** Distinct groups of settings with section headers.
    - **Cards:** Settings groups contained within rounded cards (BorderRadius 16-20px).
    - **Icons:** Colorful icon containers (Icon on soft background) for better visual hierarchy.
    - **Typography:** Clear hierarchy with `Cairo` font.
- **Colors:** Use the app's `Royal Indigo` and `Vibrant Mint` for accents and active states.

## Proposed Components

### 1. `SettingsSection`
A container widget that wraps a list of settings tiles.
- **Props:** `title` (optional), `children` (List<Widget>).
- **Style:**
    - Background: Surface color (White/Dark Grey).
    - Border Radius: 20px.
    - Shadow: Soft shadow (low elevation).
    - Padding: Internal padding for content.

### 2. `SettingsTile`
A highly customizable list tile.
- **Props:**
    - `icon`: IconData (Lucide).
    - `iconColor`: Color (for the icon background).
    - `title`: String.
    - `subtitle`: String? (optional).
    - `trailing`: Widget? (Switch, Arrow, Text, etc.).
    - `onTap`: VoidCallback?
    - `isDestructive`: bool (for "Reset Data").
- **Style:**
    - Leading: Icon centered in a 40x40 container with `color.withOpacity(0.1)` background.
    - Title: `titleMedium`.
    - Subtitle: `bodySmall` (grey).

### 3. `ThemeSelector` (New)
Replace the dropdown with a visual selector.
- **Layout:** Row of 3 cards/buttons: "System", "Light", "Dark".
- **Interaction:** Tapping selects the mode and highlights the card.

## Layout Structure

### Section 1: Appearance
- **Theme:** Custom `ThemeSelector`.
- **Language:** Tile opening a modal or using a segmented control (English/Arabic).
- **Simple Mode:** Switch Tile.

### Section 2: General
- **Currency:** Tile showing current currency code -> Opens selection dialog.
- **Security:** Switch Tile for "App Lock" (Biometrics).
- **Categories:** Tile -> Navigates to `CategoriesManagementScreen`.

### Section 3: Data Management
- **Export CSV:** Action Tile.
- **Backup Data:** Action Tile.
- **Restore Data:** Action Tile.

### Section 4: Danger Zone
- **Reset Data:** Destructive Tile (Red text/icon).

### Footer
- **App Version:** Centered, grey text at the bottom.
- **Copyright:** "Made with ❤️ by Motaasl".

## Implementation Steps

1.  **Create Widgets:**
    - Create `lib/presentation/widgets/settings/settings_section.dart`.
    - Create `lib/presentation/widgets/settings/settings_tile.dart`.
    - Create `lib/presentation/widgets/settings/theme_selector.dart`.

2.  **Refactor `SettingsScreen`:**
    - Replace `ListView` with `SingleChildScrollView` + `Column`.
    - Implement the new sections using the created widgets.
    - Migrate all existing logic (Providers, Navigation, Dialogs) to the new UI components.

3.  **Polish:**
    - Add animations (e.g., switch transitions).
    - Ensure Dark Mode compatibility.
    - Verify RTL support (Arabic).

## Task List
- [ ] Create `SettingsSection` and `SettingsTile` widgets.
- [ ] Create `ThemeSelector` widget.
- [ ] Refactor `SettingsScreen` layout.
- [ ] Verify all functionalities (Theme, Locale, Security, Data).
- [ ] Check UI in Dark Mode and Arabic.
