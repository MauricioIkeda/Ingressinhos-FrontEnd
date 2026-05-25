import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';
import 'package:ingressinhos_frontend/core/data/models/checkout_response_model.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/cart_remote_datasource.dart';

class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  final IngressinhosDioClient _ingressinhosClient;

  CartRemoteDatasourceImpl(this._ingressinhosClient);

  @override
  Future<void> addCartItem({
    required int ticketId,
    required int quantity,
    int? seatId,
  }) async {
    try {
      await _ingressinhosClient.dio.post(
        Endpoints.cartItems,
        data: {
          'ticketId': ticketId,
          'quantity': quantity,
          'seatId': seatId,
        },
      );
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao adicionar item no carrinho'),
      );
    } catch (e) {
      throw IngressinhosException(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<CartModel> getCart({required int clientId}) async {
    try {
      final response = await _ingressinhosClient.dio.get(
        Endpoints.cartByClient(clientId),
      );
      return CartModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao buscar carrinho'),
      );
    } catch (e) {
      throw IngressinhosException(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<void> removeCartItem({required int orderItemId}) async {
    try {
      await _ingressinhosClient.dio.delete(
        Endpoints.cartItemById(orderItemId),
      );
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao remover item do carrinho'),
      );
    } catch (e) {
      throw IngressinhosException(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<void> resetCart({required int clientId}) async {
    try {
      await _ingressinhosClient.dio.delete(
        Endpoints.cartReset(clientId),
      );
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao resetar carrinho'),
      );
    } catch (e) {
      throw IngressinhosException(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<CheckoutResponseModel> checkout({required int orderId}) async {
    try {
      final response = await _ingressinhosClient.dio.patch(
        Endpoints.cartCheckout(orderId),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CheckoutResponseModel.fromJson(data);
      }
      throw IngressinhosException('Resposta inválida ao finalizar compra');
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao finalizar compra'),
      );
    } catch (e) {
      throw IngressinhosException(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
