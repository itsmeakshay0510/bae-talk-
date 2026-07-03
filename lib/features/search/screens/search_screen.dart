import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/providers/product_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/category_chip.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  String _selectedCategory = 'All';
  String _sortBy = 'popular';
  RangeValues _priceRange = const RangeValues(0, 5000);
  bool _showFilters = false;

  final List<String> _categories = ['All', 'Women', 'Men', 'Kids', 'Ethnic', 'Western', 'Accessories'];
  final List<String> _recentSearches = ['Kurti', 'Jeans', 'Saree', 'T-Shirt', 'Dress'];
  final List<String> _trendingSearches = ['Summer dress', 'Ethnic wear', 'Sneakers', 'Handbag', 'Kurta set'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchResults = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _focusNode.hasFocus ? AppColors.primary
                              : isDark ? AppColors.borderDark : AppColors.border,
                          width: _focusNode.hasFocus ? 1.5 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                        style: AppTextStyles.body.copyWith(
                            color: isDark ? Colors.white : AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Search dresses, tops, shoes...',
                          hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _showFilters ? AppColors.primaryGradient : null,
                        color: _showFilters ? null : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.tune_rounded,
                        color: _showFilters ? Colors.white : AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Panel
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showFilters
                  ? Container(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sort
                          Text('Sort By', style: AppTextStyles.heading4.copyWith(
                              color: isDark ? Colors.white : AppColors.textDark)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              _FilterChip(label: 'Popular', value: 'popular',
                                selected: _sortBy == 'popular', isDark: isDark,
                                onTap: () => setState(() => _sortBy = 'popular')),
                              _FilterChip(label: 'Price: Low', value: 'price_asc',
                                selected: _sortBy == 'price_asc', isDark: isDark,
                                onTap: () => setState(() => _sortBy = 'price_asc')),
                              _FilterChip(label: 'Price: High', value: 'price_desc',
                                selected: _sortBy == 'price_desc', isDark: isDark,
                                onTap: () => setState(() => _sortBy = 'price_desc')),
                              _FilterChip(label: 'Newest', value: 'newest',
                                selected: _sortBy == 'newest', isDark: isDark,
                                onTap: () => setState(() => _sortBy = 'newest')),
                              _FilterChip(label: 'Rating', value: 'rating',
                                selected: _sortBy == 'rating', isDark: isDark,
                                onTap: () => setState(() => _sortBy = 'rating')),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Price Range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price Range', style: AppTextStyles.heading4.copyWith(
                                  color: isDark ? Colors.white : AppColors.textDark)),
                              Text('₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                                style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              thumbColor: AppColors.primary,
                              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0, max: 5000,
                              onChanged: (v) => setState(() => _priceRange = v),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Category Chips
            Container(
              height: 52,
              color: isDark ? AppColors.surfaceDark : Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) => CategoryChip(
                  label: _categories[i],
                  isSelected: _selectedCategory == _categories[i],
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                ),
              ),
            ),

            // Body
            Expanded(
              child: _query.isEmpty
                  ? _EmptySearch(
                      recent: _recentSearches,
                      trending: _trendingSearches,
                      isDark: isDark,
                      onTap: (s) {
                        _searchCtrl.text = s;
                        setState(() => _query = s.toLowerCase());
                      },
                    )
                  : searchResults.when(
                      data: (results) {
                        if (results.isEmpty) return _NoResults(query: _query);
                        final screenWidth = MediaQuery.of(context).size.width;
                        final crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: results.length,
                          itemBuilder: (ctx, i) => ProductCard(product: results[i])
                              .animate(delay: Duration(milliseconds: i * 60))
                              .fadeIn().scale(begin: const Offset(0.9, 0.9)),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(
                          color: AppColors.primary)),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.value,
    required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : (isDark ? Colors.white24 : Colors.grey.shade300),
          ),
        ),
        child: Text(label, style: AppTextStyles.caption.copyWith(
          color: selected ? Colors.white : (isDark ? Colors.white60 : AppColors.textGrey),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        )),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final List<String> recent;
  final List<String> trending;
  final bool isDark;
  final void Function(String) onTap;

  const _EmptySearch({required this.recent, required this.trending,
    required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Searches', style: AppTextStyles.heading4.copyWith(
              color: isDark ? Colors.white : AppColors.textDark))
              .animate().fadeIn(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: recent.map((s) => GestureDetector(
              onTap: () => onTap(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(s, style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textDark)),
                  ],
                ),
              ),
            )).toList(),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 28),
          Text('Trending 🔥', style: AppTextStyles.heading4.copyWith(
              color: isDark ? Colors.white : AppColors.textDark))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 12),
          ...trending.asMap().entries.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(child: Text('${e.key + 1}',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700))),
            ),
            title: Text(e.value, style: AppTextStyles.body.copyWith(
                color: isDark ? Colors.white : AppColors.textDark)),
            trailing: Icon(Icons.north_west_rounded, size: 16, color: Colors.grey.shade400),
            onTap: () => onTap(e.value),
          ).animate(delay: Duration(milliseconds: 200 + e.key * 80)).fadeIn().slideX(begin: 0.2, end: 0)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('No results for "$query"',
            style: AppTextStyles.heading4.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : AppColors.textDark))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text('Try different keywords or browse categories',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textGrey))
              .animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}
