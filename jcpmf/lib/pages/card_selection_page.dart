import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jcpmf/models/card.dart';
import 'package:jcpmf/pages/card_page.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_beep/flutter_beep.dart';

class CardSelectionPage extends StatefulWidget {
  const CardSelectionPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<CardSelectionPage> createState() => _CardSelectionPageState();
}

class _CardSelectionPageState extends State<CardSelectionPage> {
  int _counter = 10;
  late Timer _countdown;

  List<CardModel> _cards = [];

// Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final Map<String, dynamic> data = await json.decode(response);
    setState(() {
      _cards =
          List<CardModel>.from(data["cards"].map((x) => CardModel.fromJson(x)));
    });
  }

  void _decrementCounter() {
    _countdown = Timer.periodic(
        Duration(seconds: 1),
        (_) => {
              setState(() {
                // This call to setState tells the Flutter framework that something has
                // changed in this State, which causes it to rerun the build method below
                // so that the display can reflect the updated values. If we changed
                // _counter without calling setState(), then the build method would not be
                // called again, and so nothing would appear to happen.
                _counter--;
                if (_counter <= 3) {
                  Vibration.vibrate();
                  FlutterBeep.beep();
                  if (_counter <= 0) _countdown.cancel();
                }
              })
            });
  }

  @override
  void initState() {
    readJson();
    super.initState();
  }

  // void initData() async {
  //   await readJson();
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            for (int week in _cards.map((e) => e.week).toSet().toList())
              Card(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Semaine $week"),
                  for (CardModel card
                      in _cards.where((element) => element.week == week))
                    TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CardPage(card: card))),
                        child: Text(card.day.toString())),
                ],
              )),
          ],
        ),
      ),
    );
  }
}
