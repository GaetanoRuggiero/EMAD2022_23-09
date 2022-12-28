import './POI.dart';

class Itinerary {

  double? length;
  POI? startPoi;
  POI? poi_0;
  POI? poi_1;
  POI? poi_2;
  POI? endPoi;

  Itinerary({this.length, this.startPoi, this.poi_0, this.poi_1, this.poi_2, this.endPoi});

  Itinerary.fromJson(Map<String, dynamic> json) {
    length = json['length'] != null
        ? (json['length'] as double).toDouble() //doubt parse
        : null;
    startPoi = json['start_poi'] != null
        ? POI.fromJson(json['start_poi'])
        : null;
    poi_0 = json['poi_0'] != null
        ? POI.fromJson(json['poi_0'])
        : null;
    poi_1 = json['poi_1'] != null
        ? POI.fromJson(json['poi_1'])
        : null;
    poi_2 = json['poi_2'] != null
        ? POI.fromJson(json['poi_2'])
        : null;
    endPoi = json['end_poi'] != null
        ? POI.fromJson(json['end_poi'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (length != null) {
      data['length'] = double.parse(data['length'].toJson());
    }
    if (startPoi != null) {
      data['start_poi'] = startPoi!.toJson();
    }
    if (poi_0 != null) {
      data['poi_0'] = poi_0!.toJson();
    }
    if (poi_1 != null) {
      data['poi_1'] = poi_1!.toJson();
    }
    if (poi_2 != null) {
      data['poi_2'] = poi_2!.toJson();
    }
    if (endPoi != null) {
      data['end_poi'] = endPoi!.toJson();
    }
    return data;
  }

}

