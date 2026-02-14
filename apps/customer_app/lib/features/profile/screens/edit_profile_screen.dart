import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';

/// Screen for editing user profile
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();

    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _stateController = TextEditingController(text: profile?.state ?? '');
    _pincodeController = TextEditingController(text: profile?.pincode ?? '');
    _landmarkController = TextEditingController(text: profile?.landmark ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final success = await profileProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : null,
      state: _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : null,
      pincode: _pincodeController.text.trim().isNotEmpty
          ? _pincodeController.text.trim()
          : null,
      landmark: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              return provider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveProfile,
                    );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '9876543210',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.trim())) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Address Section
            Text(
              'Delivery Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This address will be used by default when placing orders',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
                hintText: '123 Main St, Apt 4B',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_drop),
                hintText: '400001',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
                    return 'Pincode must be 6 digits';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'Landmark (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
                hintText: 'Near City Mall',
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Save your delivery address here to skip entering it every time you place an order!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
