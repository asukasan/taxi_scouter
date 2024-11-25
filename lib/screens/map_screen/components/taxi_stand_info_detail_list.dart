import 'package:flutter/material.dart';
import 'package:taxi_scouter/models/taxi_station_info.dart';

class TaxiInfoCard extends StatelessWidget {
  const TaxiInfoCard({
    super.key,
    required this.taxi_station_info,
  });

  final TaxiStandInfo taxi_station_info;

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = getTimeAgo(taxi_station_info.datetime);
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(formattedDateTime),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hail),
                  Text('客数: ${taxi_station_info.customers.toString()}'),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi),
                  Text('タクシー数: ${taxi_station_info.taxis.toString()}'),
                ]
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(taxi_station_info.add_user_name)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaxiInfoCardList extends StatelessWidget {
  const TaxiInfoCardList({
    super.key,
    required this.taxi_stand_info_list,
  });

  final List<TaxiStandInfo> taxi_stand_info_list;

  @override
  Widget build(BuildContext context) {
    if (taxi_stand_info_list.isEmpty) {
      // データがない場合の処理
      return Center(
        child: Text('データがありません'),
      );
    } else {
      // データがある場合の処理
      return ListView(
        children: [
          for (TaxiStandInfo taxiInfo in taxi_stand_info_list)
            TaxiInfoCard(taxi_station_info: taxiInfo),
        ],
      );
    }
  }
}
