# Fix Black Screen on App Launch & Session Recovery

**Date:** 2025-07-03

## Feature / Bug Fix Summary

This task addresses two issues:
1.  A black screen is visible on app launch before the Flutter UI loads.
2.  The app does not resume to the last visited screen when the user returns to the app after it has been in the background.

## Analysis

### Black Screen on Launch

The black screen is a common issue in Flutter apps. It occurs because there is a delay while the Flutter engine initializes. To fix this, we can use the `flutter_native_splash` package to display a native splash screen during this initialization period.

### Session Recovery

The app currently navigates to the home screen on every launch. To improve the user experience, we should persist the last visited route and restore it when the app is reopened. We can use `SharedPreferences` to store the last route and `go_router`'s `redirect` functionality to handle the session recovery.

## Solution Implemented

*   **Splash Screen:**
    *   Add the `flutter_native_splash` dependency to `pubspec.yaml`.
    *   Configure the splash screen in `pubspec.yaml`.
    *   Run the splash screen generator.
*   **Session Recovery:**
    *   Use `SharedPreferences` to store the last visited route.
    *   Update the `app_router.dart` to save the last route on every navigation event.
    *   Modify the `redirect` logic in `app_router.dart` to restore the last route if it exists.

## Files Created/Updated

*   `pubspec.yaml`: Added `flutter_native_splash` dependency and configuration.
*   `lib/core/router/app_router.dart`: Updated to save and restore the last route.

## Caveats/Considerations

*   The splash screen configuration should be tested on both Android and iOS to ensure it displays correctly.
*   The session recovery logic should handle cases where the last route is no longer valid (e.g., a route that requires authentication when the user is logged out).

## Next Steps or Follow-Ups

*   None.
