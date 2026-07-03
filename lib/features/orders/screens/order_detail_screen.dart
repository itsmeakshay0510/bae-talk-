import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/runtime/app_runtime.dart';

final orderDetailProvider = StreamProvider.family<OrderModel?, String>((ref, orderId) async* {
  if (AppRuntime.isDemoMode) {
    final box = await Hive.openBox('orders');
    OrderModel? getOrder() {
      final data = box.get(orderId);
      if (data == null) return null;
      return OrderModel.fromMap(orderId, Map<String, dynamic>.from(data));
    }
    yield getOrder();
    await for (final _ in box.watch(key: orderId)) {
      yield getOrder();
    }
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Order Details',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final steps = [
            OrderStatus.placed, OrderStatus.confirmed, OrderStatus.packed,
            OrderStatus.shipped, OrderStatus.outForDelivery, OrderStatus.delivered,
          ];
          final currentStep = steps.indexOf(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tracking Timeline
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Tracking',
                        style: AppTextStyles.heading4.copyWith(
                          color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 20),
                      ...steps.asMap().entries.map((e) {
                        final isCompleted = e.key <= currentStep;
                        final isCurrent = e.key == currentStep;
                        return _TrackingStep(
                          status: e.value,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          isLast: e.key == steps.length - 1,
                        );
                      }).toList(),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // Delivery Address
                _InfoCard(
                  isDark: isDark,
                  title: 'Delivery Address',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.deliveryAddress.name, style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(order.deliveryAddress.fullAddress,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium)),
                      Text('Ph: ${order.deliveryAddress.phone}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium)),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // Order Items
                _InfoCard(
                  isDark: isDark,
                  title: 'Items Ordered',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    children: order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body.copyWith(
                                    color: isDark ? Colors.white : AppColors.textDark,
                                    fontWeight: FontWeight.w500)),
                                Text('${item.size} • ${item.color} • Qty: ${item.quantity}',
                                  style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          Text(formatter.format(item.price * item.quantity),
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textDark)),
                        ],
                      ),
                    )).toList(),
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // Price Summary
                _InfoCard(
                  isDark: isDark,
                  title: 'Price Details',
                  icon: Icons.receipt_outlined,
                  child: Column(
                    children: [
                      _Row('Subtotal', formatter.format(order.subtotal), isDark),
                      const SizedBox(height: 8),
                      _Row('Delivery', order.deliveryCharge == 0 ? 'FREE'
                          : formatter.format(order.deliveryCharge), isDark,
                          valueColor: order.deliveryCharge == 0 ? AppColors.success : null),
                      if (order.discount > 0) ...[
                        const SizedBox(height: 8),
                        _Row('Discount', '-${formatter.format(order.discount)}',
                            isDark, valueColor: AppColors.success),
                      ],
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 6),
                      _Row('Total Paid', formatter.format(order.totalAmount), isDark, isBold: true),
                      const SizedBox(height: 8),
                      _Row('Payment', order.paymentMethod.toUpperCase(), isDark),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Cancel/Return Actions
                if (order.status == OrderStatus.placed || order.status == OrderStatus.confirmed)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Center(
                        child: Text('Cancel Order',
                          style: AppTextStyles.button.copyWith(color: AppColors.error)),
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),

                if (order.status == OrderStatus.delivered)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text('Return / Exchange',
                          style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final OrderStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TrackingStep({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  String get _emoji {
    switch (status) {
      case OrderStatus.placed: return '📝';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.packed: return '📦';
      case OrderStatus.shipped: return '🚚';
      case OrderStatus.outForDelivery: return '🏃';
      case OrderStatus.delivered: return '🎉';
      default: return '•';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCompleted ? AppColors.primaryGradient : null,
                color: isCompleted ? null : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Center(
                child: Text(_emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted
                    ? AppColors.primary.withOpacity(0.5)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              OrderModel(
                id: '', userId: '', items: [], subtotal: 0, deliveryCharge: 0,
                discount: 0, totalAmount: 0,
                deliveryAddress: AddressModel(id: '', name: '', phone: '', addressLine1: '',
                    addressLine2: '', city: '', state: '', pincode: '', isDefault: false, type: ''),
                paymentMethod: '', paymentId: '', status: status,
                createdAt: DateTime.now(),
              ).statusLabel,
              style: AppTextStyles.body.copyWith(
                color: isCompleted
                    ? (isDark ? Colors.white : AppColors.textDark)
                    : (isDark ? Colors.white38 : Colors.grey.shade400),
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({required this.isDark, required this.title,
    required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.heading4.copyWith(
                  color: isDark ? Colors.white : AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

Widget _Row(String label, String value, bool isDark,
    {Color? valueColor, bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: isBold
          ? AppTextStyles.heading4
          : AppTextStyles.body.copyWith(color: isDark ? Colors.white60 : AppColors.textGrey)),
      Text(value, style: isBold
          ? AppTextStyles.heading3
          : AppTextStyles.body.copyWith(
              color: valueColor ?? (isDark ? Colors.white : AppColors.textDark),
              fontWeight: FontWeight.w600)),
    ],
  );
}
