class TicketModel {
  final int ticketId;
  final int eventId;
  final String name;
  final double basePrice;
  final double? premiumPrice;
  final double? vipPrice;
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
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.'));
    }

    return TicketModel(
      ticketId: json['ticketId'],
      eventId: json['eventId'],
      name: json['name'],
      basePrice: parseDouble(json['basePrice']) ?? 0,
      premiumPrice: parseDouble(json['premiumPrice']),
      vipPrice: parseDouble(json['vipPrice']),
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
