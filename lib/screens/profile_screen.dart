import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('No user logged in', style: TextStyle(color: Colors.white70)),
      );
    }

    return Container(
      color: AppColors.background,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Null-safe read: never crash even if the Firestore doc or fields
          // are missing (e.g. right after signup, before the doc is created).
          final data = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};
          final rawName = (data['name'] as String?)?.trim();
          final name = (rawName != null && rawName.isNotEmpty) ? rawName : (user.email ?? 'User');
          final email = (data['email'] as String?) ?? user.email ?? '';
          final createdAt = data['createdAt'];
          final createdText =
              createdAt is Timestamp ? createdAt.toDate().toString().split(' ')[0] : '—';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 38,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),
                Text(
                  'Account created: $createdText',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
