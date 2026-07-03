import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/runtime/app_runtime.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  AddressModel? _selectedAddress;
  String _paymentMethod = 'razorpay';

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _loadDefaultAddress();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _loadDefaultAddress() async {
    if (AppRuntime.isDemoMode) {
      final box = await Hive.openBox('addresses');
      final defaultAddress = box.values
          .map((e) => AddressModel.fromMap(Map<String, dynamic>.from(e)))
          .firstWhere((a) => a.isDefault, orElse: () => box.values.isEmpty 
              ? AddressModel(id: '', name: '', phone: '', addressLine1: '', addressLine2: '', city: '', state: '', pincode: '', isDefault: false, type: '')
              : AddressModel.fromMap(Map<String, dynamic>.from(box.values.first)));
      
      if (defaultAddress.id.isNotEmpty && mounted) {
        setState(() => _selectedAddress = defaultAddress);
      }
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();
    if (doc.docs.isNotEmpty && mounted) {
      setState(() => _selectedAddress = AddressModel.fromMap(doc.docs.first.data()));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _createOrder(response.paymentId ?? '');
    if (mounted) context.go('/order-success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  Future<void> _createOrder(String paymentId) async {
    if (_selectedAddress == null) return;

    final cartItems = ref.read(cartProvider);
    final cartTotal = ref.read(cartTotalProvider);
    final deliveryCharge = cartTotal >= 499 ? 0.0 : 49.0;

    final order = OrderModel(
      id: const Uuid().v4(),
      userId: AppRuntime.isDemoMode ? 'demo-user' : (ref.read(currentUserProvider)?.uid ?? ''),
      items: cartItems.map((item) => OrderItem(
        productId: item.productId,
        name: item.name,
        image: item.image,
        price: item.price,
        quantity: item.quantity,
        size: item.size,
        color: item.color,
      )).toList(),
      subtotal: cartTotal,
      deliveryCharge: deliveryCharge,
      discount: ref.read(cartSavingsProvider),
      totalAmount: cartTotal + deliveryCharge,
      deliveryAddress: _selectedAddress!,
      paymentMethod: _paymentMethod,
      paymentId: paymentId,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
    );

    if (AppRuntime.isDemoMode) {
      final box = await Hive.openBox('orders');
      await box.put(order.id, order.toMap());
    } else {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .set(order.toFirestore());
    }

    ref.read(cartProvider.notifier).clearCart();
  }

  void _selectAddress() async {
    final result = await context.push<AddressModel?>('/addresses?selectionMode=true');
    if (result != null && mounted) {
      setState(() => _selectedAddress = result);
    }
  }

  void _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    if (_paymentMethod == 'cod') {
      try {
        await _createOrder('cod');
        if (mounted) context.go('/order-success');
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place order: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    } else {
      final cartTotal = ref.read(cartTotalProvider);
      final deliveryCharge = cartTotal >= 499 ? 0.0 : 49.0;
      final grandTotal = (cartTotal + deliveryCharge) * 100; // Razorpay uses paise

      var options = {
        'key': 'YOUR_RAZORPAY_KEY', // Replace with your actual Razorpay key
        'amount': grandTotal.toInt(),
        'name': 'Bae Talk',
        'description': 'Fashion Order Payment',
        'prefill': {
          'contact': '9999999999',
          'email': ref.read(currentUserProvider)?.email ?? '',
        },
        'theme': {'color': '#E91E8C'},
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment initiation failed: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartSavings = ref.watch(cartSavingsProvider);
    final deliveryCharge = cartTotal >= 499 ? 0.0 : 49.0;
    final grandTotal = cartTotal + deliveryCharge;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Checkout',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Delivery Address',
                        style: AppTextStyles.heading4.copyWith(
                          color: isDark ? Colors.white : AppColors.textDark)),
                      const Spacer(),
                      TextButton(
                        onPressed: _selectAddress,
                        child: Text('Change',
                          style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  if (_selectedAddress != null) ...[
                    const SizedBox(height: 8),
                    Text(_selectedAddress!.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(_selectedAddress!.fullAddress,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? Colors.white60 : AppColors.textGrey, height: 1.4)),
                    Text(_selectedAddress!.phone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.white60 : AppColors.textGrey)),
                  ] else ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectAddress,
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Add Delivery Address',
                            style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            // Order Items
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Order Items (${cartItems.length})',
                        style: AppTextStyles.heading4.copyWith(
                          color: isDark ? Colors.white : AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  color: isDark ? Colors.white : AppColors.textDark)),
                              Text('${item.size} • ${item.color} • Qty: ${item.quantity}',
                                style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Text(formatter.format(item.totalPrice),
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            // Payment Method
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Payment Method',
                        style: AppTextStyles.heading4.copyWith(
                          color: isDark ? Colors.white : AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    icon: '💳',
                    label: 'Razorpay (UPI / Cards / Wallets)',
                    value: 'razorpay',
                    groupValue: _paymentMethod,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  _PaymentOption(
                    icon: '💵',
                    label: 'Cash on Delivery',
                    value: 'cod',
                    groupValue: _paymentMethod,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            // Price Breakdown
            _SectionCard(
              isDark: isDark,
              child: Column(
                children: [
                  _PriceRow('Subtotal', formatter.format(cartTotal), isDark),
                  const SizedBox(height: 8),
                  _PriceRow('Delivery', deliveryCharge == 0 ? 'FREE' : formatter.format(deliveryCharge),
                    isDark, valueColor: deliveryCharge == 0 ? AppColors.success : null),
                  if (cartSavings > 0) ...[
                    const SizedBox(height: 8),
                    _PriceRow('Savings', '-${formatter.format(cartSavings)}',
                      isDark, valueColor: AppColors.success),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _PriceRow('Total Amount', formatter.format(grandTotal), isDark, isBold: true),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Place Order Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
            blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.body.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textGrey)),
                Text(formatter.format(grandTotal),
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? Colors.white : AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isProcessing ? null : _placeOrder,
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
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          _paymentMethod == 'cod'
                              ? 'Place Order (COD) 📦'
                              : 'Pay ${formatter.format(grandTotal)} ⚡',
                          style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String groupValue;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.icon, required this.label, required this.value,
    required this.groupValue, required this.isDark, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
            style: AppTextStyles.body.copyWith(
              color: isDark ? Colors.white : AppColors.textDark))),
        ],
      ),
    );
  }
}

Widget _PriceRow(String label, String value, bool isDark,
    {Color? valueColor, bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: isBold
          ? AppTextStyles.heading4
          : AppTextStyles.body.copyWith(
              color: isDark ? Colors.white60 : AppColors.textGrey)),
      Text(value, style: isBold
          ? AppTextStyles.heading3
          : AppTextStyles.body.copyWith(
              color: valueColor ?? (isDark ? Colors.white : AppColors.textDark),
              fontWeight: FontWeight.w600)),
    ],
  );
}
