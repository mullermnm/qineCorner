import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:qine_corner/core/models/reading_goal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/book.dart';
import '../providers/reading_goal_provider.dart';
import '../providers/book_shelf_provider.dart';

// Constants for widget data
const String appWidgetCurrentBook = "app_widget_current_book";
const String appWidgetGoalProgress = "app_widget_goal_progress";
const String backgroundCallback = "updateHomeWidgetBackground";

@pragma('vm:entry-point')
void callbackDispatcher(Uri? uri) async {
  try {
    await updateHomeWidget();
  } catch (e) {
    print('Error in callback dispatcher: $e');
  }
}

Future<void> initializeHomeWidget() async {
  try {
    await HomeWidget.registerBackgroundCallback(callbackDispatcher);
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask(
      "updateHomeWidget",
      backgroundCallback,
      frequency: const Duration(minutes: 15),
    );

    // Initial update
    await updateHomeWidget();
  } catch (e) {
    print('Error initializing home widget: $e');
  }
}

Future<void> updateHomeWidget() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Get current book
    final currentBookJson =
        prefs.getString('${BookShelf.currentlyReading.toString()}_current');
    String bookTitle = 'No book selected';
    String goalProgress = 'No reading goal set';

    if (currentBookJson != null) {
      try {
        final bookMap = json.decode(currentBookJson);
        final currentBook = Book.fromJson(bookMap);
        bookTitle = currentBook.title;
      } catch (e) {
        print('Error parsing current book: $e');
      }
    }

    // Get reading goal progress
    final goalJson = prefs.getString('reading_goal');
    final progressJson = prefs.getString('reading_progress');

    if (goalJson != null && progressJson != null) {
      try {
        final goalMap = json.decode(goalJson);
        final progressMap = json.decode(progressJson);
        final goal = ReadingGoal.fromJson(goalMap);
        final progress = progressMap['minutes'] as int;
        goalProgress = '$progress/${goal.dailyMinutes} minutes';
      } catch (e) {
        print('Error parsing goal/progress: $e');
      }
    }

    // Update the widget
    await HomeWidget.saveWidgetData<String>(
      appWidgetCurrentBook,
      bookTitle,
    );
    await HomeWidget.saveWidgetData<String>(
      appWidgetGoalProgress,
      goalProgress,
    );

    await HomeWidget.updateWidget(
      name: 'QineCornerHomeWidget',
      androidName: 'QineCornerHomeWidget',
    );
  } catch (e) {
    print('Error updating widget: $e');
  }
}
