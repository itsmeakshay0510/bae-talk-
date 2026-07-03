import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import 'package:intl/intl.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final double? width;

  const ProductCard({super.key, required this.product, this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(product.id);
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: width,
        margin: width != null ? const EdgeInsets.only(right: 12) : null,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.images[0],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            memCacheWidth: 320,
                            placeholder: (_, __) => Container(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              child: const Center(
                                child: Icon(Icons.image_outlined, color: Colors.grey),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              child: const Center(
                                child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 32),
                              ),
                            ),
                          )
                        : Container(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 32),
                            ),
                          ),
                  ),

                  // Discount Badge
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.saleBadge,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discountPercent.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black54 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWishlisted ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Free Delivery Tag
                  if (product.hasFreeDelivery)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text('🚚 FREE Delivery',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 9,
                              fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                            )),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textDark,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        formatter.format(product.price),
                        style: AppTextStyles.heading4.copyWith(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                      if (product.discountPercent > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          formatter.format(product.originalPrice),
                          style: AppTextStyles.priceOld.copyWith(fontSize: 11),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.accentGold),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' (${product.reviewCount})',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
