import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/providers/nav_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.2), blurRadius: 16)],
                            ),
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.3),
                              child: Text(
                                (user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0]
                                    : user?.email?[0] ?? 'U').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 32,
                                  fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 26, height: 26,
                              decoration: const BoxDecoration(
                                color: AppColors.accent, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? 'Fashion Lover',
                        style: AppTextStyles.heading3.copyWith(color: Colors.white))
                          .animate(delay: 200.ms).fadeIn(),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70))
                          .animate(delay: 300.ms).fadeIn(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats Row
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      _StatItem(label: 'Orders', value: '12', emoji: '📦'),
                      _Divider(),
                      _StatItem(label: 'Wishlist', value: '34', emoji: '❤️'),
                      _Divider(),
                      _StatItem(label: 'Points', value: '250', emoji: '⭐'),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _MenuSection(
                        isDark: isDark,
                        title: 'Shopping',
                        items: [
                          _MenuItem(
                            icon: Icons.shopping_bag_outlined,
                            label: 'My Orders',
                            badge: null,
                            onTap: () => context.push('/orders'),
                            color: AppColors.primary,
                          ),
                          _MenuItem(
                            icon: Icons.favorite_border_rounded,
                            label: 'Wishlist',
                            onTap: () => ref.read(currentNavIndexProvider.notifier).state = 2,
                            color: AppColors.error,
                          ),
                          _MenuItem(
                            icon: Icons.local_offer_outlined,
                            label: 'My Coupons',
                            badge: '3',
                            onTap: () {},
                            color: AppColors.accent,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _MenuSection(
                        isDark: isDark,
                        title: 'Account',
                        items: [
                          _MenuItem(
                            icon: Icons.location_on_outlined,
                            label: 'Saved Addresses',
                            onTap: () => context.push('/addresses'),
                            color: AppColors.info,
                          ),
                          _MenuItem(
                            icon: Icons.payment_outlined,
                            label: 'Payment Methods',
                            onTap: () {},
                            color: AppColors.success,
                          ),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () {},
                            color: AppColors.warning,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _MenuSection(
                        isDark: isDark,
                        title: 'More',
                        items: [
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            onTap: () {},
                            color: AppColors.primary,
                          ),
                          _MenuItem(
                            icon: Icons.star_outline_rounded,
                            label: 'Rate Bae Talk',
                            onTap: () {},
                            color: AppColors.accentGold,
                          ),
                          _MenuItem(
                            icon: Icons.share_outlined,
                            label: 'Share App',
                            onTap: () {},
                            color: AppColors.info,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Logout
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context, ref),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.12),
                                  shape: BoxShape.circle),
                                child: const Icon(Icons.logout_rounded,
                                  color: AppColors.error, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Text('Logout', style: AppTextStyles.body.copyWith(
                                color: AppColors.error, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Version
                      Text('Bae Talk v1.0.0 • Made with ❤️ in India',
                        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade400)),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.isDark, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              )),
          ),
          ...items.map((item) => InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item.label,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w500)),
                  ),
                  if (item.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(item.badge!,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white24 : Colors.grey.shade300),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _StatItem({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.heading3),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 50,
      color: Colors.grey.shade200,
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.badge,
  });
}
