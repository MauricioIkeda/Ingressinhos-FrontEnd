import 'package:ingressinhos_frontend/core/data/models/cart_item_model.dart';
import 'package:ingressinhos_frontend/core/data/models/cart_model.dart';

class CartState {
  CartState({
    this.cart,
    this.isLoading = false,
    this.errorMessage,
  });

  final CartModel? cart;
  final bool isLoading;
  final String? errorMessage;

  List<CartItemModel> get items => cart?.items ?? const [];

  bool get isEmpty => items.isEmpty;

  int get totalTickets =>
      items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount => cart?.totalAmount ?? 0;

  static const _noChange = _NoChange();

  CartState copyWith({
    CartModel? cart,
    bool? isLoading,
    Object? errorMessage = _noChange,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class _NoChange {
  const _NoChange();
}
