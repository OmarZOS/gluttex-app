import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String screenTitle;

  const PdfViewerScreen(
      {super.key, required this.assetPath, required this.screenTitle});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<Uint8List> _loadPdfBytes(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load PDF: $e');
    }
  }

  Future<void> _loadPdf() async {
    try {
      final bytes = await _loadPdfBytes(widget.assetPath);
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.screenTitle)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pdfBytes != null
              ? PDFView(
                  pdfData: _pdfBytes!, // ← Pass bytes here
                  enableSwipe: true,
                  pageSnap: true,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF Error: $error')),
                    );
                  },
                )
              : Center(child: Text('Failed to load PDF')),
    );
  }
}
