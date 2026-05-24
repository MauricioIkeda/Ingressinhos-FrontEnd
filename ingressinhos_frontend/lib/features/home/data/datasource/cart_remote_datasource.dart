import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';

abstract class CartRemoteDatasource {
  Future<void> addCartItem({
    required int ticketId,
    required int quantity,
    int? seatId,
  });

  Future<CartModel> getCart({required int clientId});
}
