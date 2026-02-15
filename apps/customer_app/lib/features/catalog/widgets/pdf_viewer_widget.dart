import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';
import '../../../core/config/env.dart';

/// Widget for viewing PDF files with inline PDF viewer
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
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
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
        final document = await PdfDocument.openData(response.bodyBytes);
        
        setState(() {
          _pdfController = PdfController(
            document: Future.value(document),
          );
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
        title: const Text('PDF Viewer'),
        actions: [
          if (_pdfController != null)
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                // Zoom functionality is handled by PdfView gestures
              },
              tooltip: 'Pinch to zoom',
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

    if (_pdfController == null) {
      return const Center(
        child: Text('PDF not loaded'),
      );
    }

    // Display PDF with pdfx viewer
    return PdfView(
      controller: _pdfController!,
      scrollDirection: Axis.vertical,
      onDocumentLoaded: (document) {
        debugPrint('PDF loaded: ${document.pagesCount} pages');
      },
      onPageChanged: (page) {
        debugPrint('Page changed: $page');
      },
      builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        pageLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (_, error) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
