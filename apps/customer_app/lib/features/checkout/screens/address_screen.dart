import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_shared/models/order.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/checkout_provider.dart';
import '../../../routing/route_names.dart';

/// Screen for entering delivery address during checkout
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  void _loadSavedAddress() {
    final checkoutProvider = Provider.of<CheckoutProvider>(
      context,
      listen: false,
    );
    final savedAddress = checkoutProvider.deliveryAddress;

    if (savedAddress != null) {
      _nameController.text = savedAddress.name;
      _phoneController.text = savedAddress.phone;
      _line1Controller.text = savedAddress.line1;
      _line2Controller.text = savedAddress.line2 ?? '';
      _cityController.text = savedAddress.city;
      _stateController.text = savedAddress.state;
      _pincodeController.text = savedAddress.pincode;
    } else {
      // Auto-fill from profile if no saved address in checkout state
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    // Wait for frame to ensure context is available and providers are ready
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    
    // Ensure profile is loaded
    if (profileProvider.profile == null) {
      await profileProvider.fetchProfile();
    }
    
    if (!mounted) return;

    final profile = profileProvider.profile;
    if (profile != null) {
      setState(() {
        if (_nameController.text.isEmpty) _nameController.text = profile.name;
        if (_phoneController.text.isEmpty && profile.phone != null) {
          _phoneController.text = profile.phone!;
        }
        if (_line1Controller.text.isEmpty && profile.address != null) {
          _line1Controller.text = profile.address!;
        }
        // Map landmark to line 2 if available
        if (_line2Controller.text.isEmpty && profile.landmark != null) {
          _line2Controller.text = profile.landmark!;
        }
        if (_cityController.text.isEmpty && profile.city != null) {
          _cityController.text = profile.city!;
        }
        if (_stateController.text.isEmpty && profile.state != null) {
          _stateController.text = profile.state!;
        }
        if (_pincodeController.text.isEmpty && profile.pincode != null) {
          _pincodeController.text = profile.pincode!;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? _validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(value.trim())) {
      return 'Pincode must be 6 digits';
    }
    return null;
  }

  Future<void> _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      final checkoutProvider = Provider.of<CheckoutProvider>(
        context,
        listen: false,
      );

      final address = DeliveryAddress(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim().isEmpty
            ? null
            : _line2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      // Validate address using provider
      if (!checkoutProvider.validateAddress(address)) {
        if (checkoutProvider.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(checkoutProvider.error!)));
        }
        return;
      }

      // ---------------------------------------------------------
      // AUTO-SAVE: Update profile with new address details
      // ---------------------------------------------------------
      _updateProfileIfChanged();

      // Save address to checkout provider
      checkoutProvider.setDeliveryAddress(address);

      // ---------------------------------------------------------
      // AUTO-SAVE: Update profile with new address details
      // ---------------------------------------------------------
      _updateProfileIfChanged();

      // Place order
      final success = await checkoutProvider.placeOrder(address: address);

      if (success && mounted) {
        // Navigate to confirmation screen
        context.go(RouteNames.orderConfirmation);
      } else if (mounted && checkoutProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkoutProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfileIfChanged() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.profile;
    
    // If profile is not loaded, we can't compare, so we skip update or maybe fetch it?
    // Safer to skip if null to avoid overwriting with potentially empty data if fetch failed?
    // Or should we try to update anyway if we have valid data?
    // Let's only update if we have a profile to compare against.
    if (profile == null) return;

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newAddress = _line1Controller.text.trim();
    final newLandmark = _line2Controller.text.trim(); // Map line2 to landmark
    final newCity = _cityController.text.trim();
    final newState = _stateController.text.trim();
    final newPincode = _pincodeController.text.trim();

    bool needsUpdate = false;
    final Map<String, String> updates = {};

    // Check for changes or missing data
    // Note: We don't update name as that's identity, but address details we do.
    
    if (profile.phone == null || profile.phone != newPhone) {
      updates['phone'] = newPhone;
      needsUpdate = true;
    }
    if (profile.address == null || profile.address != newAddress) {
      updates['address'] = newAddress;
      needsUpdate = true;
    }
    if (profile.city == null || profile.city != newCity) {
      updates['city'] = newCity;
      needsUpdate = true;
    }
    if (profile.state == null || profile.state != newState) {
      updates['state'] = newState;
      needsUpdate = true;
    }
    if (profile.pincode == null || profile.pincode != newPincode) {
      updates['pincode'] = newPincode;
      needsUpdate = true;
    }
    
    final currentLandmark = profile.landmark ?? '';
    // Only update if changed
    if (currentLandmark != newLandmark) {
      updates['landmark'] = newLandmark;
      needsUpdate = true;
    }

    if (needsUpdate) {
      debugPrint('Updating user profile with new address details: $updates');
      // Fire and forget - don't block checkout flow for profile update
      profileProvider.updateProfile(
        phone: updates['phone'],
        address: updates['address'],
        city: updates['city'],
        state: updates['state'],
        pincode: updates['pincode'],
        landmark: updates['landmark'],
      ).then((success) {
        if (success) {
           debugPrint('User profile updated successfully via checkout.');
        } else {
           debugPrint('Failed to update user profile via checkout.');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Address')),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateName,
                    enabled: !checkoutProvider.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter 10-digit phone number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _validatePhone,
                    enabled: !checkoutProvider.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Address Line 1
                  TextFormField(
                    controller: _line1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address Line 1',
                      hintText: 'House/Flat No., Building Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateAddressLine1,
                    enabled: !checkoutProvider.isLoading,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Address Line 2 (optional)
                  TextFormField(
                    controller: _line2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address Line 2 (Optional)',
                      hintText: 'Street, Area, Landmark',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: !checkoutProvider.isLoading,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // City field
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateCity,
                    enabled: !checkoutProvider.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // State field
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      hintText: 'Enter state name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateState,
                    enabled: !checkoutProvider.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Pincode field
                  TextFormField(
                    controller: _pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      hintText: 'Enter 6-digit pincode',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pin_drop),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: _validatePincode,
                    enabled: !checkoutProvider.isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Continue button
                  ElevatedButton(
                    onPressed: checkoutProvider.isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: checkoutProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Continue to Place Order',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
