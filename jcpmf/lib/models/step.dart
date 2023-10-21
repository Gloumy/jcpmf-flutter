class StepModel {
  final String type;
  final int duration;

  StepModel(this.type, this.duration);

  StepModel.fromJson(Map<String, dynamic> json)
      : type = json["type"],
        duration = json["duration"];

  int getDurationInMs() {
    return duration * 60000;
  }
}
