import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/providers/wishlist_provider.dart';
import '../../../shared/providers/product_provider.dart';
import '../../../shared/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistIds = ref.watch(wishlistProvider);
    final allProductsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('My Wishlist ❤️',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : AppColors.textDark)),
        centerTitle: false,
        actions: [
          if (wishlistIds.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Wishlist'),
                    content: const Text('Remove all items from your wishlist?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          for (final id in List.from(wishlistIds)) {
                            ref.read(wishlistProvider.notifier).toggle(id);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Clear All',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: wishlistIds.isEmpty
          ? _EmptyWishlist()
          : allProductsAsync.when(
              data: (allProducts) {
                final wishlistProducts = allProducts
                    .where((p) => wishlistIds.contains(p.id))
                    .toList();

                if (wishlistProducts.isEmpty) return _EmptyWishlist();

                return Column(
                  children: [
                    // Count bar
                    Container(
                      color: AppColors.primary.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${wishlistProducts.length} item${wishlistProducts.length > 1 ? 's' : ''} saved',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Builder(
                        builder: (ctx) {
                          final screenWidth = MediaQuery.of(ctx).size.width;
                          final crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: wishlistProducts.length,
                            itemBuilder: (ctx, i) => ProductCard(
                              product: wishlistProducts[i],
                            ).animate(delay: Duration(milliseconds: i * 80))
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                          );
                        }
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💕', style: TextStyle(fontSize: 80))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.08, duration: 1200.ms),
          const SizedBox(height: 20),
          Text('Your wishlist is empty',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : AppColors.textDark))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text('Save items you love — tap ❤️ on any product',
            textAlign: TextAlign.center,
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
              child: Text('Explore Products 🛍️',
                style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ).animate(delay: 400.ms).fadeIn().scale(),
        ],
      ),
    );
  }
}
