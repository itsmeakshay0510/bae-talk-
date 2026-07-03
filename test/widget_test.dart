import 'package:bae_talk/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product model computes sale metadata', () {
    final product = ProductModel(
      id: 'test',
      name: 'Test Product',
      description: 'Demo',
      price: 799,
      originalPrice: 999,
      discountPercent: 20,
      images: const [],
      category: 'Women',
      subCategory: 'Ethnic',
      sizes: const ['M'],
      colors: const ['Pink'],
      sellerId: 'seller',
      sellerName: 'Seller',
      rating: 4.5,
      reviewCount: 10,
      stockCount: 5,
      isFeatured: true,
      isNewArrival: true,
      isTrending: true,
      tags: const ['demo'],
      createdAt: DateTime(2026),
    );

    expect(product.discountAmount, 200);
    expect(product.isInStock, isTrue);
    expect(product.hasFreeDelivery, isTrue);
  });
}
