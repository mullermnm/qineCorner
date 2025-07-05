# Qine Corner Architecture Rules

This document outlines the architecture, patterns, and naming conventions to be followed for all future development of the Qine Corner app.

## 1. Folder Structure

The project follows a feature-first folder structure.

- **`lib/screens/{feature_name}`**: Each feature has its own directory containing its screens, widgets, and any feature-specific logic.
- **`lib/common/`**: Shared logic is organized into subdirectories:
    - `lib/common/widgets/`: Widgets shared across multiple features.
    - `lib/core/api/`: API service definitions.
    - `lib/core/config/`: Application-level configuration.
    - `lib/core/constants/`: Application constants.
    - `lib/core/errors/`: Error handling classes and utilities.
    - `lib/core/models/`: Data models.
    - `lib/core/providers/`: Shared Riverpod providers.
    - `lib/core/router/`: Navigation and routing configuration.
    - `lib/core/services/`: Business logic services.
    - `lib/core/theme/`: Application theme definitions.
    - `lib/core/utils/`: Utility functions.
- **`lib/widgets/`**: Reusable widgets that are not specific to any feature.

## 2. State Management

- **Riverpod** is the primary state management solution.
- **`Notifier` and `AsyncNotifier`** are used to manage state.
- Providers should be defined in the most appropriate location:
    - Feature-specific providers should be located within the feature's directory.
    - Shared providers should be located in `lib/core/providers/`.

## 3. Navigation

- **`go_router`** is used for navigation.
- All routes are defined in **`lib/core/router/app_router.dart`**.
- A `ShellRoute` is used for the main application layout with bottom navigation.
- When adding a new screen, it must be registered in `app_router.dart`.

## 4. Code Style and Conventions

- **Naming:**
    - Files should be named using `snake_case.dart`.
    - Classes should be named using `PascalCase`.
    - Variables and functions should be named using `camelCase`.
- **Readability:** Code should be well-formatted, commented where necessary, and easy to understand.
- **DRY (Don't Repeat Yourself):** Avoid code duplication by creating reusable widgets, functions, and services.
- **Separation of Concerns:** Maintain a clear separation between UI, business logic, and data layers.

## 5. API Calls

- API calls are managed through services located in `lib/core/services/`.
- Use `dio` for making HTTP requests.
- API models are defined in `lib/core/models/`.

## 6. Error Handling

- Global error handling is implemented with custom error screens and widgets.
- Use `try-catch` blocks for operations that can fail, and display user-friendly error messages.

## 7. Theme

- The application has custom light and dark themes defined in `lib/core/theme/app_theme.dart`.
- A `ThemeProvider` in `lib/core/theme/theme_provider.dart` manages the current theme.

## Update Policies

- **New Features:** Create a new directory in `lib/screens/` for the feature.
- **Shared Logic:** If logic is shared across features, place it in the appropriate `lib/common/` or `lib/core/` subdirectory.
- **Routes:** Register new routes in `lib/core/router/app_router.dart`.
- **State:** Use Riverpod providers for state management, following the established patterns.
- **Theme:** Update the theme via `AppTheme` and `ThemeProvider`.
- **Validation:** Before committing any changes, ensure they align with these architectural rules.
