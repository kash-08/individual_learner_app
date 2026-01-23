// lib/widgets/settings_section.dart
import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class SettingsSection extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  late AppSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Notification Settings
            _buildSettingSwitch(
              title: 'Push Notifications',
              value: _currentSettings.notificationsEnabled,
              icon: Icons.notifications,
              onChanged: (value) {
                _updateSettings(_currentSettings.copyWith(
                  notificationsEnabled: value,
                ));
              },
            ),
            _buildSettingSwitch(
              title: 'Email Notifications',
              value: _currentSettings.emailNotifications,
              icon: Icons.email,
              onChanged: (value) {
                _updateSettings(_currentSettings.copyWith(
                  emailNotifications: value,
                ));
              },
            ),
            _buildSettingSwitch(
              title: 'Dark Mode',
              value: _currentSettings.darkMode,
              icon: Icons.dark_mode,
              onChanged: (value) {
                _updateSettings(_currentSettings.copyWith(
                  darkMode: value,
                ));
              },
            ),
            _buildSettingSwitch(
              title: 'Auto-play Videos',
              value: _currentSettings.autoPlayVideos,
              icon: Icons.play_circle_fill,
              onChanged: (value) {
                _updateSettings(_currentSettings.copyWith(
                  autoPlayVideos: value,
                ));
              },
            ),

            const SizedBox(height: 20),

            // Study Preferences
            Text(
              'Study Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Daily Goal
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Daily Study Goal'),
              subtitle: Text('${_currentSettings.dailyGoalMinutes} minutes'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editDailyGoal,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Study Reminder
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Study Reminder'),
              subtitle: Text(_currentSettings.studyReminderTime),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editReminderTime,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSettingsChanged(_currentSettings);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save All Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
  }

  void _editDailyGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Daily study goal in minutes: ${_currentSettings.dailyGoalMinutes}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _currentSettings.dailyGoalMinutes.toDouble(),
              min: 15,
              max: 240,
              divisions: 15,
              label: '${_currentSettings.dailyGoalMinutes} minutes',
              onChanged: (value) {
                _updateSettings(_currentSettings.copyWith(
                  dailyGoalMinutes: value.toInt(),
                ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editReminderTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().copyWith(
          hour: int.parse(_currentSettings.studyReminderTime.split(':')[0]),
          minute: int.parse(_currentSettings.studyReminderTime.split(':')[1]),
        ),
      ),
    ).then((time) {
      if (time != null) {
        _updateSettings(_currentSettings.copyWith(
          studyReminderTime:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        ));
      }
    });
  }
}