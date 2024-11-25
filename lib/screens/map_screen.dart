import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taxi_scouter/screens/secret.dart';
import 'package:taxi_scouter/models/taxi_station.dart';
import 'package:taxi_scouter/models/taxi_station_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_scouter/screens/taxi_stand_detail.dart';
import 'package:taxi_scouter/components/auth_modal/auth_modal.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taxi_scouter/screens/profile_screen/profile_screen.dart';
import 'package:taxi_scouter/screens/tutorial/tutorial.dart';
import 'package:taxi_scouter/components/app_loading.dart';
import 'package:taxi_scouter/screens/inquiry/inquiry.dart';
import 'package:taxi_scouter/screens/marker_color_explanation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
  });
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 初期位置
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(35.681236, 139.767125), // 東京駅
    zoom: 14.0,
  );

  // マップコントローラー
  late GoogleMapController mapController;
  // マーカー
  List<Marker> markers = [];
  // 画面の中心の位置情報
  LatLng? currentCenter;

  // サインインしているかどうか
  bool isSignedIn = false;

  //認証状態を監視
  late StreamSubscription<User?> authUserStream;

 // ローディング状態を定義
  bool isLoading = false;

  @override
  void initState() {
    // ログイン状態の変化を監視
    _watchSignInState();
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    // ログイン状態の監視を解放
    authUserStream.cancel();
    super.dispose();
  }

  // 現在地へ移動
  Future<void> _moveToCurrentLocation() async {
    // 現在地取得の許可を確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        LatLng center = LatLng(currentLocation.latitude, currentLocation.longitude);
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: center, zoom: 14.0),
          ),
        );
      });
    }
  }

  // 画面の中心を更新する
  void _onCameraMove(CameraPosition position) {
      currentCenter = position.target;
    }


  // 画面内のタクシー乗り場にピンを刺す
  Future<void> _addPin() async {
    if (currentCenter == null){
      LatLng currentCenter = await mapController.getVisibleRegion().then(
        (bounds) => LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        ),
      );
    }
    // タクシー乗り場の検索とマーカーの追加
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json' +
        '?location=${currentCenter!.latitude},${currentCenter!.longitude}&radius=${4000}&type=taxi_stand&language=ja&key=${googleApiKey}';
    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    markers.clear();
    for (var place in json['results']) {
      // もしデータベースにそのタクシー乗り場がない場合は追加する。
      List<TaxiStand> taxiStands = await getTaxiStandsByName(place['name']);
      if (taxiStands.isEmpty) {
        TaxiStand newTaxiStand = TaxiStand(
          name: place['name'],
          address: place['vicinity']
        );
        await addTaxiStand(newTaxiStand);
      }
      // 最新のタクシー情報の取得
      String? taxiStandId = await TaxiStand.getDocumentIdByNameAndAddress(place['name'], place['vicinity']);
      String finaltaxiStandId = taxiStandId == null ? '' : taxiStandId.toString();
      List<TaxiStandInfo> latest_taxi_stand_info = await TaxiStandInfo.getLatestTaxiStands(finaltaxiStandId, limitCount: 1);
      // 最新のタクシー情報を使用してそのスコアを求め、マーカーの色を変更する
      bool isTaxiStandInfoAvailableWithinTwoHours = false;
      if (latest_taxi_stand_info.isNotEmpty) {
        isTaxiStandInfoAvailableWithinTwoHours = getTaxiStandInfoAvailableWithinTwoHours(latest_taxi_stand_info[0].datetime);
      }
      int taxiStandScore = 0;
      double markerColor = BitmapDescriptor.hueGreen;
      if (latest_taxi_stand_info.isNotEmpty & isTaxiStandInfoAvailableWithinTwoHours) {
        taxiStandScore = getTaxiStandScore(latest_taxi_stand_info[0].customers,latest_taxi_stand_info[0].taxis, latest_taxi_stand_info[0].datetime);
        if (taxiStandScore > 5) {
          markerColor = BitmapDescriptor.hueRed;
        }
        else if (taxiStandScore > 2) {
          markerColor = BitmapDescriptor.hueYellow;
        }
        else {
          markerColor = BitmapDescriptor.hueBlue;
        }
      }
      LatLng markerLocation = LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']);
      markers.add(
        Marker(
          markerId: MarkerId(place['name']),
          position: markerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          infoWindow: InfoWindow(
            title: place['name'], 
            snippet: place['vicinity'],
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TaxiStandDetail(
                      name: place['name'],
                      address : place['vicinity']
                    ),
                  );
                },
              );
            }
          ),
        ),
      );
    }
    setState(() {});
  }

  // 位置情報の許可を求める
  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    else {
      _getUserLocation();
    }
  }

  // 初期位置に現在地を代入する
  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      );
    });
  }

  Future<void> addTaxiStand(TaxiStand taxiStand) async {
    // Firestoreのインスタンスを取得
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 'taxi_stands'コレクションにドキュメントを追加
    await firestore.collection('taxi_stands').add(taxiStand.toMap());
  }

  Future<List<TaxiStand>> getTaxiStandsByName(String name) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('taxi_stands')
        .where('name', isEqualTo: name)
        .get();

    return querySnapshot.docs
        .map((doc) => TaxiStand.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  void _showSignUpModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      builder: (BuildContext context) {
        return const AuthModal();
      }
    );
  }

  // ログアウト確認ダイアログを表示する関数
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('はい'),
              onPressed: () {
                _signOut();
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // Drawerを閉じる
              },
            ),
            TextButton(
              child: const Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  void setIsSignedIn(bool value) {
    setState(() {
      isSignedIn = value;
    });
  }

  void _watchSignInState() {
    authUserStream =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
        setIsSignedIn(false);
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSignUpModalBottomSheet(context));
        } else {
        setIsSignedIn(true);
        }
    });
  }

  Future<void> _signOut() async {
    await Future.delayed(const Duration(seconds: 1), () {});
    await FirebaseAuth.instance.signOut();
  }

  void showSignInAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('サインインが必要です'),
          content: const Text('この検索機能を使用するにはサインインをしてください。'),
          actions: <Widget>[
            TextButton(
              child: const Text('戻る'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: const Text('サインイン'),
              onPressed: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) => _showSignUpModalBottomSheet(context));
              }, // サインイン処理を実行
            ),
          ],
        );
      },
    );
  }

  // タクシー乗り場の現在の期待値を算出する。
  int getTaxiStandScore(int customerCount, int taxiCount, DateTime postedTime) {
    // post_timeをDateTimeオブジェクトに変換
    DateTime currentTime = DateTime.now();

    // post_timeと現在時刻の差を求める
    Duration difference = currentTime.difference(postedTime);

    double timeScore = 1 - (difference.inMinutes * (5 / 6) * 0.01);
    double basicScore = (customerCount * (1/1.2)) - taxiCount.toDouble();
    if (basicScore < 0) {
      return 0;
    }
    int totalScore = (basicScore * timeScore).toInt();

    return totalScore;
  }

  bool getTaxiStandInfoAvailableWithinTwoHours(DateTime postedTime) {
    // post_timeをDateTimeオブジェクトに変換
    DateTime currentTime = DateTime.now();

    // post_timeと現在時刻の差を求める
    Duration difference = currentTime.difference(postedTime);

    // 差が2時間以上の場合
    if (difference.inHours >= 2) {
      return false;
    }
    return true;
  }

  setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('タクシースカウター'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'タクシースカウター',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.message),
              title: const Text('こんな機能が欲しい！'),
              onTap: () {
                Navigator.of(context).pop(); // Drawerを閉じる
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FeedbackScreen(), // ProfileScreenに遷移
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('プロフィール'),
              onTap: () {
                if (isSignedIn) {
                  Navigator.of(context).pop(); // Drawerを閉じる
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(), // ProfileScreenに遷移
                  ));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('マーカーの色の説明'),
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.5), // 背景の透明度を調整
                  builder: (BuildContext context) {
                    return MarkerColorExplanationDialog();
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('使い方'),
              onTap: () {
                Navigator.of(context).pop(); // Drawerを閉じる
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TutorialPage(), 
                ));
              },
            ),
            ListTile(
              leading: isSignedIn ?  Icon(Icons.logout) : Icon(Icons.login),
              title: isSignedIn ? const Text('サインアウト') : const Text('サインイン'),
              onTap: () {
                if (isSignedIn) {
                  _showLogoutConfirmation(context); 
                }
                else {
                  _showSignUpModalBottomSheet(context);
                }
              },
            ),
          ],
        ),
      ),
      body : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) async {
                  mapController = controller;
                  await _requestPermission();
                  await _moveToCurrentLocation();
                },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Set.from(markers),
            onCameraMove: _onCameraMove,
            zoomControlsEnabled: false
          ),
          if (isLoading) 
            const Center(child: AppLoading(color: Colors.blue, dimension: 50,))
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              // ピンを追加
              if (isSignedIn) {
                setState(() {
                  isLoading = true;
                });
                await _addPin();
                setState(() {
                  isLoading = false;
                });
              }
              else {
               showSignInAlert(context); 
              }
            },
            tooltip: 'タクシー乗り場を検索',
          child: const Icon(Icons.search),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: () async {
              // 現在地を中心にカメラを移動
              await _moveToCurrentLocation();
            },
            tooltip: '現在地',
          child: const Icon(Icons.my_location),
          ),
        ],
      )
    );
  }
}