import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { placed, confirmed, packed, shipped, outForDelivery, delivered, cancelled, returned }

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final String paymentId;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? trackingId;
  final String? cancelReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentId,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingId,
    this.cancelReason,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.packed: return 'Packed';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.returned: return 'Returned';
    }
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List).map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i))).toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      deliveryCharge: (data['deliveryCharge'] as num).toDouble(),
      discount: (data['discount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      deliveryAddress: AddressModel.fromMap(Map<String, dynamic>.from(data['deliveryAddress'])),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentId: data['paymentId'] ?? '',
      status: OrderStatus.values.byName(data['status'] ?? 'placed'),
      createdAt: data['createdAt'] is String 
          ? DateTime.parse(data['createdAt']) 
          : (data['createdAt'] as Timestamp).toDate(),
      estimatedDelivery: data['estimatedDelivery'] == null 
          ? null 
          : (data['estimatedDelivery'] is String 
              ? DateTime.parse(data['estimatedDelivery']) 
              : (data['estimatedDelivery'] as Timestamp).toDate()),
      trackingId: data['trackingId'],
      cancelReason: data['cancelReason'],
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryCharge': deliveryCharge,
    'discount': discount,
    'totalAmount': totalAmount,
    'deliveryAddress': deliveryAddress.toMap(),
    'paymentMethod': paymentMethod,
    'paymentId': paymentId,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'trackingId': trackingId,
    'cancelReason': cancelReason,
  };

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryCharge': deliveryCharge,
    'discount': discount,
    'totalAmount': totalAmount,
    'deliveryAddress': deliveryAddress.toMap(),
    'paymentMethod': paymentMethod,
    'paymentId': paymentId,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'estimatedDelivery': estimatedDelivery != null ? Timestamp.fromDate(estimatedDelivery!) : null,
    'trackingId': trackingId,
    'cancelReason': cancelReason,
  };
}

class OrderItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String size;
  final String color;

  OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'quantity': quantity,
    'size': size,
    'color': color,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    productId: map['productId'],
    name: map['name'],
    image: map['image'],
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'],
    size: map['size'],
    color: map['color'],
  );
}

class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final String type; // home, work, other

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
    required this.type,
  });

  String get fullAddress => '$addressLine1, $addressLine2, $city, $state - $pincode';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isDefault': isDefault,
    'type': type,
  };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id'] ?? '',
    name: map['name'],
    phone: map['phone'],
    addressLine1: map['addressLine1'],
    addressLine2: map['addressLine2'] ?? '',
    city: map['city'],
    state: map['state'],
    pincode: map['pincode'],
    isDefault: map['isDefault'] ?? false,
    type: map['type'] ?? 'home',
  );
}
