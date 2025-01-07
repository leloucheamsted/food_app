class Photo {
  final String url;
  final String width;
  final String height;

  Photo({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      url: json['url'] ?? '',
      width: json['width'] ?? '',
      height: json['height'] ?? '',
    );
  }
}

class RestaurantEntity {
  final String publishedDate;
  final String name;
  final String location;
  final String doubleclickZone;
  final String preferredMapEngine;
  final String rawRanking;
  final String rankingGeo;
  final String rankingGeoId;
  final String rankingPosition;
  final String rankingDenominator;
  final String rankingCategory;
  final String ranking;
  final bool isClosed;
  final String openNowText;
  final bool isLongClosed;
  final String priceLevel;
  final String price;
  final String description;
  final String webUrl;
  final String writeReviewUrl;
  final Photo smallPhoto;
  final Photo thumbnailPhoto;
  final Photo originalPhoto;
  final Photo largePhoto;
  final Photo mediumPhoto;

  RestaurantEntity({
    required this.smallPhoto,
    required this.thumbnailPhoto,
    required this.originalPhoto,
    required this.largePhoto,
    required this.mediumPhoto,
    required this.publishedDate,
    required this.name,
    required this.location,
    required this.doubleclickZone,
    required this.preferredMapEngine,
    required this.rawRanking,
    required this.rankingGeo,
    required this.rankingGeoId,
    required this.rankingPosition,
    required this.rankingDenominator,
    required this.rankingCategory,
    required this.ranking,
    required this.isClosed,
    required this.openNowText,
    required this.isLongClosed,
    required this.priceLevel,
    required this.price,
    required this.description,
    required this.webUrl,
    required this.writeReviewUrl,
  });

  factory RestaurantEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RestaurantEntity(
        smallPhoto: Photo(url: '', width: '', height: ''),
        thumbnailPhoto: Photo(url: '', width: '', height: ''),
        originalPhoto: Photo(url: '', width: '', height: ''),
        largePhoto: Photo(url: '', width: '', height: ''),
        mediumPhoto: Photo(url: '', width: '', height: ''),
        name: '',
        publishedDate: '',
        location: '',
        doubleclickZone: '',
        preferredMapEngine: '',
        rawRanking: '',
        rankingGeo: '',
        rankingGeoId: '',
        rankingPosition: '',
        rankingDenominator: '',
        rankingCategory: '',
        ranking: '',
        isClosed: false,
        openNowText: '',
        isLongClosed: false,
        priceLevel: '',
        price: '',
        description: '',
        webUrl: '',
        writeReviewUrl: '',
      );
    }

    return RestaurantEntity(
      location: json['location_string'] ?? '',
      name: json['name'] ?? '',
      publishedDate: json['published_date'] ?? '',
      doubleclickZone: json['doubleclick_zone'] ?? '',
      preferredMapEngine: json['preferred_map_engine'] ?? '',
      rawRanking: (json['raw_ranking'] ?? ''),
      rankingGeo: json['ranking_geo'] ?? '',
      rankingGeoId: json['ranking_geo_id'] ?? '',
      rankingPosition: json['ranking_position'] ?? '',
      rankingDenominator: json['ranking_denominator'] ?? '',
      rankingCategory: json['ranking_category'] ?? '',
      ranking: json['rating'] ?? '',
      isClosed: json['is_closed'] ?? false,
      openNowText: json['open_now_text'] ?? '',
      isLongClosed: json['is_long_closed'] ?? false,
      priceLevel: json['price_level'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      webUrl: json['web_url'] ?? '',
      writeReviewUrl: json['write_review'] ?? '',
      smallPhoto: Photo.fromJson(json['photo']?['images']?['small'] ?? {}),
      thumbnailPhoto:
          Photo.fromJson(json['photo']?['images']?['thumbnail'] ?? {}),
      originalPhoto:
          Photo.fromJson(json['photo']?['images']?['original'] ?? {}),
      largePhoto: Photo.fromJson(json['photo']?['images']?['large'] ?? {}),
      mediumPhoto: Photo.fromJson(json['photo']?['images']?['medium'] ?? {}),
    );
  }
}
