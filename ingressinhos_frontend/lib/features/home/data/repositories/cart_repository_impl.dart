import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';
import 'package:ingressinhos_frontend/core/data/models/checkout_response_model.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/cart_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDatasource _remoteDatasource;

  CartRepositoryImpl({required CartRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<void> addCartItem({
    required int ticketId,
    required int quantity,
    int? seatId,
  }) {
    return _remoteDatasource.addCartItem(
      ticketId: ticketId,
      quantity: quantity,
      seatId: seatId,
    );
  }

  @override
  Future<CartModel> getCart({required int clientId}) {
    return _remoteDatasource.getCart(clientId: clientId);
  }

  @override
  Future<void> removeCartItem({required int orderItemId}) {
    return _remoteDatasource.removeCartItem(orderItemId: orderItemId);
  }

  @override
  Future<void> resetCart({required int clientId}) {
    return _remoteDatasource.resetCart(clientId: clientId);
  }

  @override
  Future<CheckoutResponseModel> checkout({required int orderId}) {
    return _remoteDatasource.checkout(orderId: orderId);
  }
}
