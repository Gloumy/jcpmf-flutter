class Step {
  final String type;
  final int duration;

  Step(this.type, this.duration);

  Step.fromJson(Map<String, dynamic> json)
      : type = json["type"],
        duration = json["duration"];

  int getDurationInMs() {
    return duration * 60000;
  }
}
