import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mywallet/l10n/app_localizations.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannerTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  controller.stop();
                  Navigator.pop(context, {
                    'code': barcode.rawValue,
                    'format': _mapFormat(barcode.format),
                  });
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: () => controller.toggleTorch(),
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _mapFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'qrCode';
      case BarcodeFormat.pdf417:
        return 'pdf417';
      case BarcodeFormat.aztec:
        return 'aztec';
      case BarcodeFormat.code128:
        return 'code128';
      case BarcodeFormat.code39:
        return 'code39';
      case BarcodeFormat.code93:
        return 'code93';
      case BarcodeFormat.ean13:
        return 'ean13';
      case BarcodeFormat.ean8:
        return 'ean8';
      case BarcodeFormat.upcA:
        return 'upcA';
      case BarcodeFormat.upcE:
        return 'upcE';
      case BarcodeFormat.dataMatrix:
        return 'dataMatrix';
      case BarcodeFormat.codabar:
        return 'codabar';
      default:
        return 'qrCode';
    }
  }
}
