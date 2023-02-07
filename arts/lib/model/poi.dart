class POI {
  String? id;
  String? city;
  List<String>? cityKeywords;
  String? country;
  String? imageURL;
  double? latitude;
  double? longitude;
  String? name;
  String? nameEn;
  List<String>? nameKeywords;
  String? province;
  String? region;
  String? trivia;
  String? triviaEn;
  String? history;
  String? historyEn;
  String? modelName;
  String? size;
  bool? ongoingMission;

  POI({
    this.id,
    this.city,
    this.cityKeywords,
    this.country,
    this.imageURL,
    this.latitude,
    this.longitude,
    this.name,
    this.nameEn,
    this.nameKeywords,
    this.province,
    this.region,
    this.trivia,
    this.triviaEn,
    this.history,
    this.historyEn,
    this.modelName,
    this.size,
    this.ongoingMission
  });

  POI.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    city = json['city'];
    cityKeywords = json['city_keywords'].cast<String>();
    country = json['country'];
    imageURL = json['imageURL'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    nameEn = json['name_en'];
    nameKeywords = json['name_keywords'].cast<String>();
    province = json['province'];
    region = json['region'];
    trivia = json['trivia'];
    triviaEn = json['trivia_en'];
    history = json['history'];
    historyEn = json['history_en'];
    modelName = json['model_name'];
    size = json['size'];
    ongoingMission = json['ongoing_mission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['city'] = city;
    data['city_keywords'] = cityKeywords;
    data['country'] = country;
    data['imageURL'] = imageURL;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    data['name_en'] = nameEn;
    data['name_keywords'] = nameKeywords;
    data['province'] = province;
    data['region'] = region;
    data['trivia'] = trivia;
    data['trivia_en'] = triviaEn;
    data['history'] = history;
    data['history_en'] = historyEn;
    data['model_name'] = modelName;
    data['size'] = size;
    data['ongoing_mission'] = ongoingMission;
    return data;
  }

  @override
  String toString() {
    return 'POI{id: $id, city: $city, cityKeywords: $cityKeywords, country: $country, imageURL: $imageURL, latitude: $latitude, longitude: $longitude, name: $name, nameEn: $nameEn, nameKeywords: $nameKeywords, province: $province, region: $region, modelName: $modelName, size: $size, ongoingMission: $ongoingMission}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POI && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static double getSize(String size) {
    if (size == "S") {
      return 15.0;
    } else if (size == "M") {
      return 30.0;
    } else if (size == "L") {
      return 50.0;
    } else if (size == "XL") {
      return 100.0;
    } else if (size == "XXL") {
      return 200.0;
    } else {
      return 15.0; // Default value
    }
  }

  static double getMaxPhotoThreshold(String size) {
    if (size == "S") {
      return 20.0;
    } else if (size == "M") {
      return 40.0;
    } else if (size == "L") {
      return 80.0;
    } else if (size == "XL") {
      return 150.0;
    } else if (size == "XXL") {
      return 400.0;
    } else {
      return 20.0; // Default value
    }
  }
}