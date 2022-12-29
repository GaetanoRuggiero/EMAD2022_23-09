class POI {
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

  POI({
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
    this.modelName
  });

  POI.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }

  @override
  String toString() {
    return 'POI{city: $city, cityKeywords: $cityKeywords, country: $country, imageURL: $imageURL, latitude: $latitude, longitude: $longitude, name: $name, nameEn: $nameEn, nameKeywords: $nameKeywords, province: $province, region: $region, modelName: $modelName}';
  }
}