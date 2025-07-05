# Task: Implement Highlight & Share Quotes Feature

**Date:** 2025-07-04
**Type:** New Feature

## Description

This task involved implementing an advanced "Highlight & Share Quotes" feature in the Qine Corner Flutter app. The feature allows users to select meaningful text from books (PDFs) and articles, choose from various beautifully designed templates, and share the quote cards to social media platforms. It also provides a manual entry option for unselectable text and includes deep linking for app installation.

## User Flows and UI Behavior

### Text Selection & Sharing
1.  **In PDF Viewer (`PdfViewerScreen`):**
    *   Users can select text within the PDF.
    *   Upon selection, a `showModalBottomSheet` appears with options: "Add Note" and "Share Quote".
    *   Selecting "Share Quote" navigates to the `QuoteShareScreen` with the selected text and book/author details.
2.  **In Article Viewer (`ArticleDetailScreen`):**
    *   Users can select text within the article content (rendered by `ArticleCard` using `QuillEditor`).
    *   Upon selection, a `showModalBottomSheet` appears with options: "Add Note" and "Share Quote".
    *   Selecting "Share Quote" navigates to the `QuoteShareScreen` with the selected text and article/author details.

### Manual Quote Entry
1.  A new button (`Icons.format_quote`) is added to the `AppBar` of `ArticleDetailScreen`.
2.  Tapping this button navigates to `ManualQuoteEntryScreen`.
3.  Users can manually type or paste a quote, and optionally add book title, author name, and their own name.
4.  Saving the quote adds it to local storage and attempts to sync it to the backend.

### Quote Card Preview & Sharing (`QuoteShareScreen`)
1.  Displays the selected/entered quote on a `QuoteCard`.
2.  Provides a horizontal list of template options (e.g., 'default', 'bold', 'calm', 'dark', 'poetic', 'minimalist').
3.  Users can tap on a template to preview how the quote card will look.
4.  A share button in the `AppBar` triggers the sharing functionality.
5.  The `QuoteCard` is converted to an image using `RepaintBoundary` and `dart:ui`.
6.  The image is saved to a temporary directory and then shared via `share_plus`.
7.  A deep link/app store fallback message is included in the shared text.

## Data Model and State Decisions

### `Quote` Model (`lib/features/quotes/domain/models/quote.dart`)
*   Defined using `freezed` for immutability and easy JSON serialization.
*   Fields:
    *   `id`: `String` (unique identifier, e.g., timestamp)
    *   `text`: `String` (the quote content)
    *   `bookTitle`: `String?` (optional, for quotes from books/articles)
    *   `authorName`: `String?` (optional, for quotes from books/articles)
    *   `userName`: `String?` (optional, the user who shared/created it)
    *   `createdAt`: `DateTime`
    *   `templateId`: `String` (default 'default', for selected template)

### Riverpod State Management
*   `quoteRepositoryProvider`: Provides `QuoteRepositoryImpl`.
*   `quoteServiceProvider`: Provides `QuoteService` for backend interaction.
*   `quoteNotifierProvider`: `StateNotifierProvider` managing `AsyncValue<List<Quote>>`.
    *   Handles loading, adding, deleting, and clearing quotes.
    *   `addQuote` triggers a local save and an asynchronous backend sync.

## Template Logic

### `QuoteCard` Widget (`lib/features/quotes/presentation/widgets/quote_card.dart`)
*   A `StatelessWidget` that takes a `Quote` object and a `templateId`.
*   Uses a `switch` statement to render different visual layouts based on `templateId`.
*   Each template (`_buildDefaultTemplate`, `_buildBoldTemplate`, etc.) is a private helper method that returns a `Widget`.
*   Templates use `Theme.of(context)` for consistent styling (colors, text themes) and incorporate visual elements like gradients, shadows, and rounded corners.

## Fallback Handling and Deep Link Strategy

*   **Deep Link:** The plan is to use a deep link to the app (e.g., `qinecorner://quotes/view?id=123`). This requires configuring deep links in `AndroidManifest.xml` (Android) and `Info.plist` (iOS), and handling them in `main.dart` or `app_router.dart`.
*   **Fallback Message:** When sharing, a generic message is appended: "Want to read more? Download Qine Corner now. [Deep Link/App Store Link]". The `[Deep Link/App Store Link]` placeholder needs to be replaced with actual dynamic links or static app store URLs.

## Files Added or Updated

### Added Files:
*   `lib/features/quotes/domain/models/quote.dart`
*   `lib/features/quotes/domain/models/quote.freezed.dart` (generated)
*   `lib/features/quotes/domain/models/quote.g.dart` (generated)
*   `lib/features/quotes/data/quote_repository.dart`
*   `lib/features/quotes/data/local_quote_data_source.dart`
*   `lib/features/quotes/data/quote_repository_impl.dart`
*   `lib/core/services/quote_service.dart`
*   `lib/features/quotes/presentation/providers/quote_provider.dart`
*   `lib/features/quotes/presentation/screens/manual_quote_entry_screen.dart`
*   `lib/features/quotes/presentation/screens/quote_share_screen.dart`
*   `lib/features/quotes/presentation/widgets/quote_card.dart`

### Updated Files:
*   `lib/core/router/app_router.dart`: Added new routes for `/quotes/manual-entry` and `/quotes/share`.
*   `lib/screens/settings/settings_screen.dart`: Updated the "My Achievements" tile to navigate to `/milestones`.
*   `lib/screens/book/pdf_viewer_screen.dart`: Modified `_onTextSelected` to show a bottom sheet with "Add Note" and "Share Quote" options, and navigate to `QuoteShareScreen`.
*   `lib/screens/articles/article_detail_screen.dart`: Added a manual quote entry button to the `AppBar`. Modified `ArticleCard` usage to pass `onTextSelected` callback.
*   `lib/screens/articles/widgets/article_card.dart`: Enabled `enableInteractiveSelection` in `QuillEditor` and added `onSelectionChanged` callback to pass selected text.

## Challenges or Future Feature Suggestions

*   **Deep Link Implementation:** Full deep link implementation (configuring `AndroidManifest.xml` and `Info.plist`, and handling incoming links) is a separate, complex task.
*   **Image Gallery Save:** The `QuoteShareScreen` currently only shares. Adding an option to save the generated image to the gallery (similar to `MilestoneCard`) would be a good addition.
*   **Template Customization:** Allow users to further customize templates (e.g., font choices, background colors) within the app.
*   **Backend Sync for All Quotes:** The current sync only happens when a quote is added. A mechanism to sync all local quotes to the backend (e.g., on app launch or periodically) could be implemented.
*   **Rich Text Selection:** For `flutter_html` in `ArticleDetailScreen`, direct rich text selection might be challenging. The current implementation relies on `QuillEditor` within `ArticleCard`. If `flutter_html` is used directly for content display, a custom text selection overlay might be needed.
*   **Error Handling:** Enhance error handling for network operations in `QuoteService` and `QuoteNotifier`.
*   **User Feedback:** Provide more visual feedback (e.g., loading indicators, success/error messages) during quote saving and sharing.
