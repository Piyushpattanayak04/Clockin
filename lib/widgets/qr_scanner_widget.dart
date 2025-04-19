import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatelessWidget {
  final Function(String) onQRCodeScanned;

  QRScannerWidget({required this.onQRCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final String? barcode = barcodes.isNotEmpty ? barcodes.first.rawValue : null;

              if (barcode != null) {
                // Call the callback function when a QR code is scanned
                onQRCodeScanned(barcode);
              }
            },
          ),
          // Optional: A UI overlay to show the scanning area
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
