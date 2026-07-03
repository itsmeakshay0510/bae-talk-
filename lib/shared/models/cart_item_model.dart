import 'product_model.dart';

class CartItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final double originalPrice;
  final String size;
  final String color;
  int quantity;
  final String sellerId;
  final String sellerName;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.size,
    required this.color,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
  });

  double get totalPrice => price * quantity;
  double get savings => (originalPrice - price) * quantity;

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    productId: productId,
    name: name,
    image: image,
    price: price,
    originalPrice: originalPrice,
    size: size,
    color: color,
    quantity: quantity ?? this.quantity,
    sellerId: sellerId,
    sellerName: sellerName,
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'originalPrice': originalPrice,
    'size': size,
    'color': color,
    'quantity': quantity,
    'sellerId': sellerId,
    'sellerName': sellerName,
  };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
    productId: map['productId'],
    name: map['name'],
    image: map['image'],
    price: (map['price'] as num).toDouble(),
    originalPrice: (map['originalPrice'] as num).toDouble(),
    size: map['size'],
    color: map['color'],
    quantity: map['quantity'],
    sellerId: map['sellerId'],
    sellerName: map['sellerName'],
  );

  factory CartItemModel.fromProduct(ProductModel product, String size, String color) =>
      CartItemModel(
        productId: product.id,
        name: product.name,
        image: product.images.isNotEmpty ? product.images[0] : '',
        price: product.price,
        originalPrice: product.originalPrice,
        size: size,
        color: color,
        quantity: 1,
        sellerId: product.sellerId,
        sellerName: product.sellerName,
      );
}
