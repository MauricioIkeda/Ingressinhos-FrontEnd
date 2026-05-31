class EventModel {
  int? id;
  int? ticketId;
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
    this.ticketId,
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

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.'));
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    int? extractedAvailableQuantity;
    int? extractedTicketId;
    double? extractedBasePrice;
    double? extractedPremiumPrice;
    double? extractedVipPrice;
    DateTime? extractedSalesStartsAt;
    DateTime? extractedSalesEndsAt;
    bool? extractedIsActive;
    if (json['tickets'] != null &&
        json['tickets'] is List &&
        (json['tickets'] as List).isNotEmpty) {
      final firstTicket = json['tickets'][0];
      if (firstTicket is Map<String, dynamic>) {
        extractedAvailableQuantity = parseInt(firstTicket['availableQuantity']);
        extractedTicketId = parseInt(firstTicket['id']);
        extractedBasePrice = parseDouble(firstTicket['basePrice']);
        extractedPremiumPrice = parseDouble(firstTicket['premiumPrice']);
        extractedVipPrice = parseDouble(firstTicket['vipPrice']);
        extractedSalesStartsAt = parseDate(firstTicket['salesStartsAt']);
        extractedSalesEndsAt = parseDate(firstTicket['salesEndsAt']);
        extractedIsActive = parseInt(firstTicket['status']) == 1;
      }
    }

    return EventModel(
      id: parseInt(json['id']),
      ticketId: extractedTicketId,
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
      baseTicketPrice: parseDouble(json['basePrice']) ?? extractedBasePrice,
      premiumTicketPrice:
          parseDouble(json['premiumPrice']) ?? extractedPremiumPrice,
      vipTicketPrice: parseDouble(json['vipPrice']) ?? extractedVipPrice,
      salesStartsAt: parseDate(json['salesStartsAt']) ?? extractedSalesStartsAt,
      salesEndsAt: parseDate(json['salesEndsAt']) ?? extractedSalesEndsAt,
      isActive: json['isActive'] as bool? ?? extractedIsActive,
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
