class EwasteCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String contact;
  final List<String> acceptedItems;

  EwasteCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.contact,
    required this.acceptedItems,
  });

  factory EwasteCenter.fromFirestore(Map<String, dynamic> data, String id) {
    return EwasteCenter(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      contact: data['contact'] ?? '',
      acceptedItems: List<String>.from(data['accepted_items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'contact': contact,
      'accepted_items': acceptedItems,
    };
  }
}
