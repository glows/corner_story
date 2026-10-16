# Corner appearance and localization design

## Goal

Give people an in-app choice between the existing warm editorial appearance and a monochrome appearance, and between Simplified Chinese, Traditional Chinese, and English. Apply the choice throughout the app and restore it after restart. Images, map tiles, place names, and user-authored content retain their original colors or language.

## Approach

Use Flutter's `MaterialApp.locale`, localization delegates, and generated ARB resources for interface text. Keep app preferences in a small local settings controller backed by device storage. Use two explicit theme palettes exposed through inherited theme values instead of applying a global grayscale filter. A grayscale filter would also change photographs and maps, which the user does not want. Duplicating whole pages per language would make the existing twelve screens difficult to maintain.

## User experience

Add an Appearance and Language entry to the profile area, opening a settings screen. Appearance choices are Warm Editorial and Monochrome. Language choices are Follow Device, 简体中文, 繁體中文, and English; Follow Device chooses a supported device language and falls back to English. The warm appearance remains the default. Changes apply immediately and persist locally across relaunches and sign-out. Settings are device preferences, independent of the signed-in account.

The monochrome palette uses black, white, and neutral grays for surfaces, text, controls, borders, chips, icons, and status/navigation bars. Keep sufficient text contrast in both palettes. Editorial photographs and map tiles retain original colors, and overlays can use neutral colors without filtering the underlying content.

## Localization scope

Translate app-owned navigation, onboarding, sign-in and error messages, map controls, feed actions, profile, privacy, collection and spot detail controls, dialogs, empty states, accessibility labels, and the new settings screen. Keep external data, place names, addresses, editorial descriptions supplied by the backend, and user-authored text unchanged. Format dates and numbers according to the selected locale where the app currently renders them. The three languages have matching message keys and supported interpolation arguments.

## Components and data flow

`AppSettingsController` loads saved appearance and language before the first app frame, exposes changes through `ChangeNotifier`, and writes each selection to device storage. `CornerApp` listens to that controller and rebuilds `MaterialApp` with the chosen theme and locale. A localization resource class generated from ARB files supplies text to screens and reusable widgets. A theme extension provides the editorial colors needed by custom widgets; standard Material widgets receive a matching `ThemeData`.

Missing or corrupt saved settings fall back to warm appearance and Follow Device without interrupting startup. Translation generation is checked during build; missing translations are treated as a development error. The settings screen displays and updates the current selection without needing network access.

## Verification

Run Flutter localization generation, static analysis, and existing tests. Add focused tests for preference restoration, locale fallback, and theme color behavior. Manually check the three languages and both appearances on a narrow Android device, including long labels, sign-in, navigation, map, profile, and settings. Verify that photos and map tiles retain color in monochrome mode and that choices survive app restart.

## Boundaries

No backend schema, account preference synchronization, machine translation, translated place catalog, or photo processing is required. Google sign-in and email OTP behavior remain as implemented.
