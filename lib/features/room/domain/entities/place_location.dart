class PlaceLocation {
  final String address;
  final double lat;
  final double lng;

  const PlaceLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'address': address, 'lat': lat, 'lng': lng};

  @override
  String toString() =>
      'PlaceLocation(address: '
      '$address, lat: $lat, lng: $lng)';
}
