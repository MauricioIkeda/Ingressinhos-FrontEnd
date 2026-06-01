import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';
import 'package:ingressinhos_frontend/core/data/models/checkout_response_model.dart';

abstract class CartRepository {
  Future<void> addCartItem({
    required int ticketId,
    required int quantity,
    int? seatId,
  });

  Future<CartModel> getCart({required int clientId});

  Future<void> removeCartItem({required int orderItemId});

  Future<void> resetCart({required int clientId});

  Future<CheckoutResponseModel> checkout({required int orderId});

  Future<CheckoutResponseModel> immediateOrder({
    required int ticketId,
    required int quantity,
    int? seatId,
  });
}
