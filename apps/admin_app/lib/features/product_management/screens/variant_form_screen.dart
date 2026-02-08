import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/variant_provider.dart';

class VariantFormScreen extends StatefulWidget {
  final String productId;
  final ProductVariant? variant;

  const VariantFormScreen({Key? key, required this.productId, this.variant})
    : super(key: key);

  @override
  State<VariantFormScreen> createState() => _VariantFormScreenState();
}

class _VariantFormScreenState extends State<VariantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _variantTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();

  bool _isLoading = false;

  bool get isEditing => widget.variant != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final variant = widget.variant!;
    _variantTypeController.text = variant.variantType;
    _priceController.text = variant.price.toString();
    _stockController.text = variant.stock.toString();
    _skuController.text = variant.sku;
  }

  @override
  void dispose() {
    _variantTypeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<VariantProvider>();

      if (isEditing) {
        // Update existing variant
        await provider.updateVariant(
          variantId: widget.variant!.id,
          variantType: _variantTypeController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Variant updated successfully')),
          );
        }
      } else {
        // Create new variant
        await provider.createVariant(
          productId: widget.productId,
          variantType: _variantTypeController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Variant created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: isEditing ? 'Edit Variant' : 'Add Variant',
      currentRoute: RouteNames.products,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Variant Type
            TextFormField(
              controller: _variantTypeController,
              decoration: const InputDecoration(
                labelText: 'Variant Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.style),
                helperText: 'e.g., Color, B&W, Hardcover, Paperback',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Variant type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Price is required';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Stock quantity is required';
                }
                final stock = int.tryParse(value.trim());
                if (stock == null || stock < 0) {
                  return 'Enter a valid stock quantity (0 or more)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // SKU (Optional)
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                helperText: 'Stock Keeping Unit',
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Variant Types Examples',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• For stationery: Color Print, Black & White'),
                    const Text('• For books: Hardcover, Paperback, eBook'),
                    const Text('• For sizes: Small, Medium, Large'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveVariant,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Variant' : 'Create Variant'),
            ),
          ],
        ),
      ),
    );
  }
}
