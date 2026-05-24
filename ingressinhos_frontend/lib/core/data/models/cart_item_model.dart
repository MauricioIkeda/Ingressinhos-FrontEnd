class CartItemModel {
  final int? id;
  final int? orderId;
  final int? ticketId;
  final String ticketName;
  final int quantity;
  final double unitPrice;
  final int? category;
  final int? seatId;
  final String? seatCode;
  final double totalPrice;

  const CartItemModel({
    this.id,
    this.orderId,
    this.ticketId,
    required this.ticketName,
    required this.quantity,
    required this.unitPrice,
    this.category,
    this.seatId,
    this.seatCode,
    required this.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    double parseUnitPrice(dynamic value) {
      if (value is Map<String, dynamic>) {
        return parseDouble(value['value']);
      }
      return parseDouble(value);
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return CartItemModel(
      id: json['id'] as int?,
      orderId: json['orderId'] as int?,
      ticketId: json['ticketId'] as int?,
      ticketName: json['ticketName']?.toString() ?? 'Ingresso',
      quantity: parseInt(json['quantity']),
      unitPrice: parseUnitPrice(json['unitPrice']),
      category: json['category'] as int?,
      seatId: json['seatId'] as int?,
      seatCode: json['seatCode']?.toString(),
      totalPrice: parseDouble(json['totalPrice']),
    );
  }
}
