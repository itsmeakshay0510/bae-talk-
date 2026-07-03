import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/models/cart_item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartSavings = ref.watch(cartSavingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final deliveryCharge = cartTotal >= 499 ? 0.0 : 49.0;
    final grandTotal = cartTotal + deliveryCharge;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 750;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 750),
        decoration: isDesktop ? BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ) : null,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('My Cart (${cartItems.length})',
              style: AppTextStyles.heading3.copyWith(
                color: isDark ? Colors.white : AppColors.textDark)),
            centerTitle: false,
            actions: [
              if (cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                  child: Text('Clear All',
                    style: AppTextStyles.label.copyWith(color: AppColors.error)),
                ),
            ],
          ),
          body: cartItems.isEmpty
              ? _EmptyCart()
              : Column(
                  children: [
                    // Savings Banner
                    if (cartSavings > 0)
                      Container(
                        color: AppColors.success.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.savings_outlined, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'You\'re saving ${formatter.format(cartSavings)} on this order! 🎉',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success,
                                fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
    
                    // Cart Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) => _CartItemCard(
                          item: cartItems[i],
                          formatter: formatter,
                        ).animate(delay: Duration(milliseconds: i * 80))
                            .fadeIn().slideX(begin: 0.2, end: 0),
                      ),
                    ),
    
                    // Price Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20,
                            offset: const Offset(0, -5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Promo Code
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_outlined,
                                  color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Apply Promo Code',
                                    style: AppTextStyles.body.copyWith(
                                      color: isDark ? Colors.white60 : AppColors.textGrey)),
                                ),
                                Icon(Icons.chevron_right,
                                  color: isDark ? Colors.white38 : Colors.grey.shade400),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
    
                          // Price Breakdown
                          _PriceRow(label: 'Subtotal', value: formatter.format(cartTotal), isDark: isDark),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Delivery',
                            value: deliveryCharge == 0 ? 'FREE' : formatter.format(deliveryCharge),
                            valueColor: deliveryCharge == 0 ? AppColors.success : null,
                            isDark: isDark,
                          ),
                          if (cartSavings > 0) ...[
                            const SizedBox(height: 8),
                            _PriceRow(
                              label: 'Discount',
                              value: '-${formatter.format(cartSavings)}',
                              valueColor: AppColors.success,
                              isDark: isDark,
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Total Amount',
                            value: formatter.format(grandTotal),
                            isBold: true,
                            isDark: isDark,
                          ),
    
                          const SizedBox(height: 16),
    
                          // Checkout Button
                          GestureDetector(
                            onTap: () => context.push('/checkout'),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20, offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text('Proceed to Checkout →',
                                  style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItemModel item;
  final NumberFormat formatter;

  const _CartItemCard({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => ref.read(cartProvider.notifier)
                .removeItem(item.productId, item.size, item.color),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Remove',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                memCacheWidth: 180,
                errorWidget: (_, __, ___) => Container(
                  width: 90, height: 90,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w500, height: 1.3)),
                  const SizedBox(height: 4),
                  Text('${item.size} • ${item.color}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? Colors.white38 : Colors.grey.shade400)),
                  const SizedBox(height: 8),
                  Text(formatter.format(item.totalPrice),
                    style: AppTextStyles.heading4.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark)),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => ref.read(cartProvider.notifier)
                            .updateQuantity(item.productId, item.size, item.color, item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}',
                          style: AppTextStyles.heading4.copyWith(
                            color: isDark ? Colors.white : AppColors.textDark, fontSize: 15)),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => ref.read(cartProvider.notifier)
                            .updateQuantity(item.productId, item.size, item.color, item.quantity + 1),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _QtyButton({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: isPrimary
              ? const BorderRadius.only(topRight: Radius.circular(9), bottomRight: Radius.circular(9))
              : const BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
        ),
        child: Icon(icon, size: 16,
          color: isPrimary ? Colors.white : AppColors.textGrey),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final bool isDark;

  const _PriceRow({
    required this.label, required this.value, required this.isDark,
    this.valueColor, this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold
            ? AppTextStyles.heading4.copyWith(color: isDark ? Colors.white : AppColors.textDark)
            : AppTextStyles.body.copyWith(color: isDark ? Colors.white60 : AppColors.textGrey)),
        Text(value, style: isBold
            ? AppTextStyles.heading3.copyWith(color: isDark ? Colors.white : AppColors.textDark)
            : AppTextStyles.body.copyWith(
                color: valueColor ?? (isDark ? Colors.white : AppColors.textDark),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('Your cart is empty',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : AppColors.textDark))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text('Add items to get started',
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
