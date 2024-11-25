import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('inquiry').add({
          'user_id': _firebaseAuth.currentUser!.uid,
          'datetime': DateTime.now(),
          'content': _feedbackController.text,
        });
        _feedbackController.clear(); // フォームの内容をクリア
      } catch (e) {
        print(e); // エラーハンドリング
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // キーボードを閉じる
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('こんな機能が欲しい！'),
          backgroundColor: Colors.blue,
          ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('あなたが欲しい機能の意見や要望などがあれば教えてください。'),
                SizedBox(height: 10),
                TextFormField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: '要望を入力',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '文字を入力してください。';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitFeedback,
                  child: Text('送信'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
