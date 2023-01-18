class Reward {
  int? discountAmount;
  String? expiryDate;
  String? placeEvent;
  String? poster;
  String? type;

  Reward(
      {this.discountAmount,
        this.expiryDate,
        this.placeEvent,
        this.poster,
        this.type,
      });

  Reward.fromJson(Map<String, dynamic> json) {
    discountAmount = json['discount_amount'];
    expiryDate = json['expiry_date'];
    placeEvent = json['place_event'];
    poster = json['poster'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount_amount'] = discountAmount;
    data['expiry_date'] = expiryDate;
    data['place_event'] = placeEvent;
    data['poster'] = poster;
    data['type'] = type;
    return data;
  }

  @override
  String toString() {
    return 'Reward{discountAmount: $discountAmount, expiryDate: $expiryDate, placeEvent: $placeEvent, poster: $poster, type: $type}';
  }
}