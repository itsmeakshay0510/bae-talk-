import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/providers/product_provider.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/providers/wishlist_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  final PageController _imageController = PageController();

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _addToCart(ProductModel product) {
    if (_selectedSize == null && product.sizes.isNotEmpty) {
      Fluttertoast.showToast(msg: 'Please select a size', backgroundColor: AppColors.error);
      return;
    }
    if (_selectedColor == null && product.colors.isNotEmpty) {
      Fluttertoast.showToast(msg: 'Please select a color', backgroundColor: AppColors.error);
      return;
    }
    ref.read(cartProvider.notifier).addItem(
      product,
      _selectedSize ?? 'Free Size',
      _selectedColor ?? 'Default',
    );
    Fluttertoast.showToast(
      msg: '✅ Added to cart!',
      backgroundColor: AppColors.success,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final wishlist = ref.watch(wishlistProvider);

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }
        final isWishlisted = wishlist.contains(product.id);
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
              body: CustomScrollView(
                slivers: [
                  // Image Gallery App Bar
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black54 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : AppColors.textDark, size: 18),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black54 : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? AppColors.primary : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          if (product.images.isNotEmpty)
                            PageView.builder(
                              controller: _imageController,
                              itemCount: product.images.length,
                              onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                              itemBuilder: (ctx, i) => CachedNetworkImage(
                                imageUrl: product.images[i],
                                fit: BoxFit.cover,
                                memCacheWidth: 720,
                                placeholder: (_, __) => Container(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                              ),
                            )
                          else
                            Container(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              child: const Center(
                                child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey)),
                            ),

                          // Image indicator dots
                          if (product.images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(product.images.length, (i) => Container(
                                  width: i == _selectedImageIndex ? 20 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i == _selectedImageIndex
                                        ? AppColors.primary : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                )),
                              ),
                            ),

                          // Discount badge
                          if (product.discountPercent > 0)
                            Positioned(
                              top: 70,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.saleBadge,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${product.discountPercent.toInt()}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 13,
                                    fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                                  )),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Product Info
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seller & Rating Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(product.sellerName,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ),
                                const Spacer(),
                                const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 16),
                                const SizedBox(width: 3),
                                Text('${product.rating}',
                                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
                                Text(' (${product.reviewCount} reviews)',
                                  style: AppTextStyles.caption),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Product Name
                            Text(product.name,
                              style: AppTextStyles.heading2.copyWith(
                                color: isDark ? Colors.white : AppColors.textDark, height: 1.3))
                                .animate().fadeIn().slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 16),

                            // Price Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatter.format(product.price),
                                  style: AppTextStyles.display.copyWith(
                                    color: isDark ? Colors.white : AppColors.textDark, fontSize: 28)),
                                const SizedBox(width: 10),
                                if (product.discountPercent > 0) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(formatter.format(product.originalPrice),
                                      style: AppTextStyles.priceOld.copyWith(fontSize: 16)),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Save ${formatter.format(product.discountAmount)}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.success, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Free delivery & return
                            Row(
                              children: [
                                if (product.hasFreeDelivery) ...[
                                  const Icon(Icons.local_shipping_outlined,
                                    color: AppColors.success, size: 16),
                                  const SizedBox(width: 4),
                                  Text('FREE Delivery',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
                                  const SizedBox(width: 16),
                                ],
                                  const Icon(Icons.refresh_rounded,
                                    color: AppColors.info, size: 16),
                                  const SizedBox(width: 4),
                                  Text('7 Days Return',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.info)),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 20),

                            // Size Selector
                            if (product.sizes.isNotEmpty) ...[
                              Row(
                                children: [
                                  Text('Select Size', style: AppTextStyles.heading4
                                      .copyWith(color: isDark ? Colors.white : AppColors.textDark)),
                                  const Spacer(),
                                  Text('Size Guide',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    )),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                children: product.sizes.map((size) => GestureDetector(
                                  onTap: () => setState(() => _selectedSize = size),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _selectedSize == size ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedSize == size ? AppColors.primary : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(size,
                                        style: AppTextStyles.label.copyWith(
                                          color: _selectedSize == size ? Colors.white
                                              : isDark ? Colors.white70 : AppColors.textDark,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    ),
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Color Selector
                            if (product.colors.isNotEmpty) ...[
                              Text('Select Color', style: AppTextStyles.heading4
                                  .copyWith(color: isDark ? Colors.white : AppColors.textDark)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                children: product.colors.map((color) {
                                  final isSelected = _selectedColor == color;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColor = color),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(color,
                                        style: AppTextStyles.label.copyWith(
                                          color: isSelected ? AppColors.primary
                                              : isDark ? Colors.white70 : AppColors.textGrey,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        )),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            const Divider(height: 1),
                            const SizedBox(height: 20),

                            // Description
                            Text('Description', style: AppTextStyles.heading4
                                .copyWith(color: isDark ? Colors.white : AppColors.textDark)),
                            const SizedBox(height: 8),
                            Text(product.description,
                              style: AppTextStyles.body.copyWith(
                                color: isDark ? Colors.white60 : AppColors.textGrey,
                                height: 1.6,
                              )),

                            const SizedBox(height: 100), // Bottom padding for button
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Action Buttons
              bottomNavigationBar: Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
                  ],
                ),
                child: Row(
                  children: [
                    // Add to Cart
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Center(
                            child: Text('Add to Cart',
                              style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Buy Now
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          _addToCart(product);
                          context.push('/checkout');
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 16, offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text('Buy Now ⚡',
                              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
