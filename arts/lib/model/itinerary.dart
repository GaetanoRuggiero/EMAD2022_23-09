import './POI.dart';

class Itinerary {

  double? length;
  List<POI>? path;

  Itinerary({this.length, this.path});

  Itinerary.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    if (json['path'] != null) {
      path = <POI>[];
      json['path'].forEach((v) {
        path?.add(POI.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['length'] = length;
    data['path'] = path;
    return data;
  }

  @override
  String toString() {
    return 'Itinerary{length: $length, path: $path}';
  }
}