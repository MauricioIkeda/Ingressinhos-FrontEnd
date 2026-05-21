class TicketModel {
  final int ticketId;
  final int sellerId;
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
    required this.sellerId,
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
      sellerId: json['sellerId'],
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
}