import 'package:flutter/material.dart';
import 'package:taxi_scouter/models/app_user.dart';
import 'package:taxi_scouter/components/app_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    _nameController.text = widget.user.name;
    super.initState();
  }

  void _setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetectorを追加
    return GestureDetector(
      onTap: () {
        // キーボードを閉じる
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('プロフィールの修正'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ユーザー名のテキストフィールド
                      TextField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        controller: _nameController,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: updateProfile,
                child: isLoading ? const AppLoading() : const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    try {
      _setIsLoading(true);
      await FirebaseFirestore.instance
          .collection('app_users')
          .doc(widget.user.id)
          .update({
        'name': _nameController.text,
      });

      await Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      print(e);
    } finally {
      _setIsLoading(false);
    }
  }
}
