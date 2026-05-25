import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/cart_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(CartState());

  Future<void> loadCart({int clientId = 0}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final cart = await _cartRepository.getCart(clientId: clientId);
      emit(state.copyWith(cart: cart, isLoading: false));
    } on IngressinhosException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addTickets({
    required EventModel event,
    int baseQuantity = 0,
    int premiumQuantity = 0,
    int vipQuantity = 0,
  }) async {
    final total = baseQuantity + premiumQuantity + vipQuantity;
    if (total <= 0) return;

    final ticketId = event.ticketId;
    if (ticketId == null) {
      throw IngressinhosException(
        'Ingresso indisponível para este evento.',
      );
    }

    await _cartRepository.addCartItem(
      ticketId: ticketId,
      quantity: total,
      seatId: null,
    );

    await loadCart(clientId: 0);
  }

  Future<void> removeItem({required int orderItemId}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _cartRepository.removeCartItem(orderItemId: orderItemId);
      await loadCart(clientId: 0);
    } on IngressinhosException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> resetCart({int clientId = 0}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _cartRepository.resetCart(clientId: clientId);
      await loadCart(clientId: clientId);
    } on IngressinhosException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> checkout({int orderId = 0}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _cartRepository.checkout(orderId: orderId);
      await loadCart(clientId: orderId);
    } on IngressinhosException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
