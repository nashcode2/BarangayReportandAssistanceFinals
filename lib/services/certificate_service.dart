import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/certificate_model.dart';

/// Service for generating barangay certificates
class CertificateService {
  /// Generate Barangay Clearance PDF (Simplified - Fast generation)
  static Future<Uint8List> generateBarangayClearance({
    required String residentName,
    required String address,
    required String purpose,
    required String qrCodeData,
    required String barangayName,
    required String issuedBy,
    required DateTime issuedDate,
    DateTime? validUntil,
  }) async {
    final pdf = pw.Document();
    // QR code generation removed for faster PDF creation

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                'REPUBLIC OF THE PHILIPPINES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                barangayName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'BARANGAY CLEARANCE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 30),

              // Body
              pw.Paragraph(
                text:
                    'TO WHOM IT MAY CONCERN:\n\n'
                    'This is to certify that $residentName, of legal age, '
                    'Filipino, and a resident of $address, is a bonafide resident '
                    'of this barangay and is known to be of good moral character.\n\n'
                    'This certification is issued upon the request of the above-named '
                    'person for $purpose.\n\n'
                    'Issued this ${_formatDate(issuedDate)} at $barangayName.',
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 40),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Prepared by:',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        issuedBy,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Barangay Secretary',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Certified Correct:',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        '___________________',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Barangay Captain',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              
              // Certificate ID for verification (instead of QR code)
              pw.Center(
                child: pw.Text(
                  'Certificate ID: ${qrCodeData.substring(0, qrCodeData.length > 20 ? 20 : qrCodeData.length)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ),
              
              if (validUntil != null) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Valid until: ${_formatDate(validUntil)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate Certificate of Indigency PDF (Simplified - Fast generation)
  static Future<Uint8List> generateCertificateOfIndigency({
    required String residentName,
    required String address,
    required String purpose,
    required String qrCodeData,
    required String barangayName,
    required String issuedBy,
    required DateTime issuedDate,
  }) async {
    final pdf = pw.Document();
    // QR code generation removed for faster PDF creation

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'REPUBLIC OF THE PHILIPPINES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                barangayName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'CERTIFICATE OF INDIGENCY',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 30),

              pw.Paragraph(
                text:
                    'TO WHOM IT MAY CONCERN:\n\n'
                    'This is to certify that $residentName, of legal age, '
                    'Filipino, and a resident of $address, is an indigent '
                    'resident of this barangay.\n\n'
                    'This certification is issued upon the request of the above-named '
                    'person for $purpose.\n\n'
                    'Issued this ${_formatDate(issuedDate)} at $barangayName.',
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 40),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        issuedBy,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Barangay Secretary', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Certified Correct:', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('___________________', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Barangay Captain', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Certificate ID: ${qrCodeData.substring(0, qrCodeData.length > 20 ? 20 : qrCodeData.length)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate Certificate of Residency PDF (Simplified - Fast generation)
  static Future<Uint8List> generateCertificateOfResidency({
    required String residentName,
    required String address,
    required String qrCodeData,
    required String barangayName,
    required String issuedBy,
    required DateTime issuedDate,
  }) async {
    final pdf = pw.Document();
    // QR code generation removed for faster PDF creation

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'REPUBLIC OF THE PHILIPPINES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                barangayName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'CERTIFICATE OF RESIDENCY',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 30),
              pw.Paragraph(
                text:
                    'TO WHOM IT MAY CONCERN:\n\n'
                    'This is to certify that $residentName, of legal age, '
                    'Filipino, is a bonafide resident of $address, '
                    'this barangay.\n\n'
                    'This certification is issued upon the request of the above-named '
                    'person for whatever legal purpose it may serve.\n\n'
                    'Issued this ${_formatDate(issuedDate)} at $barangayName.',
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        issuedBy,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Barangay Secretary', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Certified Correct:', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('___________________', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Barangay Captain', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Certificate ID: ${qrCodeData.substring(0, qrCodeData.length > 20 ? 20 : qrCodeData.length)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate QR code image
  static Future<Uint8List> _generateQrImage(String data) async {
    try {
      if (data.isEmpty) {
        throw Exception('QR code data is empty');
      }
      
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      
      // Render to image (optimized - smaller size for faster rendering)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = 150.0; // Reduced from 200 to 150 for faster rendering
      qrPainter.paint(canvas, Size(size, size));
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert QR code image to bytes');
      }
      
      return byteData.buffer.asUint8List();
    } catch (e) {
      // Log error and rethrow for better error handling
      print('QR code generation error: $e');
      throw Exception('Failed to generate QR code: $e');
    }
  }

  /// Format date for certificate
  static String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Generate QR code data string
  static String generateQrCodeData({
    required String certificateId,
    required String certificateType,
    required String residentName,
    required DateTime issuedDate,
  }) {
    return 'BARANGAY_CERT:$certificateId:$certificateType:$residentName:${issuedDate.toIso8601String()}';
  }
}

