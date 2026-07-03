import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/runtime/app_runtime.dart';
import '../../auth/providers/auth_provider.dart';

final ordersProvider = StreamProvider<List<OrderModel>>((ref) async* {
  if (AppRuntime.isDemoMode) {
    final box = await Hive.openBox('orders');
    List<OrderModel> getList() => box.values
        .map((e) => OrderModel.fromMap(e['id'] ?? '', Map<String, dynamic>.from(e)))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield getList();
    await for (final _ in box.watch()) {
      yield getList();
    }
    return;
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield const <OrderModel>[];
    return;
  }
  yield* FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('My Orders 📦',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : AppColors.textDark)),
        centerTitle: false,
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? _EmptyOrders()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (ctx, i) => _OrderCard(order: orders[i], isDark: isDark)
                    .animate(delay: Duration(milliseconds: i * 80))
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;

  const _OrderCard({required this.order, required this.isDark});

  Color _statusColor(String statusLabel) {
    switch (statusLabel) {
      case 'Delivered': return AppColors.success;
      case 'Cancelled': return AppColors.error;
      case 'Shipped':
      case 'Out for delivery': return AppColors.info;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy');
    final statusColor = _statusColor(order.statusLabel);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: AppTextStyles.label.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textGrey)),
                    const SizedBox(height: 2),
                    Text(dateFormatter.format(order.createdAt),
                      style: AppTextStyles.bodySmall),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.statusLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items Preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
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
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
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

                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('+${order.items.length - 2} more items',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: AppTextStyles.caption),
                    Text(formatter.format(order.totalAmount),
                      style: AppTextStyles.heading4.copyWith(
                        color: isDark ? Colors.white : AppColors.textDark)),
                  ],
                ),
                const Spacer(),

                // Track Order button
                if (order.status != OrderStatus.cancelled &&
                    order.status != OrderStatus.delivered)
                  GestureDetector(
                    onTap: () => context.push('/orders/${order.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Track Order',
                        style: AppTextStyles.buttonSmall.copyWith(color: Colors.white)),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Buy Again',
                        style: AppTextStyles.buttonSmall.copyWith(color: AppColors.primary)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📦', style: TextStyle(fontSize: 80))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('No orders yet',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : AppColors.textDark))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text('Your order history will appear here',
            style: AppTextStyles.body.copyWith(color: AppColors.textGrey))
              .animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Text('Start Shopping 🛍️',
                style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ).animate(delay: 400.ms).fadeIn().scale(),
        ],
      ),
    );
  }
}
