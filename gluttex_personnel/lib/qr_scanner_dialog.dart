import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_personnel/qr_scanner_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerDialog extends StatefulWidget {
  final QRScannerService qrScannerService;
  final Function(AppUser) onUserScanned;

  const QRScannerDialog({
    Key? key,
    required this.qrScannerService,
    required this.onUserScanned,
  }) : super(key: key);

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> {
  bool _isScanning = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            // Scanner View
            _buildScannerView(),
            // Instructions
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: _isScanning
            ? QRView(
                key: widget.qrScannerService.qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 5,
                  cutOutSize: 250,
                ),
              )
            : _buildScanResult(),
      ),
    );
  }

  Widget _buildScanResult() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Failed',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 50, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan Successful!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInstructions() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Position the QR code within the frame',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The scan will happen automatically',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    widget.qrScannerService.onQRViewCreated(controller);

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && _isScanning) {
        _handleScannedData(scanData.code!);
      }
    });
  }

  void _handleScannedData(String qrData) {
    setState(() {
      _isScanning = false;
    });

    // Parse QR data
    final user = widget.qrScannerService.parseQRData(qrData);

    if (user != null) {
      setState(() {
        _hasError = false;
      });

      // Delay to show success state
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
        widget.onUserScanned(user);
      });
    } else {
      setState(() {
        _hasError = true;
      });

      // Allow retry after error
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isScanning = true;
          _hasError = false;
        });
      });
    }
  }

  @override
  void dispose() {
    widget.qrScannerService.controller?.dispose();
    super.dispose();
  }
}
