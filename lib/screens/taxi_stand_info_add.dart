import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaxiStandInfoAdd extends StatefulWidget {
  final String taxiStandName;
  final String taxiStandAddress;
  final String taxiStandId;

  const TaxiStandInfoAdd({
    Key? key,
    required this.taxiStandName,
    required this.taxiStandAddress,
    required this.taxiStandId,
  }) : super(key: key);

  @override
  _TaxiStandInfoAddState createState() => _TaxiStandInfoAddState();
}

class _TaxiStandInfoAddState extends State<TaxiStandInfoAdd> {
  final _formKey = GlobalKey<FormState>();
  final _customersController = TextEditingController();
  final _taxisController = TextEditingController();

  void _addTaxiStandInfo() async {
    if (_formKey.currentState!.validate()) {
      // Firebaseにデータを追加
      String ? uid = getCurrentUserUID();
      await FirebaseFirestore.instance.collection('taxi_stand_info').add({
        'customers': int.parse(_customersController.text),
        'taxis': int.parse(_taxisController.text),
        'datetime': DateTime.now(),
        'taxi_stand_id': widget.taxiStandId,
        'add_user_id': uid != null ? uid.toString() : '',
      });
      Navigator.of(context).pop();
    }
  }

  String? getCurrentUserUID() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    return user?.uid; // ユーザーがログインしている場合はUIDを返し、そうでなければnullを返す
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // キーボードを閉じる
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.taxiStandName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _customersController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(labelText: '客数'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) < 0 || int.parse(value) > 100) {
                    return '0〜100の数字を入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _taxisController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(labelText: 'タクシー数'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) < 0 || int.parse(value) > 100) {
                    return '0〜100の数字を入力してください';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('戻る'),
                  ),
                  ElevatedButton(
                    onPressed: _addTaxiStandInfo,
                    child: Text('追加'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
