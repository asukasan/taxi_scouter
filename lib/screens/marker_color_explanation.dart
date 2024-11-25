import 'package:flutter/material.dart';

class MarkerColorExplanationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20 , 20, 20), // 24はボタンのサイズの半分
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('マーカーの色の説明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('マーカーの色はタクシーの数、客の数、更新してからの時間によって変わります。'),
                  SizedBox(height: 20),
                  _buildRow('assets/images/marker_red.jpg', '客数が多い乗り場'),
                  _buildRow('assets/images/marker_yellow.jpg', '客数が普通な乗り場'),
                  _buildRow('assets/images/marker_blue.jpg', '客数が少ない乗り場'),
                  _buildRow('assets/images/marker_green.jpg', '直近の更新がない乗り場'),
                ],
              ),
            ),
          ),
          Positioned(
            right: -12, // ダイアログの外側にボタンを少し出す
            top: -12, // ダイアログの外側にボタンを少し出す
            child: CircleAvatar(
              backgroundColor: Colors.white, // ボタンの背景色
              radius: 16, // ボタンのサイズ
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String imagePath, String text) {
    return Row(
      children: <Widget>[
        Image.asset(imagePath, width: 50, height: 50),
        SizedBox(width: 10),
        Text(text),
      ],
    );
  }
}
