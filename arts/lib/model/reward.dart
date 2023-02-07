class Reward {
  String? id;
  int? discountAmount;
  String? expiryDate;
  String? placeEvent;
  String? type;
  String? category;
  String? email;

  Reward(
      {
        this.id,
        this.discountAmount,
        this.expiryDate,
        this.placeEvent,
        this.type,
        this.category,
        this.email
      });

  Reward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    discountAmount = json['discount_amount'];
    expiryDate = json['expiry_date'];
    placeEvent = json['place_event'];
    type = json['type'];
    category = json['category'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['discount_amount'] = discountAmount;
    data['expiry_date'] = expiryDate;
    data['place_event'] = placeEvent;
    data['type'] = type;
    data['category'] = category;
    data['email'] = email;
    return data;
  }

  @override
  String toString() {
    return 'Reward {id: $id, discountAmount: $discountAmount, expiryDate: $expiryDate, placeEvent: $placeEvent, type: $type, category: $category, email: $email}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reward && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}