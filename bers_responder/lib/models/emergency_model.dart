class Emergency {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final String status;
  final String? responderId;

  Emergency({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.responderId,
  });

  factory Emergency.fromMap(String id, Map<dynamic, dynamic> data) {
    return Emergency(
      id: id,
      responderId: data["responder_ID"],
      location: data['location'] ?? 'Unknown Location',
      latitude: double.tryParse(data['live_es_latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(data['live_es_longitude'].toString()) ?? 0.0,
      status: data['report_Status'] ?? '',
    );
  }

  Emergency copyWith({
    String? id,
    String? location,
    double? latitude,
    double? longitude,
    String? status,
    String? responderId,
  }) {
    return Emergency(
      id: id ?? this.id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      responderId: responderId ?? this.responderId,
    );
  }
}
