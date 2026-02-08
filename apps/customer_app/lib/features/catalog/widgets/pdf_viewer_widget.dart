import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../core/config/env.dart';

/// Widget for viewing PDF files
class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerWidget({super.key, required this.pdfUrl});

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final resolvedUrl = _resolvePdfUrl(widget.pdfUrl);
      final response = await http.get(Uri.parse(resolvedUrl));

      if (response.statusCode == 200) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  String _resolvePdfUrl(String pdfPath) {
    if (pdfPath.startsWith('http')) return pdfPath;
    if (pdfPath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$pdfPath';
    }
    return '${Environment.apiBaseUrl}/api/v1/files/pdfs/books/$pdfPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _pdfBytes != null ? _downloadPdf : null,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load PDF',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPdf, child: const Text('Retry')),
          ],
        ),
      );
    }

    // Note: This is a placeholder. For full PDF viewing, you would need to integrate
    // a PDF viewer package like flutter_pdfview or syncfusion_flutter_pdfviewer
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'PDF Preview Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'File size: ${(_pdfBytes!.length / 1024).toStringAsFixed(2)} KB',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Note: Full PDF preview requires additional packages. You can download the PDF to view it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadPdf() {
    // TODO: Implement actual PDF download functionality
    // This would typically involve using packages like:
    // - path_provider for getting download directory
    // - permission_handler for storage permissions
    // - file I/O operations to save the PDF

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
