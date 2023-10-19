import 'package:jcpmf/models/step.dart';

class CardModel {
  final int week;
  final int day;
  final List<Step> steps;

  CardModel(this.week, this.day, this.steps);

  CardModel.fromJson(Map<String, dynamic> json)
      : week = json["week"],
        day = json["day"],
        steps = List<Step>.from(json["steps"].map((x) => Step.fromJson(x)));
}
