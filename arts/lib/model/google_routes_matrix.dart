class GoogleRoutesMatrix {
  int? originIndex;
  int? destinationIndex;
  int? distanceMeters;
  String? duration;
  String? condition;

  GoogleRoutesMatrix(
      {this.originIndex,
        this.destinationIndex,
        this.distanceMeters,
        this.duration,
        this.condition});

  GoogleRoutesMatrix.fromJson(Map<String, dynamic> json) {
    originIndex = json['originIndex'];
    destinationIndex = json['destinationIndex'];
    distanceMeters = json['distanceMeters'];
    duration = json['duration'];
    condition = json['condition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['originIndex'] = originIndex;
    data['destinationIndex'] = destinationIndex;
    data['distanceMeters'] = distanceMeters;
    data['duration'] = duration;
    data['condition'] = condition;
    return data;
  }
}