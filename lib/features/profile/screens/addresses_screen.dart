import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/runtime/app_runtime.dart';
import '../../auth/providers/auth_provider.dart';

final addressesProvider = StreamProvider<List<AddressModel>>((ref) async* {
  if (AppRuntime.isDemoMode) {
    final box = await Hive.openBox('addresses');
    List<AddressModel> getList() => box.values
        .map((e) => AddressModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    yield getList();
    await for (final _ in box.watch()) {
      yield getList();
    }
    return;
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield const <AddressModel>[];
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('addresses')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => AddressModel.fromMap(doc.data())).toList());
});

class AddressesScreen extends ConsumerWidget {
  final bool selectionMode;

  const AddressesScreen({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          selectionMode ? 'Select Address' : 'Saved Addresses',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddressSheet(context, ref),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Address'),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) return const _EmptyAddresses();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _AddressCard(
                address: address,
                isDark: isDark,
                selectionMode: selectionMode,
                onSelect: () => context.pop(address),
                onEdit: () => _showAddressSheet(context, ref, address: address),
                onDelete: () => _deleteAddress(context, ref, address),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _deleteAddress(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) async {
    if (AppRuntime.isDemoMode) {
      final box = await Hive.openBox('addresses');
      await box.delete(address.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc(address.id)
        .delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted')),
    );
  }

  void _showAddressSheet(
    BuildContext context,
    WidgetRef ref, {
    AddressModel? address,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddressForm(address: address),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isDark;
  final bool selectionMode;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.selectionMode,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppColors.primary.withOpacity(0.5))
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: InkWell(
        onTap: selectionMode ? onSelect : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  address.type == 'work' ? Icons.business_outlined : Icons.home_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  address.type.toUpperCase(),
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Default',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.name,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.fullAddress,
              style: AppTextStyles.bodySmall.copyWith(height: 1.4),
            ),
            const SizedBox(height: 4),
            Text('Phone: ${address.phone}', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  final AddressModel? address;

  const _AddressForm({this.address});

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late String _type;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _nameCtrl = TextEditingController(text: address?.name ?? '');
    _phoneCtrl = TextEditingController(text: address?.phone ?? '');
    _line1Ctrl = TextEditingController(text: address?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: address?.addressLine2 ?? '');
    _cityCtrl = TextEditingController(text: address?.city ?? '');
    _stateCtrl = TextEditingController(text: address?.state ?? '');
    _pincodeCtrl = TextEditingController(text: address?.pincode ?? '');
    _type = address?.type ?? 'home';
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = widget.address?.id.isNotEmpty == true
        ? widget.address!.id
        : const Uuid().v4();

    final address = AddressModel(
      id: id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      isDefault: _isDefault,
      type: _type,
    );

    if (AppRuntime.isDemoMode) {
      final box = await Hive.openBox('addresses');
      if (_isDefault) {
        for (final key in box.keys) {
          final existingMap = Map<String, dynamic>.from(box.get(key));
          if (existingMap['isDefault'] == true && key != id) {
            existingMap['isDefault'] = false;
            await box.put(key, existingMap);
          }
        }
      }
      await box.put(id, address.toMap());
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');

    if (_isDefault) {
      final defaults = await collection.where('isDefault', isEqualTo: true).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in defaults.docs) {
        if (doc.id != id) batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }

    await collection.doc(id).set(address.toMap());

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address == null ? 'Add Address' : 'Edit Address',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Full name'),
              _field(_phoneCtrl, 'Phone', keyboardType: TextInputType.phone),
              _field(_line1Ctrl, 'Address line 1'),
              _field(_line2Ctrl, 'Address line 2', required: false),
              Row(
                children: [
                  Expanded(child: _field(_cityCtrl, 'City')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_stateCtrl, 'State')),
                ],
              ),
              _field(_pincodeCtrl, 'Pincode', keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'home', label: Text('Home'), icon: Icon(Icons.home_outlined)),
                  ButtonSegment(value: 'work', label: Text('Work'), icon: Icon(Icons.business_outlined)),
                  ButtonSegment(value: 'other', label: Text('Other'), icon: Icon(Icons.place_outlined)),
                ],
                selected: {_type},
                onSelectionChanged: (value) => setState(() => _type = value.first),
              ),
              SwitchListTile(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: const Text('Use as default address'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) return 'Required';
          return null;
        },
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No saved addresses yet. Add one to speed up checkout.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
        ),
      ),
    );
  }
}
