// Support Management Screen - Edit Support Information

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../providers/support_provider.dart';

class SupportManagementScreen extends StatefulWidget {
  const SupportManagementScreen({super.key});

  @override
  State<SupportManagementScreen> createState() =>
      _SupportManagementScreenState();
}

class _SupportManagementScreenState extends State<SupportManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for shop information
  final _shopNameController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopEmailController = TextEditingController();
  final _shopWhatsappController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _workingHoursController = TextEditingController();

  // Controllers for developer information
  final _developerNameController = TextEditingController();
  final _developerEmailController = TextEditingController();
  final _developerWhatsappController = TextEditingController();

  // Controller for website
  final _websiteUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSupportInfo();
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopEmailController.dispose();
    _shopWhatsappController.dispose();
    _shopAddressController.dispose();
    _workingHoursController.dispose();
    _developerNameController.dispose();
    _developerEmailController.dispose();
    _developerWhatsappController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSupportInfo() async {
    final provider = context.read<SupportProvider>();
    await provider.fetchSupportInfo();

    if (mounted && provider.supportInfo != null) {
      final info = provider.supportInfo!;
      _shopNameController.text = info.shopName ?? '';
      _shopPhoneController.text = info.shopPhone ?? '';
      _shopEmailController.text = info.shopEmail ?? '';
      _shopWhatsappController.text = info.shopWhatsapp ?? '';
      _shopAddressController.text = info.shopAddress ?? '';
      _workingHoursController.text = info.workingHours ?? '';
      _developerNameController.text = info.developerName ?? '';
      _developerEmailController.text = info.developerEmail ?? '';
      _developerWhatsappController.text = info.developerWhatsapp ?? '';
      _websiteUrlController.text = info.websiteUrl ?? '';
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<SupportProvider>();

    final data = {
      'shopName': _shopNameController.text.trim().isEmpty
          ? null
          : _shopNameController.text.trim(),
      'shopPhone': _shopPhoneController.text.trim().isEmpty
          ? null
          : _shopPhoneController.text.trim(),
      'shopEmail': _shopEmailController.text.trim().isEmpty
          ? null
          : _shopEmailController.text.trim(),
      'shopWhatsapp': _shopWhatsappController.text.trim().isEmpty
          ? null
          : _shopWhatsappController.text.trim(),
      'shopAddress': _shopAddressController.text.trim().isEmpty
          ? null
          : _shopAddressController.text.trim(),
      'workingHours': _workingHoursController.text.trim().isEmpty
          ? null
          : _workingHoursController.text.trim(),
      'developerName': _developerNameController.text.trim().isEmpty
          ? null
          : _developerNameController.text.trim(),
      'developerEmail': _developerEmailController.text.trim().isEmpty
          ? null
          : _developerEmailController.text.trim(),
      'developerWhatsapp': _developerWhatsappController.text.trim().isEmpty
          ? null
          : _developerWhatsappController.text.trim(),
      'websiteUrl': _websiteUrlController.text.trim().isEmpty
          ? null
          : _websiteUrlController.text.trim(),
    };

    final success = await provider.updateSupportInfo(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Support Information',
      currentRoute: RouteNames.supportManagement,
      body: Consumer<SupportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.supportInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.supportInfo == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSupportInfo,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Information Section
                  const Text(
                    'Shop Contact Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This information will be displayed to customers in the Help & Support section.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _shopPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+91 1234567890',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _shopEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      hintText: 'shop@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _shopWhatsappController,
                    decoration: const InputDecoration(
                      labelText: 'Shop WhatsApp Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat),
                      hintText: '+911234567890 (with country code)',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _shopAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _workingHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Working Hours',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      hintText: 'Mon-Sat: 9:00 AM - 7:00 PM',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // Developer Information Section
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Developer Contact (Bug Reports)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customers can use this to report bugs or technical issues.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _developerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Developer Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _developerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Developer Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      hintText: 'dev@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _developerWhatsappController,
                    decoration: const InputDecoration(
                      labelText: 'Developer WhatsApp Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat),
                      hintText: '+911234567890 (with country code)',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),

                  // Additional Information
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _websiteUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Website URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                      hintText: 'https://example.com',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.startsWith('http://') &&
                            !value.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleSave,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        provider.isLoading ? 'Saving...' : 'Save Changes',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
