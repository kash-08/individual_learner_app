// lib/screens/course_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';

class CoursePreferencesScreen extends StatefulWidget {
  const CoursePreferencesScreen({super.key});

  @override
  State<CoursePreferencesScreen> createState() => _CoursePreferencesScreenState();
}

class _CoursePreferencesScreenState extends State<CoursePreferencesScreen> {
  List<String> _selectedCategories = [];
  List<String> _selectedDifficulties = [];
  int _dailyGoalMinutes = 60;
  String _preferredLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadUserProfile();

    final profile = profileProvider.userProfile;
    final settings = profileProvider.appSettings;

    if (profile != null) {
      setState(() {
        _selectedCategories = settings.preferredCategories;
        _selectedDifficulties = [settings.difficultyPreference];
        _dailyGoalMinutes = settings.dailyGoalMinutes;
        _preferredLanguage = profile.preferredLanguage ?? 'English';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final allCategories = courseProvider.getAllCategories();
    final difficulties = ['Beginner', 'Intermediate', 'Advanced'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Preferences'),
        backgroundColor: const Color(0xFF4361EE),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            _buildSection(
              title: 'Preferred Categories',
              subtitle: 'Select categories you\'re interested in',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF4361EE).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF4361EE),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Difficulty Level
            _buildSection(
              title: 'Difficulty Level',
              subtitle: 'Choose your preferred difficulty',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: difficulties.map((difficulty) {
                    final isSelected = _selectedDifficulties.contains(difficulty);
                    return ChoiceChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDifficulties = [difficulty];
                          }
                        });
                      },
                      selectedColor: const Color(0xFF4361EE),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Daily Goal
            _buildSection(
              title: 'Daily Study Goal',
              subtitle: 'Set your daily learning target',
              children: [
                Column(
                  children: [
                    Text(
                      '$_dailyGoalMinutes minutes',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4361EE),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _dailyGoalMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '$_dailyGoalMinutes min',
                      onChanged: (value) {
                        setState(() {
                          _dailyGoalMinutes = value.toInt();
                        });
                      },
                      activeColor: const Color(0xFF4361EE),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('15 min', style: TextStyle(color: Colors.grey)),
                        Text('4 hours', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language Preference
            _buildSection(
              title: 'Preferred Language',
              subtitle: 'Choose content language',
              children: [
                DropdownButtonFormField<String>(
                  value: _preferredLanguage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  items: ['English', 'Spanish', 'French', 'German', 'Chinese']
                      .map((language) => DropdownMenuItem(
                    value: language,
                    child: Text(language),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _preferredLanguage = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetPreferences,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Reset to Default'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentSettings = profileProvider.appSettings;

      // Update profile
      await profileProvider.updateProfile(
        preferredLanguage: _preferredLanguage,
      );

      // Update settings
      await profileProvider.updateSettings(
        currentSettings.copyWith(
          preferredCategories: _selectedCategories,
          difficultyPreference: _selectedDifficulties.isNotEmpty
              ? _selectedDifficulties.first.toLowerCase()
              : 'intermediate',
          dailyGoalMinutes: _dailyGoalMinutes,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preferences: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text('Are you sure you want to reset all preferences to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedCategories = [];
                _selectedDifficulties = ['Intermediate'];
                _dailyGoalMinutes = 60;
                _preferredLanguage = 'English';
              });
              _savePreferences();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
