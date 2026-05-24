import 'package:ingressinhos_frontend/core/data/models/cart_item_model.dart';

class CartModel {
  final int? id;
  final int? clientId;
  final double totalAmount;
  final int? status;
  final List<CartItemModel> items;

  const CartModel({
    this.id,
    this.clientId,
    required this.totalAmount,
    this.status,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final itemsJson = json['items'];
    final parsedItems = (itemsJson is List)
        ? itemsJson
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList()
        : <CartItemModel>[];

    return CartModel(
      id: json['id'] as int?,
      clientId: json['clientId'] as int?,
      totalAmount: parseDouble(json['totalAmount']),
      status: json['status'] as int?,
      items: parsedItems,
    );
  }
}
