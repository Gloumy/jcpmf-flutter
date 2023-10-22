import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:jcpmf/models/card.dart';
import 'package:jcpmf/models/step.dart';
import 'package:jcpmf/services/local_notification_service.dart';
import 'package:vibration/vibration.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.card});

  final CardModel card;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late int _counter;
  late int _currentCountdown;
  late String _displayCountdown;
  int _currentStep = -1;

  @override
  void initState() {
    setState(() {
      _currentCountdown = widget.card.steps[0].getDurationInMs();
    });
    countdownDisplay();
    super.initState();
  }

  late Timer _countdown;

  void startCountdown() async {
    final int maxIndex = widget.card.steps.length - 1;
    for (int i = 0; i <= maxIndex; i++) {
      setState(() {
        _currentStep = i;
      });
      final notificationTitle =
          _currentStep == 0 ? "Première étape" : "Etape suivante";
      await LocalNotificationService().addNotification(notificationTitle,
          "${_currentStep + 1}. ${widget.card.steps[i].displayType()} ${widget.card.steps[i].duration}min");
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }
      final int duration = widget.card.steps[i].getDurationInMs();
      for (int j = duration; j >= 0; j -= 1000) {
        setState(() {
          _currentCountdown = j;
        });
        countdownDisplay();
        if (j <= 3000) {
          await FlutterBeep.beep();
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    await LocalNotificationService()
        .addNotification("Entraînement terminé", "Bravo !");
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
    setState(() {
      _currentStep = -1;
      _currentCountdown = widget.card.steps[0].getDurationInMs();
    });
    countdownDisplay();
  }

  void countdownDisplay() {
    final bool lessThanMinute = _currentCountdown <= 60000;
    final int minute = (_currentCountdown / 60000).floor();
    int seconds = lessThanMinute
        ? (_currentCountdown / 1000).floor()
        : (_currentCountdown % 60000) ~/ 1000;

    if (seconds == 60) {
      seconds = 0;
    }

    setState(() {
      _displayCountdown =
          "${minute.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    });
  }

  Color cardColor(StepModel step) {
    bool active = widget.card.steps.indexOf(step) == _currentStep;

    return active ? Colors.greenAccent : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("JCPMF"),
        centerTitle: true,
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
        children: [
          Text(_displayCountdown),
          for (StepModel step in widget.card.steps)
            Card(
              color: cardColor(step),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text(step.type), Text(step.duration.toString())],
              ),
            ),
          TextButton(onPressed: startCountdown, child: Text("Start")),
        ],
      )),
    );
  }
}
