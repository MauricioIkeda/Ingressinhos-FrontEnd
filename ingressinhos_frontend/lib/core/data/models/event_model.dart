import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

class EventModel {
  int? id;
  int? sellerId;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int locationId;
  String? locationName;
  double? baseTicketPrice;
  double? premiumTicketPrice;
  double? vipTicketPrice;
  final bool hasSeats;
  final String? description;
  final String? imageUrl;

  EventModel({
    this.id,
    this.sellerId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    this.locationName,
    required this.hasSeats,
    this.description,
    this.imageUrl,
    this.baseTicketPrice,
    this.premiumTicketPrice,
    this.vipTicketPrice,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'], 
      sellerId: json['sellerId'],
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

  Map<String, dynamic> toJson() {
    return {
      'sellerId': sellerId,
      'name': name,
      'startTime': startTime.toUtc().toIso8601String(), 
      'endTime': endTime.toUtc().toIso8601String(),
      'locationId': locationId,
      'hasSeats': hasSeats,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}