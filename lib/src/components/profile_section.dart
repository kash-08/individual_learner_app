// lib/widgets/profile_section.dart
import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class ProfileSection extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<List<String>> onUpdateInterests;

  const ProfileSection({
    super.key,
    required this.profile,
    required this.onUpdateInterests,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late List<String> _interests;
  final TextEditingController _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _interests = List.from(widget.profile.interests);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Interests & Preferences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _addInterest,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Interest',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Interests Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.map((interest) {
                return Chip(
                  label: Text(interest),
                  onDeleted: () => _removeInterest(interest),
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
            ),

            if (_interests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No interests added yet. Add your learning interests to get personalized recommendations.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Preferences
            _buildPreferenceItem(
              icon: Icons.school,
              title: 'Study Focus',
              value: widget.profile.studyFocus ?? 'Not specified',
            ),
            _buildPreferenceItem(
              icon: Icons.language,
              title: 'Preferred Language',
              value: widget.profile.preferredLanguage ?? 'English',
            ),
            _buildPreferenceItem(
              icon: Icons.timer,
              title: 'Daily Goal',
              value: '${widget.profile.preferences['dailyGoal'] ?? 60} minutes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addInterest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: _interestController,
          decoration: const InputDecoration(
            hintText: 'Enter your interest (e.g., Machine Learning)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final interest = _interestController.text.trim();
              if (interest.isNotEmpty && !_interests.contains(interest)) {
                setState(() {
                  _interests.add(interest);
                });
                widget.onUpdateInterests(_interests);
                _interestController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
    widget.onUpdateInterests(_interests);
  }
}