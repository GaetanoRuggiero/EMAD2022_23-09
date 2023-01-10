class GoogleVisionResponse {
  List<Responses>? responses;

  GoogleVisionResponse({this.responses});

  GoogleVisionResponse.fromJson(Map<String, dynamic> json) {
    if (json['responses'] != null) {
      responses = <Responses>[];
      json['responses'].forEach((v) {
        responses!.add(Responses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (responses != null) {
      data['responses'] = responses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Responses {
  WebDetection? webDetection;

  Responses({this.webDetection});

  Responses.fromJson(Map<String, dynamic> json) {
    webDetection = json['webDetection'] != null
        ? WebDetection.fromJson(json['webDetection'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (webDetection != null) {
      data['webDetection'] = webDetection!.toJson();
    }
    return data;
  }
}

class WebDetection {
  List<WebEntities>? webEntities;
  List<PartialMatchingImages>? partialMatchingImages;
  List<PagesWithMatchingImages>? pagesWithMatchingImages;
  List<VisuallySimilarImages>? visuallySimilarImages;
  List<BestGuessLabels>? bestGuessLabels;

  WebDetection(
      {this.webEntities,
        this.partialMatchingImages,
        this.pagesWithMatchingImages,
        this.visuallySimilarImages,
        this.bestGuessLabels});

  WebDetection.fromJson(Map<String, dynamic> json) {
    if (json['webEntities'] != null) {
      webEntities = <WebEntities>[];
      json['webEntities'].forEach((v) {
        webEntities!.add(WebEntities.fromJson(v));
      });
    }
    if (json['partialMatchingImages'] != null) {
      partialMatchingImages = <PartialMatchingImages>[];
      json['partialMatchingImages'].forEach((v) {
        partialMatchingImages!.add(PartialMatchingImages.fromJson(v));
      });
    }
    if (json['pagesWithMatchingImages'] != null) {
      pagesWithMatchingImages = <PagesWithMatchingImages>[];
      json['pagesWithMatchingImages'].forEach((v) {
        pagesWithMatchingImages!.add(PagesWithMatchingImages.fromJson(v));
      });
    }
    if (json['visuallySimilarImages'] != null) {
      visuallySimilarImages = <VisuallySimilarImages>[];
      json['visuallySimilarImages'].forEach((v) {
        visuallySimilarImages!.add(VisuallySimilarImages.fromJson(v));
      });
    }
    if (json['bestGuessLabels'] != null) {
      bestGuessLabels = <BestGuessLabels>[];
      json['bestGuessLabels'].forEach((v) {
        bestGuessLabels!.add(BestGuessLabels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (webEntities != null) {
      data['webEntities'] = webEntities!.map((v) => v.toJson()).toList();
    }
    if (partialMatchingImages != null) {
      data['partialMatchingImages'] =
          partialMatchingImages!.map((v) => v.toJson()).toList();
    }
    if (pagesWithMatchingImages != null) {
      data['pagesWithMatchingImages'] =
          pagesWithMatchingImages!.map((v) => v.toJson()).toList();
    }
    if (visuallySimilarImages != null) {
      data['visuallySimilarImages'] =
          visuallySimilarImages!.map((v) => v.toJson()).toList();
    }
    if (bestGuessLabels != null) {
      data['bestGuessLabels'] =
          bestGuessLabels!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WebEntities {
  String? entityId;
  double? score;
  String? description;

  WebEntities({this.entityId, this.score, this.description});

  WebEntities.fromJson(Map<String, dynamic> json) {
    entityId = json['entityId'];
    score = json['score'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['entityId'] = entityId;
    data['score'] = score;
    data['description'] = description;
    return data;
  }
}

class PartialMatchingImages {
  String? url;

  PartialMatchingImages({this.url});

  PartialMatchingImages.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}

class PagesWithMatchingImages {
  String? url;
  String? pageTitle;
  List<PartialMatchingImages>? partialMatchingImages;

  PagesWithMatchingImages(
      {this.url, this.pageTitle, this.partialMatchingImages});

  PagesWithMatchingImages.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    pageTitle = json['pageTitle'];
    if (json['partialMatchingImages'] != null) {
      partialMatchingImages = <PartialMatchingImages>[];
      json['partialMatchingImages'].forEach((v) {
        partialMatchingImages!.add(PartialMatchingImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['pageTitle'] = pageTitle;
    if (partialMatchingImages != null) {
      data['partialMatchingImages'] =
          partialMatchingImages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisuallySimilarImages {
  String? url;

  VisuallySimilarImages({this.url});

  VisuallySimilarImages.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}

class BestGuessLabels {
  String? label;

  BestGuessLabels({this.label});

  BestGuessLabels.fromJson(Map<String, dynamic> json) {
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}