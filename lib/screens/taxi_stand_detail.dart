import 'package:flutter/material.dart';
import 'package:taxi_scouter/models/taxi_station_info.dart';
import 'package:taxi_scouter/models/taxi_station.dart';
import 'package:taxi_scouter/screens/taxi_stand_info_add.dart';
import 'package:taxi_scouter/screens/map_screen/components/taxi_stand_info_detail_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiStandDetail extends StatefulWidget {
  final String name;
  final String address;

  TaxiStandDetail({
    Key? key,
    required this.name,
    required this.address,
  }) : super(key: key);

  @override
  _TaxiStandDetailState createState() => _TaxiStandDetailState();
}

class _TaxiStandDetailState extends State<TaxiStandDetail> {
  String taxi_stand_id = '';
  List<TaxiStandInfo> taxi_stand_info_list = []; // メンバー変数として宣言

  @override
  void initState() {
    super.initState();
    getTaxiStandData(); // データ取得メソッドを呼び出し
  }

  Future<void> getTaxiStandData() async {
    String? id = await TaxiStand.getDocumentIdByNameAndAddress(widget.name, widget.address);
    if (id != null) {
      setState(() {
        taxi_stand_id = id.toString();
      });

      // データを取得し、taxi_stand_info_listに代入
      List<TaxiStandInfo> infoList = await TaxiStandInfo.getLatestTaxiStands(taxi_stand_id);
      for (var info in infoList) {
        String userName = await getUserName(info.add_user_id);
        info.add_user_name = userName; 
      }
      setState(() {
        taxi_stand_info_list = infoList;
      });
    }
  }

  Future<String> getUserName(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot userDoc = await firestore.collection('app_users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;  // Map型にキャスト
        return data?['name'];  // nameフィールドを取得
      } else {
        return '';  // ドキュメントが存在しない場合
      }
    } catch (e) {
      return '';  // エラーが発生した場合
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TaxiInfoCardList(taxi_stand_info_list: taxi_stand_info_list),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                ),
                child: const Text('戻る'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: TaxiStandInfoAdd(
                          taxiStandName: widget.name, // nameを渡す
                          taxiStandAddress: widget.address, // addressを渡す
                          taxiStandId: taxi_stand_id,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      );
                    },
                  ).then((_) {
                    // showDialogが閉じた後、setStateを呼び出して画面を更新
                    setState(() {
                      getTaxiStandData();
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('追加'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
