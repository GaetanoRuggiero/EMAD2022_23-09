class POI {
  String? city;
  List<String>? cityKeywords;
  String? country;
  String? imageURL;
  double? latitude;
  double? longitude;
  String? name;
  List<String>? nameKeywords;
  String? province;
  String? region;
  String? trivia;
  String? history;

  POI(
      {this.city,
        this.cityKeywords,
        this.country,
        this.imageURL,
        this.latitude,
        this.longitude,
        this.name,
        this.nameKeywords,
        this.province,
        this.region,
        this.trivia,
        this.history});

  POI.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    cityKeywords = json['city_keywords'].cast<String>();
    country = json['country'];
    imageURL = json['imageURL'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    nameKeywords = json['name_keywords'].cast<String>();
    province = json['province'];
    region = json['region'];
    trivia = json['trivia'];
    history = json['history'];
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
    data['name_keywords'] = nameKeywords;
    data['province'] = province;
    data['region'] = region;
    data['trivia'] = trivia;
    data['history'] = history;
    return data;
  }

  @override
  String toString() {
    return 'POI{city: $city, cityKeywords: $cityKeywords, country: $country, imageURL: $imageURL, latitude: $latitude, longitude: $longitude, name: $name, nameKeywords: $nameKeywords, province: $province, region: $region}';
  }
}