import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PdfPickerWidget extends StatefulWidget {
  final String? currentPdfUrl;
  final Function(File) onPdfSelected;

  const PdfPickerWidget({
    Key? key,
    this.currentPdfUrl,
    required this.onPdfSelected,
  }) : super(key: key);

  @override
  State<PdfPickerWidget> createState() => _PdfPickerWidgetState();
}

class _PdfPickerWidgetState extends State<PdfPickerWidget> {
  File? _selectedPdf;
  String? _selectedPdfName;
  int? _selectedPdfSize;

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file size (max 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF size must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedPdf = file;
          _selectedPdfName = result.files.single.name;
          _selectedPdfSize = fileSize;
        });
        widget.onPdfSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePdf() {
    setState(() {
      _selectedPdf = null;
      _selectedPdfName = null;
      _selectedPdfSize = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPdf = _selectedPdf != null || widget.currentPdfUrl != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product PDF Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // PDF Preview
            if (hasPdf)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 40,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPdfName ?? 'Existing PDF',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (_selectedPdfSize != null)
                            Text(
                              _formatFileSize(_selectedPdfSize!),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            )
                          else if (widget.currentPdfUrl != null)
                            Text(
                              'Current PDF',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_selectedPdf != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _removePdf,
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No PDF selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Select PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                label: Text(hasPdf ? 'Change PDF' : 'Select PDF'),
              ),
            ),

            const SizedBox(height: 8),

            // Info Text
            Text(
              'Supported format: PDF only. Max size: 10MB',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 4),

            Text(
              'This PDF will be used as a preview for customers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
