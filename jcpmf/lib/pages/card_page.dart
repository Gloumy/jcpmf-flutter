import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:jcpmf/models/card.dart';
import 'package:jcpmf/models/countdown_state.dart';
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
  late CardModel card = widget.card;

  late int _counter;
  late int _currentCountdown;
  late String _displayCountdown;
  int _currentStep = -1;
  CountdownState countdownState = CountdownState.stopped;

  @override
  void initState() {
    setState(() {
      _currentCountdown = card.steps[0].getDurationInMs();
    });
    countdownDisplay();
    super.initState();
  }

  late Timer _countdown;

  void startCountdown({bool resume = false}) async {
    final int maxIndex = card.steps.length - 1;
    countdownState = CountdownState.ongoing;

    for (int i = resume ? _currentStep : 0; i <= maxIndex; i++) {
      if (countdownState != CountdownState.ongoing) {
        if (countdownState == CountdownState.skipped) {
          setCountdownState(CountdownState.ongoing);
        } else {
          // Paused or stopped
          break;
        }
      }
      setState(() {
        _currentStep = i;
      });
      final notificationTitle =
          _currentStep == 0 ? "Première étape" : "Etape suivante";
      await LocalNotificationService().addNotification(notificationTitle,
          "${_currentStep + 1}. ${card.steps[i].displayType()} ${card.steps[i].duration}min");
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }
      final int duration =
          resume ? _currentCountdown : card.steps[i].getDurationInMs();
      for (int j = duration; j >= 0; j -= 1000) {
        if (countdownState == CountdownState.ongoing) {
          setState(() {
            _currentCountdown = j;
          });
          countdownDisplay();
          if (j <= 3000) {
            await FlutterBeep.beep();
          }
          await Future.delayed(const Duration(seconds: 1));
        } else {
          if (countdownState != CountdownState.ongoing) {
            // Stopped, skipped or paused
            break;
          }
        }
      }
    }
    if (countdownState == CountdownState.ongoing) {
      await LocalNotificationService()
          .addNotification("Entraînement terminé", "Bravo !");
    }
  }

  Future<void> reset() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
    setState(() {
      _currentStep = -1;
      _currentCountdown = card.steps[0].getDurationInMs();
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
    bool active = card.steps.indexOf(step) == _currentStep;

    return active ? Colors.greenAccent : Colors.grey;
  }

  void setCountdownState(CountdownState state) {
    if (state == CountdownState.stopped) {
      reset();
    }
    setState(() {
      countdownState = state;
    });
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
          for (StepModel step in card.steps)
            Card(
              color: cardColor(step),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text(step.type), Text(step.duration.toString())],
              ),
            ),
          TextButton(onPressed: startCountdown, child: Text("Start")),
          TextButton(
              onPressed: () => setCountdownState(CountdownState.paused),
              child: Text("Pause")),
          TextButton(
              onPressed: () => setCountdownState(CountdownState.stopped),
              child: Text("Stop")),
          TextButton(
              onPressed: () => setCountdownState(CountdownState.skipped),
              child: Text("Skip")),
          TextButton(
              onPressed: () => startCountdown(resume: true),
              child: Text("Resume")),
        ],
      )),
    );
  }
}
