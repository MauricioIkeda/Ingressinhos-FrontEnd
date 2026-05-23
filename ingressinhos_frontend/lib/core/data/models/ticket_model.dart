class TicketModel {
  final int ticketId;
  final int eventId;
  final String name;
  final double basePrice;
  final double premiumPrice;
  final double vipPrice;
  final DateTime salesStartsAt;
  final DateTime salesEndsAt;
  final bool isActive;

  TicketModel({
    required this.ticketId,
    required this.eventId,
    required this.name,
    required this.basePrice,
    required this.premiumPrice,
    required this.vipPrice,
    required this.salesStartsAt,
    required this.salesEndsAt,
    required this.isActive,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketId: json['ticketId'],
      eventId: json['eventId'],
      name: json['name'],
      basePrice: json['basePrice'].toDouble(),
      premiumPrice: json['premiumPrice'].toDouble(),
      vipPrice: json['vipPrice'].toDouble(),
      salesStartsAt: DateTime.parse(json['salesStartsAt']),
      salesEndsAt: DateTime.parse(json['salesEndsAt']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'name': name,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
      'vipPrice': vipPrice,
      'salesStartsAt': salesStartsAt.toUtc().toIso8601String(),
      'salesEndsAt': salesEndsAt.toUtc().toIso8601String(),
      'isActive': isActive,
    };
  }
}
