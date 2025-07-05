# 2025-07-03-shareable-reading-milestones

**Feature Summary:**
This feature introduces "Shareable Reading Milestones" to the Qine Corner Flutter app. Users will be able to see their personal reading achievements (e.g., completing a book, reaching a certain number of pages) presented in a visually appealing card or badge format. These milestones can then be shared on various social media platforms with a pre-designed template that includes the user's profile name, the milestone achieved, and optionally a quote or progress summary. Users will also have the option to save the generated image to their device or share it directly. A dedicated "My Achievements" page will list all previously unlocked milestones.

**Goals and User Flow:**

*   **User Goal:**
    *   View personal reading milestones (book completion, page count, reading streak).
    *   Experience visually appealing milestone presentation (card/badge).
    *   Share milestones on social media (Telegram, WhatsApp, Instagram) with a designed template including profile name, milestone, and optional quote/summary.
    *   Choose to save the shareable image to the device or share directly.
    *   Access all previously unlocked milestones from a "My Achievements" page.

*   **User Flow:**
    1.  User reads a book/uses the app.
    2.  App detects a milestone achievement (e.g., book finished, 100 pages read).
    3.  A notification or pop-up appears, congratulating the user and displaying the `MilestoneCard`.
    4.  User taps a "Share" button on the `MilestoneCard`.
    5.  A sharing options dialog appears, allowing direct share or save to device.
    6.  If sharing, the app generates an image of the `MilestoneCard` and opens the native sharing sheet.
    7.  If saving, the app saves the image to the device's gallery.
    8.  User can navigate to a new "My Achievements" screen from the settings or profile to view all past milestones.

**Implementation Plan and Decisions:**

1.  **Folder Structure:**
    *   Create a new feature directory: `lib/features/milestones/`
        *   `domain/`: Contains `milestone.dart` (data model for a milestone).
        *   `data/`: Contains `milestone_repository.dart` (abstract interface) and `local_milestone_data_source.dart` (implementation using `shared_preferences`).
        *   `presentation/`: Contains `screens/my_achievements_screen.dart` and `widgets/milestone_card.dart`.
        *   `presentation/providers/`: Contains `milestone_provider.dart` (Riverpod state management).

2.  **Milestone Detection Logic:**
    *   **Book Completion:** Modify `lib/screens/book/pdf_viewer_screen.dart` to detect when the user reaches the last page of a book. This will trigger a `book_completed` milestone.
    *   **Page Count:** Implement a global page counter. When a user reads a new page, update this counter. Check for predefined page milestones (e.g., 100, 500, 1000 total pages read). This will trigger `pages_read` milestones.
    *   **Reading Streak:** (Deferred for future iteration due to complexity of daily tracking and background tasks).

3.  **State Management (Riverpod):**
    *   `MilestoneNotifier`: A `StateNotifier` in `milestone_provider.dart` to manage the list of unlocked milestones. It will expose methods to add new milestones and retrieve existing ones.
    *   Providers will be used to expose the `MilestoneNotifier` and its state to the UI.

4.  **Routing (GoRouter):**
    *   Add a new `GoRoute` in `lib/core/router/app_router.dart` for `/achievements` that points to `MyAchievementsScreen`.

5.  **Visuals (`MilestoneCard` Widget):**
    *   Create `lib/features/milestones/presentation/widgets/milestone_card.dart`.
    *   This widget will display the milestone title, description, user's name, and potentially a dynamic element like a quote or progress bar.
    *   Utilize `RepaintBoundary` to enable capturing the widget as an image for sharing.

6.  **Sharing Functionality:**
    *   Integrate the `share_plus` package for native sharing sheet integration.
    *   Implement logic to convert the `MilestoneCard` widget into an image using `RenderRepaintBoundary` and `ui.Image`.
    *   Use `path_provider` to save the generated image to a temporary directory before sharing or saving to the gallery.
    *   For saving to gallery, consider `image_gallery_saver` (requires platform-specific permissions).

7.  **Persistence:**
    *   Use `shared_preferences` in `local_milestone_data_source.dart` to store a list of unlocked milestones (e.g., `Milestone` objects serialized to JSON strings).

8.  **UI Integration:**
    *   Add an entry in `lib/screens/settings/settings_screen.dart` to navigate to the `MyAchievementsScreen`.

**Files Created or Updated:**

*   **New Files:**
    *   `lib/features/milestones/domain/milestone.dart`
    *   `lib/features/milestones/data/milestone_repository.dart`
    *   `lib/features/milestones/data/local_milestone_data_source.dart`
    *   `lib/features/milestones/presentation/screens/my_achievements_screen.dart`
    *   `lib/features/milestones/presentation/widgets/milestone_card.dart`
    *   `lib/features/milestones/presentation/providers/milestone_provider.dart`

*   **Updated Files:**
    *   `pubspec.yaml` (add `share_plus`, `path_provider`, `image_gallery_saver`)
    *   `lib/core/router/app_router.dart`
    *   `lib/screens/settings/settings_screen.dart`
    *   `lib/screens/book/pdf_viewer_screen.dart`

**Challenges or Edge Cases:**

*   **Image Generation Reliability:** Ensuring the `RepaintBoundary` accurately captures the widget's visual state across different devices and Flutter versions. This might require careful testing.
*   **Platform Permissions:** Handling permissions for saving images to the gallery on both Android and iOS.
*   **Milestone Granularity:** Deciding on appropriate thresholds for page-based milestones to avoid overwhelming the user with too many notifications.
*   **Error Handling:** Gracefully handling errors during image generation, sharing, or persistence.
*   **Performance:** Optimizing image generation for large or complex `MilestoneCard` layouts.

**Suggestions for Improvement (Future Iterations):**

*   **More Diverse Milestone Types:** Implement milestones for reading time, genre completion, author completion, etc.
*   **Animated Milestone Unlocks:** Add engaging animations when a new milestone is achieved.
*   **Backend Synchronization:** Store milestones on a backend server for cross-device synchronization and more robust data management.
*   **Push Notifications:** Integrate push notifications to inform users about new milestone unlocks.
*   **Customizable Share Templates:** Allow users to choose from different shareable templates or customize elements like quotes.
*   **Gamification Elements:** Introduce leaderboards or challenges based on milestones.
