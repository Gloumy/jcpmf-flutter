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

  String displayType() {
    switch (type) {
      case "E/S":
        return "Echauffement";
      case "C":
        return "Course";
      case "M":
        return "Marche";
      case "RC":
        return "Récupération";
      case "M/T":
        return "Trottiner";
      default:
        return type;
    }
  }
}
