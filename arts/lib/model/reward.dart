class Reward {
  int? discountAmount;
  String? expiryDate;
  String? placeEvent;
  String? poster;
  String? type;
  String? category;

  Reward(
      {this.discountAmount,
        this.expiryDate,
        this.placeEvent,
        this.poster,
        this.type,
        this.category
      });

  Reward.fromJson(Map<String, dynamic> json) {
    discountAmount = json['discount_amount'];
    expiryDate = json['expiry_date'];
    placeEvent = json['place_event'];
    poster = json['poster'];
    type = json['type'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount_amount'] = discountAmount;
    data['expiry_date'] = expiryDate;
    data['place_event'] = placeEvent;
    data['poster'] = poster;
    data['type'] = type;
    data['category'] = category;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reward &&
          runtimeType == other.runtimeType &&
          discountAmount == other.discountAmount &&
          expiryDate == other.expiryDate &&
          placeEvent == other.placeEvent &&
          poster == other.poster &&
          type == other.type &&
          category == other.category;

  @override
  int get hashCode =>
      discountAmount.hashCode ^
      expiryDate.hashCode ^
      placeEvent.hashCode ^
      poster.hashCode ^
      type.hashCode ^
      category.hashCode;

  @override
  String toString() {
    return 'Reward{discountAmount: $discountAmount, expiryDate: $expiryDate, placeEvent: $placeEvent, poster: $poster, type: $type, category: $category}';
  }
}