import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/providers/reading_schedule_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateScheduleScreen extends ConsumerStatefulWidget {
  final String bookClubId;

  const CreateScheduleScreen({
    super.key,
    required this.bookClubId,
  });

  @override
  ConsumerState<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends ConsumerState<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final List<TextEditingController> _chapterControllers = [
    TextEditingController()
  ];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _chapterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChapter() {
    setState(() {
      _chapterControllers.add(TextEditingController());
    });
  }

  void _removeChapter(int index) {
    setState(() {
      _chapterControllers[index].dispose();
      _chapterControllers.removeAt(index);
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accentMint,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ??
          (_startDate?.add(const Duration(days: 7)) ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accentMint,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createSchedule() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get all non-empty chapter texts
        final chapters = _chapterControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

        await ref.read(readingScheduleProvider('new').notifier).createSchedule(
          widget.bookClubId,
          startDate: _startDate!,
          endDate: _endDate!,
          chapters: chapters,
          notes: _notesController.text.trim(),
        );

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule created successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create schedule: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reading Schedule'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentMint.withOpacity(0.8),
                AppColors.accentMint.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingAnimation())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isDark ? Colors.grey[850]! : Colors.white,
                                isDark ? Colors.grey[900]! : Colors.grey[50]!,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Schedule Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.accentMint,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DatePickerField(
                                      label: 'Start Date',
                                      date: _startDate,
                                      onTap: _selectStartDate,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _DatePickerField(
                                      label: 'End Date',
                                      date: _endDate,
                                      onTap: _selectEndDate,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Reading Plan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.accentMint,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _chapterControllers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              _chapterControllers[index],
                                          decoration: InputDecoration(
                                            labelText: 'Chapter ${index + 1}',
                                            hintText:
                                                'e.g., Chapters 1-3 or Pages 1-50',
                                            prefixIcon: Icon(
                                              Icons.book,
                                              color: AppColors.accentMint,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.accentMint,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.accentMint
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.accentMint,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[100],
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter chapter details';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      if (_chapterControllers.length > 1)
                                        IconButton(
                                          icon:
                                              const Icon(Icons.remove_circle),
                                          onPressed: () =>
                                              _removeChapter(index),
                                          color: Colors.red,
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: _addChapter,
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: AppColors.accentMint,
                                  ),
                                  label: const Text('Add Chapter'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes',
                                  hintText:
                                      'Add any additional notes or instructions...',
                                  alignLabelWithHint: true,
                                  prefixIcon: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 84),
                                    child: Icon(
                                      Icons.note_alt,
                                      color: AppColors.accentMint,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.accentMint,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.accentMint
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.accentMint,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _createSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentMint,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.accentMint.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.accentMint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.accentMint,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null ? dateFormat.format(date!) : 'Select date',
                  style: TextStyle(
                    color: date != null ? null : Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
