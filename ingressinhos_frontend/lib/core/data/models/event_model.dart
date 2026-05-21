import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

class EventModel {
  final int? id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int locationId;
  LocationModel? location;
  double? baseTicketPrice;
  final bool hasSeats;
  final String? description;
  final String? imageUrl;

  EventModel({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    this.location,
    required this.hasSeats,
    this.description,
    this.imageUrl,
    this.baseTicketPrice,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      locationId: json['locationId'],
      hasSeats: json['hasSeats'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      baseTicketPrice: json['baseTicketPrice'] != null ? double.parse(json['baseTicketPrice'].toString()) : null,
    );
  }
}