import 'package:arts/model/sidequest.dart';

class SidequestDatabase {
  StartDate? startDate;
  StartDate? endDate;
  String? poi;
  String? reward;

  SidequestDatabase({this.startDate, this.endDate, this.poi, this.reward});

  SidequestDatabase.fromJson(Map<String, dynamic> json) {
    startDate = json['start_date'] != null
        ? StartDate.fromJson(json['start_date'])
        : null;
    endDate = json['end_date'] != null
        ? StartDate.fromJson(json['end_date'])
        : null;
    poi = json['poi'];
    reward = json['reward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (startDate != null) {
      data['start_date'] = startDate!.toJson();
    }
    if (endDate != null) {
      data['end_date'] = endDate!.toJson();
    }
    data['poi'] = poi;
    data['reward'] = reward;

    return data;
  }

  @override
  String toString() {
    return 'SidequestDatabase {startDate: $startDate, endDate: $endDate, poi: $poi, reward: $reward}';
  }
}