class GoogleRoutesResponse {
  List<Routes>? routes;

  GoogleRoutesResponse({this.routes});

  GoogleRoutesResponse.fromJson(Map<String, dynamic> json) {
    if (json['routes'] != null) {
      routes = <Routes>[];
      json['routes'].forEach((v) {
        routes!.add(Routes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (routes != null) {
      data['routes'] = routes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Routes {
  List<Legs>? legs;
  int? distanceMeters;
  String? duration;

  Routes({this.legs, this.distanceMeters, this.duration});

  Routes.fromJson(Map<String, dynamic> json) {
    if (json['legs'] != null) {
      legs = <Legs>[];
      json['legs'].forEach((v) {
        legs!.add(Legs.fromJson(v));
      });
    }
    distanceMeters = json['distanceMeters'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (legs != null) {
      data['legs'] = legs!.map((v) => v.toJson()).toList();
    }
    data['distanceMeters'] = distanceMeters;
    data['duration'] = duration;
    return data;
  }
}

class Legs {
  int? distanceMeters;
  String? duration;
  String? staticDuration;
  EncodedPolyline? polyline;
  StartLocation? startLocation;
  StartLocation? endLocation;
  List<Steps>? steps;

  Legs(
      {this.distanceMeters,
        this.duration,
        this.staticDuration,
        this.polyline,
        this.startLocation,
        this.endLocation,
        this.steps});

  Legs.fromJson(Map<String, dynamic> json) {
    distanceMeters = json['distanceMeters'];
    duration = json['duration'];
    staticDuration = json['staticDuration'];
    polyline = json['polyline'] != null
        ? EncodedPolyline.fromJson(json['polyline'])
        : null;
    startLocation = json['startLocation'] != null
        ? StartLocation.fromJson(json['startLocation'])
        : null;
    endLocation = json['endLocation'] != null
        ? StartLocation.fromJson(json['endLocation'])
        : null;
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distanceMeters'] = distanceMeters;
    data['duration'] = duration;
    data['staticDuration'] = staticDuration;
    if (polyline != null) {
      data['polyline'] = polyline!.toJson();
    }
    if (startLocation != null) {
      data['startLocation'] = startLocation!.toJson();
    }
    if (endLocation != null) {
      data['endLocation'] = endLocation!.toJson();
    }
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EncodedPolyline {
  String? encodedPolyline;

  EncodedPolyline({this.encodedPolyline});

  EncodedPolyline.fromJson(Map<String, dynamic> json) {
    encodedPolyline = json['encodedPolyline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['encodedPolyline'] = encodedPolyline;
    return data;
  }
}

class StartLocation {
  RoutesLatLng? latLng;

  StartLocation({this.latLng});

  StartLocation.fromJson(Map<String, dynamic> json) {
    latLng =
    json['latLng'] != null ? RoutesLatLng.fromJson(json['latLng']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (latLng != null) {
      data['latLng'] = latLng!.toJson();
    }
    return data;
  }
}

class RoutesLatLng {
  double? latitude;
  double? longitude;

  RoutesLatLng({this.latitude, this.longitude});

  RoutesLatLng.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class Steps {
  int? distanceMeters;
  String? staticDuration;
  EncodedPolyline? polyline;
  StartLocation? startLocation;
  StartLocation? endLocation;
  NavigationInstruction? navigationInstruction;

  Steps(
      {this.distanceMeters,
        this.staticDuration,
        this.polyline,
        this.startLocation,
        this.endLocation,
        this.navigationInstruction});

  Steps.fromJson(Map<String, dynamic> json) {
    distanceMeters = json['distanceMeters'];
    staticDuration = json['staticDuration'];
    polyline = json['polyline'] != null
        ? EncodedPolyline.fromJson(json['polyline'])
        : null;
    startLocation = json['startLocation'] != null
        ? StartLocation.fromJson(json['startLocation'])
        : null;
    endLocation = json['endLocation'] != null
        ? StartLocation.fromJson(json['endLocation'])
        : null;
    navigationInstruction = json['navigationInstruction'] != null
        ? NavigationInstruction.fromJson(json['navigationInstruction'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distanceMeters'] = distanceMeters;
    data['staticDuration'] = staticDuration;
    if (polyline != null) {
      data['polyline'] = polyline!.toJson();
    }
    if (startLocation != null) {
      data['startLocation'] = startLocation!.toJson();
    }
    if (endLocation != null) {
      data['endLocation'] = endLocation!.toJson();
    }
    if (navigationInstruction != null) {
      data['navigationInstruction'] = navigationInstruction!.toJson();
    }
    return data;
  }
}

class NavigationInstruction {
  String? maneuver;
  String? instructions;

  NavigationInstruction({this.maneuver, this.instructions});

  NavigationInstruction.fromJson(Map<String, dynamic> json) {
    maneuver = json['maneuver'];
    instructions = json['instructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maneuver'] = maneuver;
    data['instructions'] = instructions;
    return data;
  }
}
