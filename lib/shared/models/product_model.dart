import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final double discountPercent;
  final List<String> images;
  final String category;
  final String subCategory;
  final List<String> sizes;
  final List<String> colors;
  final String sellerId;
  final String sellerName;
  final double rating;
  final int reviewCount;
  final int stockCount;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isTrending;
  final List<String> tags;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.images,
    required this.category,
    required this.subCategory,
    required this.sizes,
    required this.colors,
    required this.sellerId,
    required this.sellerName,
    required this.rating,
    required this.reviewCount,
    required this.stockCount,
    required this.isFeatured,
    required this.isNewArrival,
    required this.isTrending,
    required this.tags,
    required this.createdAt,
  });

  double get discountAmount => originalPrice - price;
  bool get isInStock => stockCount > 0;
  bool get hasFreeDelivery => price >= 499;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockCount: data['stockCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
      isTrending: data['isTrending'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'discountPercent': discountPercent,
    'images': images,
    'category': category,
    'subCategory': subCategory,
    'sizes': sizes,
    'colors': colors,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'rating': rating,
    'reviewCount': reviewCount,
    'stockCount': stockCount,
    'isFeatured': isFeatured,
    'isNewArrival': isNewArrival,
    'isTrending': isTrending,
    'tags': tags,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
