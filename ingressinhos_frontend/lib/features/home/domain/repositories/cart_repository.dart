import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';

abstract class CartRepository {
  Future<void> addCartItem({
    required int ticketId,
    required int quantity,
    int? seatId,
  });

  Future<CartModel> getCart({required int clientId});

  Future<void> removeCartItem({required int orderItemId});

  Future<void> resetCart({required int clientId});
}
