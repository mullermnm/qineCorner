import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/reading_goal_provider.dart';
import '../../core/models/reading_goal.dart';
import '../../screens/home/home_screen.dart';

class GoalSetupScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const GoalSetupScreen({
    Key? key,
    this.isOnboarding = false,
  }) : super(key: key);

  @override
  ConsumerState<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends ConsumerState<GoalSetupScreen> {
  late double _goalMinutes;
  late bool _notificationsEnabled;
  late TimeOfDay _notificationTime;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeGoalValues();
  }

  Future<void> _initializeGoalValues() async {
    final currentGoal = ref.read(readingGoalProvider);
    if (currentGoal != null) {
      setState(() {
        _goalMinutes = currentGoal.dailyMinutes.toDouble();
        _notificationsEnabled = currentGoal.notificationsEnabled;
        _notificationTime = TimeOfDay(
          hour: int.parse(currentGoal.notificationTime.split(':')[0]),
          minute: int.parse(currentGoal.notificationTime.split(':')[1]),
        );
        _isInitialized = true;
      });
    } else {
      setState(() {
        _goalMinutes = 30.0;
        _notificationsEnabled = true;
        _notificationTime = const TimeOfDay(hour: 20, minute: 0);
        _isInitialized = true;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Remove the ref.listen as it's not working properly for navigation
    // We'll handle navigation directly in the button press

    return WillPopScope(
      // Handle back button press to navigate back instead of exiting
      onWillPop: () async {
        if (widget.isOnboarding) {
          // If in onboarding, go to home instead of exiting
          context.go('/home');
          return false;
        }
        return true; // Allow normal back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Set Reading Goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          leading: !widget.isOnboarding
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/home'),
                ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Reading Target',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your daily reading goal to track your progress',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '${_goalMinutes.round()} minutes per day',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
                tickMarkShape: const RoundSliderTickMarkShape(),
                activeTickMarkColor: Theme.of(context).primaryColor,
                inactiveTickMarkColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Slider(
                value: _goalMinutes,
                min: 1,
                max: 120,
                divisions: 23,
                label: '${_goalMinutes.round()} min',
                onChanged: (value) {
                  setState(() {
                    _goalMinutes = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text(
                'Daily Reminder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Get notified to read at ${_formatTimeOfDay(_notificationTime)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            if (_notificationsEnabled)
              ListTile(
                title: const Text('Reminder Time'),
                trailing: Text(
                  _formatTimeOfDay(_notificationTime),
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () => _selectTime(context),
              ),
            const Spacer(),
            Row(
              children: [
                if (!widget.isOnboarding)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip for Now',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (!widget.isOnboarding) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isSaving = true;
                            });

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('last_route');

                            final goal = ReadingGoal(
                              dailyMinutes: _goalMinutes.round(),
                              notificationsEnabled: _notificationsEnabled,
                              notificationTime:
                                  _formatTimeOfDay(_notificationTime),
                            );

                            await ref
                                .read(readingGoalProvider.notifier)
                                .saveGoal(goal);

                            if (!mounted) return;

                            setState(() {
                              _isSaving = false;
                            });

                            // Show success toast for all cases
                            Fluttertoast.showToast(
                              msg: 'Reading goal saved successfully!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                            
                            if (widget.isOnboarding) {
                              // Add debug print to track navigation
                              print('DEBUG: Navigating to home from goal setup');
                              
                              // First try to navigate using GoRouter
                              try {
                                context.go('/home');
                              } catch (e) {
                                print('DEBUG: GoRouter navigation error: $e');
                                
                                // Fallback to Navigator if GoRouter fails
                                try {
                                  Navigator.of(context).pushReplacementNamed('/home');
                                } catch (e) {
                                  print('DEBUG: Navigator fallback error: $e');
                                  
                                  // Last resort: use Navigator.pushReplacement with MaterialPageRoute
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                }
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.isOnboarding ? 'Get Started' : 'Save Goal',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
