import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class QRService {
  // Method to generate QR code data from the member's details
  String generateQRData({
    required String memberName,
    required String teamName,
    required String college,
  }) {
    // Combine details into a single string (can be in any format you like)
    return '$memberName|$teamName|$college';
  }

  // Method to create a QR image widget
  Widget generateQRWidget({
    required String memberName,
    required String teamName,
    required String college,
    double size = 200.0,
  }) {
    final qrData = generateQRData(
      memberName: memberName,
      teamName: teamName,
      college: college,
    );

    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  // Method to validate QR data (decode it and check if it's in the correct format)
  Map<String, String>? validateQRData(String qrCode) {
    final parts = qrCode.split('|');

    // Check if the QR data format is correct (i.e., 3 parts: memberName|teamName|college)
    if (parts.length == 3) {
      return {
        'memberName': parts[0],
        'teamName': parts[1],
        'college': parts[2],
      };
    }
    return null; // Invalid QR format
  }
}
