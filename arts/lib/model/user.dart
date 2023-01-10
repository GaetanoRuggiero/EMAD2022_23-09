class User {
  String? name;
  String? surname;
  String? email;
  String? password;
  List<Visited>? visited;

  User({this.name, this.surname, this.email, this.password, this.visited});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    password = json['password'];
    if (json['visited'] != null) {
      visited = <Visited>[];
      json['visited'].forEach((v) {
        visited!.add(Visited.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['surname'] = surname;
    data['email'] = email;
    data['password'] = password;
    if (visited != null) {
      data['visited'] = visited!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'User{name: $name, surname: $surname, email: $email, visited: $visited}';
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
