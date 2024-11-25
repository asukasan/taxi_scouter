import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiStandInfo {
  final String id;
  final int customers;
  final int taxis;
  final DateTime datetime;
  final String add_user_id;
  String add_user_name;

  TaxiStandInfo({
    required this.id,
    required this.customers,
    required this.taxis,
    required this.datetime,
    required this.add_user_id,
    this.add_user_name = '',
  });

  static Future<List<TaxiStandInfo>> getLatestTaxiStands(String taxiStandId, {int limitCount = 5}) async {
    var collection = FirebaseFirestore.instance.collection('taxi_stand_info');
    var querySnapshot = await collection
        .where('taxi_stand_id', isEqualTo: taxiStandId)
        .orderBy('datetime', descending: true)
        .limit(limitCount)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return []; 
    }

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return TaxiStandInfo(
        id: data['taxi_stand_id'],
        customers: data['customers'],
        taxis: data['taxis'],
        datetime: data['datetime'].toDate(), // FirebaseのTimestampをDateTimeに変換
        add_user_id: data['add_user_id'],
      );
    }).toList();
  }
}
