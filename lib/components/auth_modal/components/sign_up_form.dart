import 'package:flutter/material.dart';
import 'package:taxi_scouter/components/auth_modal/components/submit_button.dart';
import 'package:taxi_scouter/components/auth_modal/components/auth_text_form_field.dart';
import 'package:taxi_scouter/components/auth_modal/components/animated_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_scouter/components/auth_modal/components/auth_modal_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------  Validation ---------

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '文字を入力して下さい。';
    }
    // メールアドレスの形式を確認する正規表現パターン
    String pattern = r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return '無効なメールアドレスです。';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '文字を入力して下さい。';
    }
    if (value.length < 8) {
      return 'パスワードは8文字以上である必要があります。';
    }
    // 大文字、小文字、数字を含むかを確認する正規表現パターン
    RegExp upperCasePattern = RegExp(r'[A-Z]');
    RegExp lowerCasePattern = RegExp(r'[a-z]');
    RegExp numberPattern = RegExp(r'\d');

    if (!upperCasePattern.hasMatch(value)) {
      return '少なくとも1つの大文字を含む必要があります。';
    }
    if (!lowerCasePattern.hasMatch(value)) {
      return '少なくとも1つの小文字を含む必要があります。';
    }
    if (!numberPattern.hasMatch(value)) {
      return '少なくとも1つの数字を含む必要があります。';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '文字を入力して下さい。';
    }
    if (value != _passwordController.text) {
      return 'パスワードが一致しません。';
    }
    return null;
  }

  // ---------  StateChanges ---------
  void _setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void _clearErrorMessage() {
    setState(() {
      errorMessage = '';
    });
  }

  void _setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            '新規登録',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const AuthModalImage(),
          AnimatedErrorMessage(errorMessage: errorMessage),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _emailController,
            onChanged: (value) => _clearErrorMessage(),
            validator: validateEmail,
            labelText: 'Email',
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (value) => _clearErrorMessage(),
            validator: validatePassword,
            labelText: 'Password',
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            obscureText: true,
            onChanged: (value) => _clearErrorMessage(),
            validator: validateConfirmPassword,
            labelText: 'Confirm Password',
          ),
          const SizedBox(height: 16.0),
          SubmitButton(
            labelName: '新規登録',
            isLoading: isLoading,
            onTap: () => _submit(context),
          ),
        ],
      ),
    );
  }

   Future<void> createAppUser(String userId) async {
    await FirebaseFirestore.instance.collection('app_users').doc(userId).set({
      'name': 'your name please!',
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // サインアップ処理
      final UserCredential? user = await signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 500ミリ秒待って、モーダルを閉じる
      if (user != null) {
        await createAppUser(user.user!.uid);
        if (!mounted) return;
        Future.delayed(
          const Duration(milliseconds: 500),
          Navigator.of(context).pop,
        );
      }
    }
  }

  // ---------  Sign Up ---------

  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _setIsLoading(true);
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _setErrorMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _setErrorMessage('The account already exists for that email.');
      } else {
        _setErrorMessage('Unidentified error occurred while signing up.');
      }
    } finally {
      _setIsLoading(false);
    }
    return null;
  }
}
