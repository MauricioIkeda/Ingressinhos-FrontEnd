class EventModel {
  int? id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int locationId;
  String? locationName;
  final int? locationTotalCapacity;
  final bool? locationHasSeats;
  final bool hasSeats;
  final String? description;
  final String? imageUrl;

  String? sellerTradingName;
  double? baseTicketPrice;
  double? premiumTicketPrice;
  double? vipTicketPrice;
  final DateTime? salesStartsAt;
  final DateTime? salesEndsAt;
  final bool? isActive;
  final int? availableTickets;

  EventModel({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    this.locationName,
    this.locationTotalCapacity,
    this.locationHasSeats,
    required this.hasSeats,
    this.description,
    this.imageUrl,
    this.sellerTradingName,
    this.baseTicketPrice,
    this.premiumTicketPrice,
    this.vipTicketPrice,
    this.isActive,
    this.salesStartsAt,
    this.salesEndsAt,
    this.availableTickets,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    int? extractedAvailableQuantity;
    if (json['tickets'] != null && json['tickets'] is List && (json['tickets'] as List).isNotEmpty) {
      extractedAvailableQuantity = parseInt(json['tickets'][0]['availableQuantity']);
    }

    return EventModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      locationId: parseInt(json['locationId']) ?? 0,
      locationName: json['locationName']?.toString(),
      locationTotalCapacity: parseInt(json['locationTotalCapacity']),
      locationHasSeats: json['locationHasSeats'] as bool?,
      hasSeats: json['hasSeats'] == true,
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      sellerTradingName: json['sellerTradingName']?.toString(),
      baseTicketPrice: json['basePrice'],
      premiumTicketPrice: json['premiumPrice'],
      vipTicketPrice: json['vipPrice'],
      salesStartsAt: json['salesStartsAt'] != null
          ? DateTime.parse(json['salesStartsAt'])
          : null,
      salesEndsAt: json['salesEndsAt'] != null
          ? DateTime.parse(json['salesEndsAt'])
          : null,
      isActive: json['isActive'] as bool?,
      availableTickets: extractedAvailableQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
