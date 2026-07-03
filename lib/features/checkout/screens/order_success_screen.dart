import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Animation
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.success.withOpacity(0.2), Colors.transparent],
                      ),
                    ),
                    child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 80)),
                    ),
                  )
                      .animate()
                      .scale(duration: 700.ms, curve: Curves.elasticOut)
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 1, end: 1.05, duration: 1000.ms),

                  const SizedBox(height: 32),

                  Text('Order Placed! 🎊',
                    style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 32))
                      .animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Your fashion is on its way!\nExpected delivery in 5-7 business days.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(color: Colors.white60, height: 1.5))
                      .animate(delay: 500.ms).fadeIn(),

                  const SizedBox(height: 48),

                  // Features Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FeaturePill(emoji: '📦', label: 'Order\nPlaced'),
                      _Arrow(),
                      _FeaturePill(emoji: '🚚', label: 'Being\nPrepared'),
                      _Arrow(),
                      _FeaturePill(emoji: '✅', label: 'On the\nWay'),
                    ],
                  ).animate(delay: 700.ms).fadeIn(),

                  const SizedBox(height: 56),

                  // Track Order Button
                  GestureDetector(
                    onTap: () => context.go('/orders'),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Center(
                        child: Text('Track My Order 📦',
                          style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ).animate(delay: 900.ms).fadeIn().scale(),

                  const SizedBox(height: 16),

                  // Continue Shopping
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Text('Continue Shopping',
                          style: AppTextStyles.button.copyWith(color: Colors.white70)),
                      ),
                    ),
                  ).animate(delay: 1000.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String emoji;
  final String label;
  const _FeaturePill({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: Colors.white60, height: 1.3)),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 20);
  }
}
