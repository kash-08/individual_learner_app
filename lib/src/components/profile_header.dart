// lib/components/profile_header.dart
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              profile.name ?? 'No Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              profile.email ?? 'No Email',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Study Focus
            if (profile.studyFocus != null && profile.studyFocus!.isNotEmpty)
              Text(
                profile.studyFocus!,
                style: const TextStyle(
                  color: Color(0xFF4361EE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

            // Bio
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}