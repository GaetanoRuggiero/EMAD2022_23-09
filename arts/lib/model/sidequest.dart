import './reward.dart';
import './POI.dart';

class Sidequest {
  StartDate? startDate;
  StartDate? endDate;
  POI? poi;
  Reward? reward;

  Sidequest({this.startDate, this.endDate, this.poi, this.reward});

  Sidequest.fromJson(Map<String, dynamic> json) {
    startDate = json['start_date'] != null
        ? StartDate.fromJson(json['start_date'])
        : null;
    endDate = json['end_date'] != null
        ? StartDate.fromJson(json['end_date'])
        : null;
    poi = json['poi'] != null
        ? POI.fromJson(json['poi'])
        : null;
    reward = json['reward'] != null
        ? Reward.fromJson(json['reward'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (startDate != null) {
      data['start_date'] = startDate!.toJson();
    }
    if (endDate != null) {
      data['end_date'] = endDate!.toJson();
    }
    if (poi != null) {
      data['poi'] = poi!.toJson();
    }
    if (reward != null) {
      data['reward'] = reward!.toJson();
    }
    return data;
  }
}

class StartDate {
  int? seconds;
  int? nanos;

  StartDate({this.seconds, this.nanos});

  StartDate.fromJson(Map<String, dynamic> json) {
    seconds = json['seconds'];
    nanos = json['nanos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seconds'] = seconds;
    data['nanos'] = nanos;
    return data;
  }
}