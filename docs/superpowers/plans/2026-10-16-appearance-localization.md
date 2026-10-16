# Appearance and Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent monochrome appearance and Simplified Chinese, Traditional Chinese, and English UI to Corner.

**Architecture:** One settings controller owns device preferences. `MaterialApp` receives locale and theme from it. A shared localization catalog provides UI text; screens use it through `BuildContext`. Monochrome uses neutral theme tokens without filtering images or map tiles.

**Tech Stack:** Flutter/Dart, existing app storage, Flutter localization delegates.

**Spec:** `docs/superpowers/specs/2026-10-16-appearance-localization-design.md`

## Global Constraints

- Warm Editorial is the default appearance.
- Supported locales are Simplified Chinese, Traditional Chinese, and English; unsupported device locales fall back to English.
- Photos and map tiles remain in original color.
- Account data, place names, and user-authored content remain unchanged.

## Review Focus

- Corrupt saved settings use defaults and do not prevent startup.
- Unsupported device locale resolves to English.
- Changing language updates navigation and current page without restart.
- Monochrome leaves photograph and map imagery unchanged.
- Text and controls remain legible on narrow Android screens.

---

### Task 1: Settings state and persistence

**Files:** Create `corner_story/lib/settings/app_settings.dart`; modify `corner_story/lib/main.dart`; test `corner_story/test/app_settings_test.dart`.

**Interfaces:** `AppSettingsController.load()`, `setAppearance(AppAppearance)`, `setLanguage(AppLanguage)`; exposes selected appearance and locale.

- [ ] Add failing tests for defaults, persisted choices, corrupt values, and unsupported device locale.
- [ ] Run the focused test and confirm failure.
- [ ] Implement the controller and wire it into `CornerApp`.
- [ ] Run the focused test and confirm pass.

### Task 2: Palette and theme application

**Files:** Modify `corner_story/lib/theme/corner_theme.dart`; create theme selection helpers; test `corner_story/test/appearance_test.dart`.

**Interfaces:** `CornerPalette.forAppearance(AppAppearance)` and `CornerPalette.of(BuildContext)` supply colors to app widgets.

- [ ] Add failing tests for neutral monochrome palette and preserved image widgets.
- [ ] Run the focused test and confirm failure.
- [ ] Implement palette and migrate custom color references in shared widgets and screens.
- [ ] Run the focused test and confirm pass.

### Task 3: Localization resources and screen migration

**Files:** Create localization resources under `corner_story/lib/l10n/`; modify `corner_story/lib/screens/*.dart` and shared theme widgets; test `corner_story/test/localization_test.dart`.

**Interfaces:** `CornerL10n.of(context)` with English, Simplified Chinese, and Traditional Chinese messages.

- [ ] Add failing tests for representative navigation, login, settings, map, privacy, and profile strings in each locale.
- [ ] Run the focused test and confirm failure.
- [ ] Add translations and migrate app-owned UI strings across all screens.
- [ ] Run localization generation and focused tests.

### Task 4: Settings UI and end-to-end verification

**Files:** Create `corner_story/lib/screens/app_settings_screen.dart`; modify `corner_story/lib/screens/profile_screen.dart`; test `corner_story/test/settings_screen_test.dart`.

**Interfaces:** Profile opens settings; selectors call the settings controller.

- [ ] Add failing widget test for switching and restoring appearance and language.
- [ ] Run the focused test and confirm failure.
- [ ] Implement settings screen and profile entry.
- [ ] Run `flutter analyze` and `flutter test`.
- [ ] Build Android APK and visually inspect on the attached device when available.
