import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiStand {
  String name;
  String address;

  TaxiStand({required this.name, required this.address});

  // Firebaseのデータからオブジェクトを生成するためのファクトリメソッド
  factory TaxiStand.fromMap(Map<String, dynamic> data) {
    return TaxiStand(
      name: data['name'],
      address: data['address'],
    );
  }

  // オブジェクトからFirebaseのデータ形式に変換するためのメソッド
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }
  // nameとaddressに基づいてドキュメントIDを取得する関数
  static Future<String?> getDocumentIdByNameAndAddress(String name, String address) async {
    var collection = FirebaseFirestore.instance.collection('taxi_stands');
    var querySnapshot = await collection
        .where('name', isEqualTo: name)
        .where('address', isEqualTo: address)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // ドキュメントのIDを返却
    } else {
      return null; // 見つからなかった場合はnullを返却
    }
  }
}
