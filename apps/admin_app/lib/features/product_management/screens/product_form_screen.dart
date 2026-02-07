import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../providers/product_provider.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/pdf_picker_widget.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _basePriceController = TextEditingController();

  String? _selectedSubjectId;
  String _selectedFileType = 'none'; // 'image', 'pdf', 'none'
  bool _isActive = true;
  bool _isLoading = false;

  File? _selectedImageFile;
  File? _selectedPdfFile;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final product = widget.product!;
    _titleController.text = product.title;
    _descriptionController.text = product.description;
    _isbnController.text = product.isbn ?? '';
    _basePriceController.text = product.basePrice.toString();
    _selectedSubjectId = product.subjectId;
    _selectedFileType = product.fileType;
    _isActive = product.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProductProvider>();

      if (isEditing) {
        // Update existing product
        await provider.updateProduct(
          productId: widget.product!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          isbn: _isbnController.text.trim().isEmpty
              ? null
              : _isbnController.text.trim(),
          basePrice: double.parse(_basePriceController.text.trim()),
          subjectId: _selectedSubjectId,
          fileType: _selectedFileType,
          isActive: _isActive,
        );

        // Upload files if selected
        if (_selectedImageFile != null && _selectedFileType == 'image') {
          await provider.uploadProductImage(
            widget.product!.id,
            _selectedImageFile!,
          );
        }

        if (_selectedPdfFile != null && _selectedFileType == 'pdf') {
          await provider.uploadProductPDF(
            widget.product!.id,
            _selectedPdfFile!,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        // Create new product
        final newProduct = await provider.createProduct(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          isbn: _isbnController.text.trim().isEmpty
              ? null
              : _isbnController.text.trim(),
          basePrice: double.parse(_basePriceController.text.trim()),
          subjectId: _selectedSubjectId!,
          fileType: _selectedFileType,
        );

        // Upload files if selected
        if (_selectedImageFile != null && _selectedFileType == 'image') {
          await provider.uploadProductImage(newProduct.id, _selectedImageFile!);
        }

        if (_selectedPdfFile != null && _selectedFileType == 'pdf') {
          await provider.uploadProductPDF(newProduct.id, _selectedPdfFile!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully')),
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
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Product Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ISBN (Optional)
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.library_books),
              ),
            ),
            const SizedBox(height: 16),

            // Base Price
            TextFormField(
              controller: _basePriceController,
              decoration: const InputDecoration(
                labelText: 'Base Price *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Base price is required';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Subject ID - In real app, this should be a dropdown
            // For now, using text field (TODO: Implement subject selector)
            TextFormField(
              initialValue: _selectedSubjectId,
              decoration: const InputDecoration(
                labelText: 'Subject ID *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
                helperText: 'Enter valid subject ID',
              ),
              onChanged: (value) {
                _selectedSubjectId = value.trim().isEmpty ? null : value.trim();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // File Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'none',
                          label: Text('None'),
                          icon: Icon(Icons.block),
                        ),
                        ButtonSegment(
                          value: 'image',
                          label: Text('Image'),
                          icon: Icon(Icons.image),
                        ),
                        ButtonSegment(
                          value: 'pdf',
                          label: Text('PDF'),
                          icon: Icon(Icons.picture_as_pdf),
                        ),
                      ],
                      selected: {_selectedFileType},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedFileType = selection.first;
                          // Clear file selections when changing type
                          _selectedImageFile = null;
                          _selectedPdfFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image Picker (if file type is image)
            if (_selectedFileType == 'image')
              ImagePickerWidget(
                currentImageUrl: widget.product?.imageUrl,
                onImageSelected: (file) {
                  setState(() {
                    _selectedImageFile = file;
                  });
                },
              ),

            // PDF Picker (if file type is pdf)
            if (_selectedFileType == 'pdf')
              PdfPickerWidget(
                currentPdfUrl: widget.product?.pdfUrl,
                onPdfSelected: (file) {
                  setState(() {
                    _selectedPdfFile = file;
                  });
                },
              ),

            const SizedBox(height: 16),

            // Active Status
            SwitchListTile(
              title: const Text('Active Status'),
              subtitle: Text(
                _isActive ? 'Product is active' : 'Product is inactive',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Product' : 'Create Product'),
            ),
          ],
        ),
      ),
    );
  }
}
