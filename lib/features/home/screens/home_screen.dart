import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/providers/product_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/category_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _bannerController = PageController();
  String _selectedCategory = 'All';
  int _bannerIndex = 0;

  final List<BannerData> _banners = [
    BannerData(
      title: 'Summer Sale 🌞',
      subtitle: 'Up to 70% OFF on all ethnic wear',
      gradient: [const Color(0xFFE91E8C), const Color(0xFF9C27B0)],
      emoji: '👗',
    ),
    BannerData(
      title: 'New Arrivals ✨',
      subtitle: 'Fresh styles just dropped',
      gradient: [const Color(0xFF3F51B5), const Color(0xFF00BCD4)],
      emoji: '🆕',
    ),
    BannerData(
      title: 'Flash Deal ⚡',
      subtitle: 'Extra 20% OFF — Today only!',
      gradient: [const Color(0xFFFF6B35), const Color(0xFFFF9800)],
      emoji: '💥',
    ),
  ];

  final List<String> _categories = ['All', 'Women', 'Men', 'Kids', 'Ethnic', 'Western', 'Accessories'];

  @override
  void initState() {
    super.initState();
    // Auto-scroll banner
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      if (_bannerController.hasClients) {
        _bannerIndex = (_bannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _bannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                  child: Text('Bae Talk',
                    style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                  color: isDark ? Colors.white70 : AppColors.textDark),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    onTap: () => context.go('/home', extra: 1),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded,
                            color: isDark ? Colors.white38 : Colors.grey.shade400),
                          const SizedBox(width: 10),
                          Text('Search dresses, tops, shoes...',
                            style: AppTextStyles.body.copyWith(
                              color: isDark ? Colors.white38 : Colors.grey.shade400)),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // Banner Carousel
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _banners.length,
                    itemBuilder: (ctx, i) => _BannerCard(data: _banners[i]),
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 12),

                // Banner Indicator
                Center(
                  child: SmoothPageIndicator(
                    controller: _bannerController,
                    count: _banners.length,
                    effect: const WormEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: AppColors.primary,
                      dotColor: Colors.grey,
                      spacing: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) => CategoryChip(
                      label: _categories[i],
                      isSelected: _selectedCategory == _categories[i],
                      onTap: () => setState(() => _selectedCategory = _categories[i]),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Trending Now
                SectionHeader(
                  title: 'Trending Now 🔥',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: Consumer(
                    builder: (ctx, ref, _) {
                      final products = ref.watch(trendingProductsProvider);
                      return products.when(
                        data: (data) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.length,
                          itemBuilder: (ctx, i) => ProductCard(
                            product: data[i],
                            width: 160,
                          ).animate(delay: Duration(milliseconds: i * 80))
                              .fadeIn().slideX(begin: 0.2, end: 0),
                        ),
                        loading: () => _ShimmerList(),
                        error: (e, _) => const Center(child: Text('Failed to load')),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Flash Deals Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Text('⚡', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Flash Deals',
                              style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                            Text('Ends in 02:45:30',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Shop Now',
                            style: AppTextStyles.buttonSmall.copyWith(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                const SizedBox(height: 24),

                // New Arrivals
                SectionHeader(title: 'New Arrivals ✨', onSeeAll: () {}),
                const SizedBox(height: 12),
                Consumer(
                  builder: (ctx, ref, _) {
                    final products = ref.watch(newArrivalsProvider);
                    return products.when(
                      data: (data) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: data.length > 6 ? 6 : data.length,
                          itemBuilder: (ctx, i) => ProductCard(
                            product: data[i],
                          ).animate(delay: Duration(milliseconds: i * 100))
                              .fadeIn().scale(begin: const Offset(0.9, 0.9)),
                        );
                      },
                      loading: () => _GridShimmer(),
                      error: (e, _) => const SizedBox(),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String emoji;
  BannerData({required this.title, required this.subtitle, required this.gradient, required this.emoji});
}

class _BannerCard extends StatelessWidget {
  final BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: data.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradient[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern circles
          Positioned(right: -20, top: -20,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1)))),
          Positioned(right: 30, bottom: -30,
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1)))),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.title,
                        style: AppTextStyles.heading2.copyWith(color: Colors.white, fontSize: 20)),
                      const SizedBox(height: 6),
                      Text(data.subtitle,
                        style: AppTextStyles.body.copyWith(color: Colors.white70)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Shop Now',
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: data.gradient[0])),
                      ),
                    ],
                  ),
                ),
                Text(data.emoji, style: const TextStyle(fontSize: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 160,
          height: 240,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.65,
      ),
      itemCount: crossAxisCount * 2,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
