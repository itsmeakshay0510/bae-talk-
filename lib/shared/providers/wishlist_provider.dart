import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../runtime/app_runtime.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return WishlistNotifier(uid: user?.uid);
});

class WishlistNotifier extends StateNotifier<List<String>> {
  final String? uid;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  WishlistNotifier({this.uid}) : super([]) {
    if (AppRuntime.isDemoMode) {
      _loadDemoWishlist();
    } else if (uid != null && AppRuntime.firebaseReady) {
      _loadWishlist();
    }
  }

  void _loadDemoWishlist() async {
    final box = await Hive.openBox('wishlist');
    state = List<String>.from(box.get('items') ?? []);
  }

  void _loadWishlist() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      state = List<String>.from(doc.data()?['wishlist'] ?? []);
    }
  }

  void toggle(String productId) async {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }

    if (AppRuntime.isDemoMode) {
      final box = await Hive.openBox('wishlist');
      await box.put('items', state);
      return;
    }

    if (uid != null && AppRuntime.firebaseReady) {
      await _firestore.collection('users').doc(uid).update({
        'wishlist': state,
      });
    }
  }

  bool isWishlisted(String productId) => state.contains(productId);
}
