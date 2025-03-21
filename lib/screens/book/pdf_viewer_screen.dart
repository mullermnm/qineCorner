import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/api/api_config.dart';
import 'package:qine_corner/core/models/note.dart';
import 'package:qine_corner/core/providers/notes_provider.dart';
import 'package:qine_corner/screens/goal/widgets/goal_congratulations_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/models/book.dart';
import '../../core/theme/app_colors.dart';
import '../../common/widgets/loading_animation.dart';
import '../../screens/error/widgets/animated_error_widget.dart';
import '../notes/widgets/add_note_dialog.dart';
import '../notes/notes_screen.dart';
import '../../core/providers/reading_goal_provider.dart';
import '../../core/providers/recent_books_provider.dart';
import '../../core/providers/reading_streak_provider.dart';
import 'widgets/streak_animation_dialog.dart';
import '../../core/config/app_config.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final Book book;

  const PdfViewerScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  Timer? _readingTimer;
  int _elapsedSeconds = 0;
  bool _isReading = false;
  bool _goalAchieved = false;
  bool _hasShownGoalDialog = false;
  String? _selectedText;

  String get _fullPdfUrl => AppConfig.getPdfUrl(widget.book.filePath);

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _startReadingTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentBooksProvider.notifier).addRecentBook(widget.book);
    });
    
    print('Loading PDF from: $_fullPdfUrl');
  }

  @override
  void dispose() {
    if (!mounted) return;
    
    // Save reading progress before disposing
    try {
      final elapsedMinutes = _elapsedSeconds ~/ 60;
      if (elapsedMinutes > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _saveReadingProgress(elapsedMinutes);
          }
        });
      }
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
    
    _readingTimer?.cancel();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _startReadingTimer() {
    _isReading = true;
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
          _checkGoalProgress();
        });
      }
    });
  }

  void _pauseReadingTimer() {
    _isReading = false;
    _readingTimer?.cancel();
  }

  void _resumeReadingTimer() {
    if (!_isReading) {
      _startReadingTimer();
    }
  }

  void _checkGoalProgress() {
    final goal = ref.read(readingGoalProvider);
    if (goal == null) return;

    if (!_goalAchieved) {
      final elapsedMinutes = _elapsedSeconds ~/ 60;
      if (elapsedMinutes >= goal.dailyMinutes) {
        _goalAchieved = true;
        _handleGoalAchieved(elapsedMinutes, goal.dailyMinutes);
      }
    }
  }

  void _saveReadingProgress(int minutes) {
    if (!mounted) return;
    
    try {
      debugPrint('[_saveReadingProgress] Started with $minutes minutes');
      
      // Update reading goal progress
      final goalNotifier = ref.read(readingGoalProvider.notifier);
      goalNotifier.addReadingTime(minutes);
      
      // Get current progress and goal
      final todayProgress = goalNotifier.getTodayProgress();
      final goal = ref.read(readingGoalProvider);
      
      debugPrint('[_saveReadingProgress] Progress: $todayProgress, Goal: ${goal?.dailyMinutes}');
      
      if (goal != null && todayProgress >= goal.dailyMinutes) {
        debugPrint('[_saveReadingProgress] Goal achieved, showing dialogs');
        _handleGoalAchieved(todayProgress, goal.dailyMinutes);
      }
    } catch (e) {
      debugPrint('[_saveReadingProgress] Error: $e');
    }
  }

  void _handleGoalAchieved(int todayProgress, int dailyGoal) {
    debugPrint('[_handleGoalAchieved] Started');
    // First show congratulations dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => GoalCongratulationsDialog(
        onContinueReading: () async {
          debugPrint('[GoalCongratulationsDialog] Continue reading pressed');
          Navigator.of(context).pop();
          // Add a small delay before showing the next dialog
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            _updateStreakAndShowAnimation(todayProgress, dailyGoal);
          }
        },
        onStop: () async {
          debugPrint('[GoalCongratulationsDialog] Stop pressed');
          Navigator.of(context).pop();
          // Add a small delay before showing the next dialog
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            _updateStreakAndShowAnimation(todayProgress, dailyGoal);
          }
        },
      ),
    );
  }

  Future<void> _updateStreakAndShowAnimation(int todayProgress, int dailyGoal) async {
    try {
      debugPrint('[_updateStreakAndShowAnimation] Started');
      
      // Update streak
      final streakNotifier = ref.read(readingStreakProvider.notifier);
      final streakBefore = ref.read(readingStreakProvider);
      final streakCountBefore = streakBefore?.currentStreak ?? 0;
      
      debugPrint('[_updateStreakAndShowAnimation] Before update - Streak: $streakCountBefore');
      
      // Record reading progress
      await streakNotifier.recordReadingProgress(todayProgress, dailyGoal);
      
      if (!mounted) return;
      
      final streakAfter = ref.read(readingStreakProvider);
      if (streakAfter == null) {
        debugPrint('[_updateStreakAndShowAnimation] Error: Streak is null after update');
        return;
      }
      
      final streakCountAfter = streakAfter.currentStreak;
      debugPrint('[_updateStreakAndShowAnimation] After update - Streak: $streakCountAfter');
      
      // Show streak animation if streak increased
      if (streakCountAfter > streakCountBefore && mounted) {
        debugPrint('[_updateStreakAndShowAnimation] Showing streak animation dialog');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StreakAnimationDialog(
            previousStreak: streakCountBefore,
            newStreak: streakCountAfter,
            achievements: streakAfter.achievements,
            onAnimationComplete: () {
              debugPrint('[StreakAnimationDialog] Animation complete');
              Navigator.of(context).pop();
            },
          ),
        );
      } else {
        debugPrint('[_updateStreakAndShowAnimation] No streak increase: before=$streakCountBefore, after=$streakCountAfter');
      }
    } catch (e, stackTrace) {
      debugPrint('[_updateStreakAndShowAnimation] Error: $e');
      debugPrint('[_updateStreakAndShowAnimation] Stack trace: $stackTrace');
    }
  }

  void _showGoalAchievedDialog() {
    showDialog(
      context: context,
      builder: (context) => GoalCongratulationsDialog(
        onContinueReading: () {
          Navigator.pop(context);
        },
        onStop: () {
          Navigator.pop(context);
          Navigator.pop(context); // Exit reading session
        },
      ),
    );
  }

  String _formatReadingTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildReadingProgress() {
    final goal = ref.watch(readingGoalProvider);
    if (goal == null) return const SizedBox.shrink();

    final elapsedMinutes = _elapsedSeconds ~/ 60;
    final progress = elapsedMinutes / goal.dailyMinutes;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reading Time: ${_formatReadingTime()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Goal: ${goal.dailyMinutes} mins',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isReading ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isReading) {
                _pauseReadingTimer();
              } else {
                _resumeReadingTimer();
              }
            },
          ),
        ],
      ),
    );
  }

  void _onTextSelected(String? text) {
    setState(() {
      _selectedText = text;
    });
    if (text != null && text.isNotEmpty) {
      _showNoteCreationDialog(text);
    }
  }

  Future<void> _showNoteCreationDialog(String highlightedText) async {
    final noteController = TextEditingController();
    final tagsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$highlightedText"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Enter your note...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(
                hintText: 'Add tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final note = Note(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                bookTitle: widget.book.title,
                pageNumber: _currentPage,
                noteText: noteController.text,
                highlightedText: highlightedText,
                createdAt: DateTime.now(),
                tags: tagsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
                bookId: widget.book.id,
              );
              ref.read(notesProvider.notifier).addNote(note);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note added successfully'),
                  action: SnackBarAction(
                    label: 'View',
                    onPressed: () => context.push('/notes'),
                  ),
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Page $_currentPage',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.skip_previous),
              title: const Text('Previous Page'),
              onTap: () {
                _pdfViewerController.previousPage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next),
              title: const Text('Next Page'),
              onTap: () {
                _pdfViewerController.nextPage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pageview),
              title: const Text('Go to Page'),
              onTap: () {
                Navigator.pop(context);
                _showGoToPageDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AddNoteDialog(
                    bookTitle: widget.book.title,
                    currentPage: _currentPage,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('View Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesScreen(
                      initialBookTitle: widget.book.title,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            _fullPdfUrl,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              print('PDF load failed: ${details.error}');
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              _onTextSelected(details.selectedText);
            },
          ),
          if (_isLoading)
            const Center(
              child: LoadingAnimation(),
            ),
          if (_hasError)
            Center(
              child: AnimatedErrorWidget(
                message: 'Failed to load PDF',
                onRetry: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                },
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: _buildReadingProgress(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () => _pdfViewerController.previousPage(),
            ),
            GestureDetector(
              onTap: _showGoToPageDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.white30 : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Page $_currentPage',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () => _pdfViewerController.nextPage(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGoToPageDialog() async {
    final TextEditingController pageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter page number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(pageController.text);
              if (page != null) {
                _pdfViewerController.jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}
