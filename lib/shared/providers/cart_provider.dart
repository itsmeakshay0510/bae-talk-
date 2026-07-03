import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/cart_item_model.dart';
import '../../shared/models/product_model.dart';

// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

// Cart count
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

// Cart total
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.totalPrice);
});

// Cart savings
final cartSavingsProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.savings);
});

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]) {
    _loadCart();
  }

  final _box = Hive.box('cart');

  void _loadCart() {
    final data = _box.get('items');
    if (data != null) {
      state = (data as List).map((e) => CartItemModel.fromMap(Map<String, dynamic>.from(e))).toList();
    }
  }

  void _saveCart() {
    _box.put('items', state.map((e) => e.toMap()).toList());
  }

  void addItem(ProductModel product, String size, String color) {
    final existingIndex = state.indexWhere(
      (item) => item.productId == product.id && item.size == size && item.color == color,
    );

    if (existingIndex >= 0) {
      final updated = List<CartItemModel>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItemModel.fromProduct(product, size, color)];
    }
    _saveCart();
  }

  void removeItem(String productId, String size, String color) {
    state = state.where((item) =>
      !(item.productId == productId && item.size == size && item.color == color)
    ).toList();
    _saveCart();
  }

  void updateQuantity(String productId, String size, String color, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, size, color);
      return;
    }
    final updated = List<CartItemModel>.from(state);
    final index = updated.indexWhere(
      (item) => item.productId == productId && item.size == size && item.color == color,
    );
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = updated;
      _saveCart();
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }
}
