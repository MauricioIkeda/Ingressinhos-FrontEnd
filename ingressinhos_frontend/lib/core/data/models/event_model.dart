class EventModel {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int locationId;
  final bool hasSeats;
  final String? description;
  final String? imageUrl;

  EventModel({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.hasSeats,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "locationId": locationId,
      "hasSeats": hasSeats,
      "description": description,
      "imageUrl": imageUrl,
      // eventId e sellerId geralmente são enviados pelo backend ou pegos do token
    };
  }
}