class Reward {
  int? discountAmount;
  ExpiryDate? expiryDate;
  String? placeEvent;
  String? poster;
  String? type;

  Reward(
      {this.discountAmount,
        this.expiryDate,
        this.placeEvent,
        this.poster,
        this.type});

  Reward.fromJson(Map<String, dynamic> json) {
    discountAmount = json['discount_amount'];
    expiryDate = json['expiry_date'] != null
        ? ExpiryDate.fromJson(json['expiry_date'])
        : null;
    placeEvent = json['place_event'];
    poster = json['poster'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount_amount'] = discountAmount;
    if (expiryDate != null) {
      data['expiry_date'] = expiryDate!.toJson();
    }
    data['place_event'] = placeEvent;
    data['poster'] = poster;
    data['type'] = type;
    return data;
  }
}

class ExpiryDate {
  int? seconds;
  int? nanos;

  ExpiryDate({this.seconds, this.nanos});

  ExpiryDate.fromJson(Map<String, dynamic> json) {
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