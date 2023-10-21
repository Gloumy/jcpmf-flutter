import 'package:flutter/material.dart';
import 'package:jcpmf/models/card.dart';
import 'package:jcpmf/models/step.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.card});

  final CardModel card;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
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
          for (StepModel step in widget.card.steps)
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text(step.type), Text(step.duration.toString())],
              ),
            )
        ],
      )),
    );
  }
}
