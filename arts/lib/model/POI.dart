class POI {
  String? city;
  String? cityLower;
  String? country;
  String? countryLower;
  String? imageURL;
  double? latitude;
  double? longitude;
  String? name;
  String? nameLower;
  String? province;
  String? provinceLower;
  String? region;
  String? regionLower;
  String? history;
  String? trivia;

  POI(
      {this.city,
        this.cityLower,
        this.country,
        this.countryLower,
        this.imageURL,
        this.latitude,
        this.longitude,
        this.name,
        this.nameLower,
        this.province,
        this.provinceLower,
        this.region,
        this.regionLower,
        this.history,
        this.trivia});

  POI.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    cityLower = json['city_lower'];
    country = json['country'];
    countryLower = json['country_lower'];
    imageURL = json['imageURL'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    nameLower = json['name_lower'];
    province = json['province'];
    provinceLower = json['province_lower'];
    region = json['region'];
    regionLower = json['region_lower'];
    history = json['history'];
    trivia = json['trivia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['city_lower'] = cityLower;
    data['country'] = country;
    data['country_lower'] = countryLower;
    data['imageURL'] = imageURL;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    data['name_lower'] = nameLower;
    data['province'] = province;
    data['province_lower'] = provinceLower;
    data['region'] = region;
    data['region_lower'] = regionLower;
    data['history'] = history;
    data['trivia'] = trivia;
    return data;
  }

  @override
  String toString() {
    return 'POI{city: $city, cityLower: $cityLower, country: $country, countryLower: $countryLower, imageURL: $imageURL, latitude: $latitude, longitude: $longitude, name: $name, nameLower: $nameLower, province: $province, provinceLower: $provinceLower, region: $region, regionLower: $regionLower, history: $history, trivia: $trivia}';
  }
}
