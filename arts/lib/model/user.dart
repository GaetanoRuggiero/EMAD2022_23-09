class User {
  String? name;
  String? surname;
  String? email;
  String? password;
  bool? partner;
  int? rewardsAdded;
  String? category;
  double? latitude;
  double? longitude;
  String? registrationDate;
  List<Visited>? visited;
  List<Coupon>? couponList;

  User({this.name, this.surname, this.email, this.password, this.partner,
    this.rewardsAdded, this.category,  this.latitude, this.longitude, this.registrationDate,
    this.visited, this.couponList
  });

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    password = json['password'];
    partner = json['partner'];
    rewardsAdded = json['rewards_added'];
    category = json['category'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    registrationDate = json['registration_date'];
    if (json['visited'] != null) {
      visited = <Visited>[];
      json['visited'].forEach((v) {
        visited!.add(Visited.fromJson(v));
      });
    }
    if (json['coupons'] != null) {
      couponList = <Coupon>[];
      json['coupons'].forEach((c) {
        couponList!.add(Coupon.fromJson(c));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['surname'] = surname;
    data['email'] = email;
    data['password'] = password;
    data['partner'] = partner;
    data['rewards_added'] = rewardsAdded;
    data['category'] = category;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['registration_date'] = registrationDate;
    if (visited != null) {
      data['visited'] = visited!.map((v) => v.toJson()).toList();
    }
    if (couponList != null) {
      data['coupons'] = couponList!.map((c) => c.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'User{name: $name, surname: $surname, email: $email, partner: $partner, rewardsAdded: $rewardsAdded, category: $category, visited: $visited, coupons: $couponList}';
  }
}

class Coupon {
  String? rewardId;
  late bool used;
  String? qrUrl;

  Coupon(this.rewardId, this.used);

  Coupon.fromJson(Map<String, dynamic> json) {
    rewardId = json['reward_id'];
    used = json['used'];
    qrUrl = json['qr_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reward_id'] = rewardId;
    data['used'] = used;
    data['qr_url'] = qrUrl;
    return data;
  }

  @override
  String toString() {
    return 'Coupon{reward_id: $rewardId, used: $used}';
  }
}

class Visited {
  String? poiId;
  String? lastVisited;

  Visited({this.poiId, this.lastVisited});

  Visited.fromJson(Map<String, dynamic> json) {
    poiId = json['poi_id'];
    lastVisited = json['last_visited'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['poi_id'] = poiId;
    data['last_visited'] = lastVisited;
    return data;
  }

  @override
  String toString() {
    return 'Visited{poiId: $poiId, lastVisited: $lastVisited}';
  }
}
