import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/timetable_provider.dart';
import '../providers/course_provider.dart';
import '../models/timetable_model.dart';
import '../components/timetable_slot_card.dart';

class SmartTimetableScreen extends StatefulWidget {
  const SmartTimetableScreen({super.key});

  @override
  State<SmartTimetableScreen> createState() => _SmartTimetableScreenState();
}

class _SmartTimetableScreenState extends State<SmartTimetableScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<TimetableSlot> _selectedSlots = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    await Provider.of<TimetableProvider>(context, listen: false)
        .loadTimetableSlots();
    _updateSelectedSlots();
  }

  void _updateSelectedSlots() {
    if (_selectedDay != null) {
      final timetableProvider = Provider.of<TimetableProvider>(
          context, listen: false);
      _selectedSlots = timetableProvider.getSlotsForDate(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Timetable'),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSlotDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAISuggestionsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatistics(context),
          ),
        ],
      ),
      body: Consumer<TimetableProvider>(
        builder: (context, timetableProvider, child) {
          if (timetableProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Calendar View
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _updateSelectedSlots();
                    },
                    onPageChanged: (focusedDay) {
                      setState(() => _focusedDay = focusedDay);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF4361EE).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF4361EE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: const Color(0xFF4361EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: const TextStyle(color: Colors.white),
                    ),
                    eventLoader: (day) {
                      final slots = timetableProvider.getSlotsForDate(day);
                      return slots.map((slot) => slot.id).toList();
                    },
                  ),
                ),
              ),

              // Selected Day Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDay != null
                          ? '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                          : 'Select a date',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text('${_selectedSlots.length} slots'),
                      backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Timetable Slots for Selected Day
              Expanded(
                child: _selectedSlots.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _selectedSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _selectedSlots[index];
                    return TimetableSlotCard(
                      slot: slot,
                      onToggleComplete: (isCompleted) async {
                        await timetableProvider.toggleSlotCompletion(
                          slot.id,
                          isCompleted,
                        );
                        setState(() {});
                      },
                      onEdit: () => _showEditSlotDialog(context, slot),
                      onDelete: () => _showDeleteDialog(context, slot),
                    );
                  },
                ),
              ),

              // Quick Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      icon: Icons.today,
                      label: 'Today',
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime.now();
                          _focusedDay = DateTime.now();
                        });
                        _updateSelectedSlots();
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.auto_fix_high,
                      label: 'AI Plan',
                      onPressed: () => _showAISuggestionsDialog(context),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onPressed: () => _showSettings(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSlotDialog(context),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Study Slots Scheduled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add study slots to create your perfect timetable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddSlotDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add First Slot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: const Color(0xFF4361EE),
          onPressed: onPressed,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4361EE),
          ),
        ),
      ],
    );
  }

  // Dialog for adding new slot
  void _showAddSlotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditTimetableSlotDialog(
        onSave: (slot) async {
          final timetableProvider = Provider.of<TimetableProvider>(
              context, listen: false);
          await timetableProvider.addTimetableSlot(slot);
          _updateSelectedSlots();
        },
      ),
    );
  }

  // Dialog for editing slot
  void _showEditSlotDialog(BuildContext context, TimetableSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AddEditTimetableSlotDialog(
        slot: slot,
        onSave: (updatedSlot) async {
          final timetableProvider = Provider.of<TimetableProvider>(
              context, listen: false);
          await timetableProvider.updateTimetableSlot(updatedSlot);
          _updateSelectedSlots();
        },
      ),
    );
  }

  // Dialog for deleting slot
  void _showDeleteDialog(BuildContext context, TimetableSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slot'),
        content: Text('Are you sure you want to delete "${slot.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final timetableProvider = Provider.of<TimetableProvider>(
                  context, listen: false);
              await timetableProvider.deleteTimetableSlot(slot.id);
              _updateSelectedSlots();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Dialog for AI suggestions
  void _showAISuggestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AISuggestionsDialog(
        onApplySuggestions: (suggestions) async {
          final timetableProvider = Provider.of<TimetableProvider>(
              context, listen: false);
          for (var suggestion in suggestions) {
            await timetableProvider.addTimetableSlot(suggestion);
          }
          _updateSelectedSlots();
        },
      ),
    );
  }

  // Show statistics
  void _showStatistics(BuildContext context) {
    final timetableProvider = Provider.of<TimetableProvider>(
        context, listen: false);
    final stats = timetableProvider.getStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timetable Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('Total Slots', '${stats.totalSlots}'),
              _buildStatItem('Completed', '${stats.completedSlots}'),
              _buildStatItem('Upcoming', '${stats.upcomingSlots}'),
              _buildStatItem('Total Study Hours',
                  '${stats.totalStudyHours.toStringAsFixed(1)}h'),
              _buildStatItem('Avg Daily Study Time',
                  '${stats.averageStudyTimePerDay.toStringAsFixed(1)}h'),
              const SizedBox(height: 16),
              const Text(
                'Study Time Distribution',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...stats.studyTimeByDay.entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text('${(entry.value / 60).toStringAsFixed(1)}h'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Settings dialog
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timetable Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Auto-generate from Courses'),
                value: true,
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Notification Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // Add time picker here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Add/Edit Slot Dialog
class AddEditTimetableSlotDialog extends StatefulWidget {
  final TimetableSlot? slot;
  final Function(TimetableSlot) onSave;

  const AddEditTimetableSlotDialog({
    super.key,
    this.slot,
    required this.onSave,
  });

  @override
  State<AddEditTimetableSlotDialog> createState() =>
      _AddEditTimetableSlotDialogState();
}

class _AddEditTimetableSlotDialogState
    extends State<AddEditTimetableSlotDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _selectedCourseId;
  bool _isRecurring = false;
  final List<int> _selectedDays = [];
  DateTime? _recurringEndDate;

  final List<String> _colors = [
    '#4361EE', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
  ];
  String _selectedColor = '#4361EE';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.slot != null) {
      _titleController = TextEditingController(text: widget.slot!.title);
      _descriptionController = TextEditingController(
          text: widget.slot!.description);
      _selectedDate = widget.slot!.date;
      _startTime = widget.slot!.startTime;
      _endTime = widget.slot!.endTime;
      _selectedCourseId = widget.slot!.courseId;
      _isRecurring = widget.slot!.isRecurring;
      _selectedDays.addAll(widget.slot!.recurringDays);
      _recurringEndDate = widget.slot!.recurringEndDate;
      _selectedColor = widget.slot!.colorHex;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay(
        hour: _startTime.hour + 1,
        minute: _startTime.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final enrolledCourses = courseProvider.enrolledCourses;

    return AlertDialog(
      title: Text(widget.slot == null ? 'Add Study Slot' : 'Edit Study Slot'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Math Revision',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (enrolledCourses.isNotEmpty)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Course (Optional)',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('None'),
                        ),
                        ...enrolledCourses.map((course) {
                          return DropdownMenuItem(
                            value: course.id,
                            child: Text(course.title),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCourseId = value);
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Color:'),
                const SizedBox(width: 8),
                ..._colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.substring(1, 7),
                            radix: 16) + 0xFF000000),
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring'),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 8),
              const Text('Repeat on:'),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final dayName = _getDayName(dayNumber);
                  final isSelected = _selectedDays.contains(dayNumber);

                  return FilterChip(
                    label: Text(dayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(dayNumber);
                        } else {
                          _selectedDays.remove(dayNumber);
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectRecurringEndDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Repeat Until',
                  ),
                  child: Text(
                    _recurringEndDate != null
                        ? '${_recurringEndDate!.day}/${_recurringEndDate!.month}/${_recurringEndDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSlot,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          // Auto-adjust end time if it's before start time
          if (_endTime.hour < _startTime.hour ||
              (_endTime.hour == _startTime.hour &&
                  _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(
              hour: _startTime.hour + 1,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _selectRecurringEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _recurringEndDate ?? DateTime.now().add(
          const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _recurringEndDate = pickedDate);
    }
  }

  String _getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  void _saveSlot() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final slot = TimetableSlot(
      id: widget.slot?.id ?? '',
      userId: '', // Will be set by provider
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      title: _titleController.text,
      description: _descriptionController.text,
      courseId: _selectedCourseId ?? '',
      colorHex: _selectedColor,
      isCompleted: widget.slot?.isCompleted ?? false,
      isRecurring: _isRecurring,
      recurringDays: _selectedDays,
      recurringEndDate: _recurringEndDate,
      createdAt: widget.slot?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(slot);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// AI Suggestions Dialog
class AISuggestionsDialog extends StatefulWidget {
  final Function(List<TimetableSlot>) onApplySuggestions;

  const AISuggestionsDialog({super.key, required this.onApplySuggestions});

  @override
  State<AISuggestionsDialog> createState() => _AISuggestionsDialogState();
}

class _AISuggestionsDialogState extends State<AISuggestionsDialog> {
  int _preferredHours = 2;
  final List<int> _selectedDays = [1, 3, 5]; // Mon, Wed, Fri
  TimeOfDay _preferredStartTime = const TimeOfDay(hour: 18, minute: 0);
  int _weeks = 4;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Timetable Suggestions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Let AI create an optimal study schedule for you',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Study Hours Per Day:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _preferredHours.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$_preferredHours hours',
                    onChanged: (value) {
                      setState(() => _preferredHours = value.toInt());
                    },
                  ),
                ),
                Text('$_preferredHours'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Preferred Days:'),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final dayNumber = index + 1;
                final dayName = _getDayName(dayNumber);
                final isSelected = _selectedDays.contains(dayNumber);

                return FilterChip(
                  label: Text(dayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(dayNumber);
                      } else {
                        _selectedDays.remove(dayNumber);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectStartTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Preferred Start Time',
                ),
                child: Text(_preferredStartTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Generate for:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _weeks.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: '$_weeks weeks',
                    onChanged: (value) {
                      setState(() => _weeks = value.toInt());
                    },
                  ),
                ),
                Text('$_weeks weeks'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _generateSuggestions,
          child: const Text('Generate & Apply'),
        ),
      ],
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _preferredStartTime,
    );

    if (pickedTime != null) {
      setState(() => _preferredStartTime = pickedTime);
    }
  }

  String _getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  void _generateSuggestions() async {
    final timetableProvider = Provider.of<TimetableProvider>(
        context, listen: false);
    final suggestions = await timetableProvider.generateAISuggestions(
      courseIds: [],
      preferredStudyHoursPerDay: _preferredHours,
      preferredDays: _selectedDays,
      preferredStartTime: _preferredStartTime,
      weeks: _weeks,
    );

    widget.onApplySuggestions(suggestions);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generated ${suggestions.length} AI suggestions'),
        backgroundColor: Colors.green,
      ),
    );
  }
}