import 'package:flutter/material.dart';
import 'package:taxi_scouter/models/app_user.dart';
import 'package:taxi_scouter/components/app_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_scouter/screens/profile_screen/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;

  setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<AppUser?>(
        stream: _fetchAppUser(),
        builder: (context, snapshot) {
          final appUser = snapshot.data;

          if (appUser == null) {
            return const Center(child: AppLoading(color: Colors.blue));
          }

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return EditProfileScreen(user: appUser);
                        }),
                      );
                    },
                    child: const Text(
                      '編集',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appUser.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _signOut(context),
                  child: isLoading
                      ? const AppLoading(color: Colors.blue)
                      : const Text('サインアウト'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<AppUser?> _fetchAppUser() {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      return FirebaseFirestore.instance
          .collection('app_users')
          .doc(userId)
          .snapshots()
          .map((snap) => AppUser.fromDoc(
                snap.id,
                snap.data() as Map<String, dynamic>,
              ));
    } catch (e) {
      print(e);
    }
    return const Stream.empty();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      setIsLoading(true);
      await Future.delayed(
        const Duration(seconds: 1),
        () => FirebaseAuth.instance.signOut(),
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    } finally {
      setIsLoading(false);
    }
  }
}
