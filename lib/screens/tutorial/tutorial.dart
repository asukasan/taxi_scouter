import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:taxi_scouter/screens/marker_color_explanation.dart';

class TutorialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使い方'),
        backgroundColor: Colors.blue,
      ),
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () {
          // when user select SKIP
          Navigator.pop(context);
        },
        finishCallback: () {
          // when user select NEXT
          Navigator.pop(context);
        },
      ),
    );
  }

  final pages = [
    PageModel(
        color: const Color(0xFF95cedd),
        imageAssetPath: 'assets/images/home.png',
        title: 'ホーム画面',
        body: 'このアプリではタクシー乗り場の情報を追加、閲覧することができます',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF9B90BC),
        imageAssetPath: 'assets/images/search1.png',
        title: '検索機能1',
        body: '検索ボタンを押すことで画面内のタクシー乗り場一覧を表示できます。',
        doAnimateImage: true),
    PageModel.withChild(
      child: SingleChildScrollView(
        child: Builder(
          builder: (BuildContext innerContext) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 42.0),
                child: Image.asset('assets/images/search2.png'),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  '検索機能2',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ピンの色によってタクシー乗り場の\nおすすめ度がわかります。',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('ピンの色について'),
                onPressed: () {
                  showDialog(
                    context: innerContext,
                    builder: (BuildContext context) {
                      return MarkerColorExplanationDialog();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      color: const Color(0xFF00BCD4),
      doAnimateChild: true
    ),
    PageModel.withChild(
      child: SingleChildScrollView(
        child: Builder(
          builder: (BuildContext innerContext) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 42.0),
                child: Image.asset('assets/images/info_window.png'),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'ピンの情報',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ピンを押すことでタクシー乗り場の詳細ウィンドウが表示されます',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      color: const Color(0xFF4CAF50),
      doAnimateChild: true
    ),
    PageModel.withChild(
      child: SingleChildScrollView(
        child: Builder(
          builder: (BuildContext innerContext) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 42.0),
                child: Image.asset('assets/images/taxi_stand_info_detail.png'),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'タクシー乗り場の情報',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '詳細ウィンドウを押すと、そのタクシー乗り場の詳細情報が見れます',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      color: const Color(0xFFFFC107),
      doAnimateChild: true
    ),
    PageModel.withChild(
      child: SingleChildScrollView(
        child: Builder(
          builder: (BuildContext innerContext) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 42.0),
                child: Image.asset('assets/images/info_window.png'),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'ピンの情報',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ピンを押すことでタクシー乗り場の詳細ウィンドウが表示されます',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      color: const Color(0xFF4CAF50),
      doAnimateChild: true
    ),
    PageModel.withChild(
      child: SingleChildScrollView(
        child: Builder(
          builder: (BuildContext innerContext) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 42.0),
                child: Image.asset('assets/images/taxi_stand_info_add.png'),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'タクシー乗り場の情報の追加',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '追加ボタンを押すと、タクシー乗り場の情報を追加できます',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      color: const Color(0xFFFF5722),
      doAnimateChild: true
    ),
    PageModel.withChild(
        child: Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Text(
              "さあ、始めましょう",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
              ),
            )),
        color: const Color(0xFF5886d6),
        doAnimateChild: true)
  ];
}
