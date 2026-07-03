import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../runtime/app_runtime.dart';

FirebaseFirestore get _firestore => FirebaseFirestore.instance;

// All products stream
final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  if (AppRuntime.isDemoMode) return Stream.value(_demoProducts);
  return _firestore.collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
});

// Trending products
final trendingProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  if (AppRuntime.isDemoMode) {
    return Stream.value(_demoProducts.where((p) => p.isTrending).toList());
  }
  return _firestore.collection('products')
      .where('isTrending', isEqualTo: true)
      .limit(10)
      .snapshots()
      .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
});

// New arrivals
final newArrivalsProvider = StreamProvider<List<ProductModel>>((ref) {
  if (AppRuntime.isDemoMode) {
    return Stream.value(_demoProducts.where((p) => p.isNewArrival).toList());
  }
  return _firestore.collection('products')
      .where('isNewArrival', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(12)
      .snapshots()
      .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
});

// Featured products
final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  if (AppRuntime.isDemoMode) {
    return Stream.value(_demoProducts.where((p) => p.isFeatured).toList());
  }
  return _firestore.collection('products')
      .where('isFeatured', isEqualTo: true)
      .limit(8)
      .snapshots()
      .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
});

// Products by category
final categoryProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, category) {
  if (AppRuntime.isDemoMode) {
    if (category == 'All') return Stream.value(_demoProducts);
    return Stream.value(_demoProducts.where((p) => p.category == category).toList());
  }
  if (category == 'All') {
    return _firestore.collection('products')
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
  }
  return _firestore.collection('products')
      .where('category', isEqualTo: category)
      .snapshots()
      .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
});

// Single product
final productDetailProvider = StreamProvider.family<ProductModel?, String>((ref, id) {
  if (AppRuntime.isDemoMode) {
    for (final product in _demoProducts) {
      if (product.id == id) return Stream.value(product);
    }
    return Stream.value(null);
  }
  return _firestore.collection('products')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? ProductModel.fromFirestore(doc) : null);
});

// Search products
final searchResultsProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  if (AppRuntime.isDemoMode) {
    final normalized = query.toLowerCase();
    return _demoProducts.where((product) {
      final haystack = [
        product.name,
        product.description,
        product.category,
        product.subCategory,
        ...product.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }
  final snapshot = await _firestore.collection('products')
      .where('tags', arrayContains: query.toLowerCase())
      .limit(20)
      .get();
  return snapshot.docs.map(ProductModel.fromFirestore).toList();
});

final _demoProducts = _generateDemoProducts();

List<ProductModel> _generateDemoProducts() {
  final baseList = <ProductModel>[
    ProductModel(
      id: 'demo-kurti-1',
      name: 'Embroidered Cotton Kurti',
      description: 'Soft daily-wear kurti with light embroidery and a relaxed fit.',
      price: 799,
      originalPrice: 1299,
      discountPercent: 38,
      images: const ['https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=450'],
      category: 'Women',
      subCategory: 'Ethnic',
      sizes: const ['S', 'M', 'L', 'XL'],
      colors: const ['Pink', 'Yellow', 'White'],
      sellerId: 'demo-seller',
      sellerName: 'Bae Select',
      rating: 4.6,
      reviewCount: 128,
      stockCount: 24,
      isFeatured: true,
      isNewArrival: true,
      isTrending: true,
      tags: const ['kurti', 'ethnic', 'cotton', 'women'],
      createdAt: DateTime(2026, 6, 20),
    ),
    ProductModel(
      id: 'demo-dress-1',
      name: 'Summer Floral Midi Dress',
      description: 'Breathable floral dress for brunches, holidays, and warm evenings.',
      price: 1199,
      originalPrice: 1899,
      discountPercent: 37,
      images: const ['https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=450'],
      category: 'Women',
      subCategory: 'Western',
      sizes: const ['XS', 'S', 'M', 'L'],
      colors: const ['Blue', 'Green'],
      sellerId: 'demo-seller',
      sellerName: 'Urban Loom',
      rating: 4.4,
      reviewCount: 94,
      stockCount: 18,
      isFeatured: true,
      isNewArrival: true,
      isTrending: true,
      tags: const ['dress', 'summer', 'floral', 'western'],
      createdAt: DateTime(2026, 6, 18),
    ),
    ProductModel(
      id: 'demo-shirt-1',
      name: 'Classic Linen Shirt',
      description: 'Lightweight linen shirt with a clean tailored silhouette.',
      price: 999,
      originalPrice: 1499,
      discountPercent: 33,
      images: const ['https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=450'],
      category: 'Men',
      subCategory: 'Shirts',
      sizes: const ['M', 'L', 'XL', 'XXL'],
      colors: const ['White', 'Navy', 'Olive'],
      sellerId: 'demo-seller',
      sellerName: 'Thread Co.',
      rating: 4.5,
      reviewCount: 76,
      stockCount: 32,
      isFeatured: false,
      isNewArrival: true,
      isTrending: true,
      tags: const ['shirt', 'linen', 'men'],
      createdAt: DateTime(2026, 6, 12),
    ),
    ProductModel(
      id: 'demo-bag-1',
      name: 'Quilted Mini Sling Bag',
      description: 'Compact sling bag with a quilted finish and metal chain strap.',
      price: 699,
      originalPrice: 999,
      discountPercent: 30,
      images: const ['https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=450'],
      category: 'Accessories',
      subCategory: 'Bags',
      sizes: const [],
      colors: const ['Black', 'Tan', 'Pink'],
      sellerId: 'demo-seller',
      sellerName: 'Bae Select',
      rating: 4.3,
      reviewCount: 52,
      stockCount: 15,
      isFeatured: true,
      isNewArrival: false,
      isTrending: false,
      tags: const ['bag', 'sling', 'accessories'],
      createdAt: DateTime(2026, 6, 6),
    ),
  ];

  final categories = ['Women', 'Men', 'Kids', 'Ethnic', 'Western', 'Accessories'];
  final subCategories = {
    'Women': ['Dresses', 'Tops', 'Skirts', 'Footwear'],
    'Men': ['Shirts', 'T-Shirts', 'Trousers', 'Footwear'],
    'Kids': ['T-Shirts', 'Dresses', 'Ethnic', 'Toys'],
    'Ethnic': ['Kurtas', 'Sarees', 'Sherwanis'],
    'Western': ['Jeans', 'Jackets', 'Coats'],
    'Accessories': ['Bags', 'Watches', 'Sunglasses', 'Belts']
  };

  final fashionImages = [
    'photo-1434389677669-e08b4cac3105',
    'photo-1483985988355-763728e1935b',
    'photo-1490481651871-ab68de25d43d',
    'photo-1539571696357-5a69c17a67c6',
    'photo-1507679799987-c73779587ccf',
    'photo-1544441893-675973e31985',
    'photo-1509631179647-0177331693ae',
    'photo-1525507119028-ed4c629a60a3',
    'photo-1479064555552-3ef4979f8908',
    'photo-1512436991641-6745cdb1723f',
    'photo-1554568218-0f1715e72254',
    'photo-1620799140408-edc6dcb6d633',
    'photo-1603252109303-2751441dd157',
    'photo-1618244972963-dbee1a7edc95',
    'photo-1595950653106-6c9ebd614d3a',
    'photo-1560343090-f0409e92791a',
    'photo-1505740420928-5e560c06d30e',
    'photo-1523275335684-37898b6baf30',
    'photo-1572635196237-14b3f281503f',
    'photo-1584917865442-de89df76afd3',
  ];

  for (int i = 1; i <= 50; i++) {
    final category = categories[i % categories.length];
    final subList = subCategories[category]!;
    final subCat = subList[i % subList.length];
    final imageId = fashionImages[i % fashionImages.length];
    final price = 499 + (i * 45) % 2500;
    final originalPrice = (price * 1.5).round();
    final discountPercent = (((originalPrice - price) / originalPrice) * 100).round();

    baseList.add(
      ProductModel(
        id: 'gen-prod-$i',
        name: 'Premium $subCat - Style $i',
        description: 'Exquisite $subCat designed for the modern look. Made from high-quality materials to ensure extreme comfort and fashion appeal. Perfect for daily wear or special occasions.',
        price: price.toDouble(),
        originalPrice: originalPrice.toDouble(),
        discountPercent: discountPercent.toDouble(),
        images: ['https://images.unsplash.com/$imageId?w=225'],
        category: category,
        subCategory: subCat,
        sizes: const ['S', 'M', 'L', 'XL'],
        colors: const ['Black', 'Blue', 'White', 'Purple'],
        sellerId: 'gen-seller-${i % 4}',
        sellerName: 'Fashion Hub ${i % 3 + 1}',
        rating: double.parse((4.0 + (i % 10) * 0.1).toStringAsFixed(1)),
        reviewCount: 15 + i * 3,
        stockCount: 10 + i % 20,
        isFeatured: i % 7 == 0,
        isNewArrival: i % 5 == 0,
        isTrending: i % 3 == 0,
        tags: [category.toLowerCase(), subCat.toLowerCase(), 'fashion', 'style'],
        createdAt: DateTime(2026, 6, i % 28 + 1),
      ),
    );
  }
  return baseList;
}
