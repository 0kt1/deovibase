import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  String qrData1 = "";
  String qrData2 = "";
  List<Barcode> barcodes = [];
  File? _image;
  MobileScannerController? _mobileScannerController;

  @override
  void initState() {
    super.initState();
    _mobileScannerController = MobileScannerController();
  }

  @override
  void dispose() {
    // Dispose of the MobileScannerController to release camera and related resources
    _mobileScannerController?.dispose();
    _image = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            height: 350,
            width: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
              border: Border.all(
                color: Colors.deepPurple,
              ),
            ),
            child: _image == null
                ? MobileScanner(
                  controller: _mobileScannerController,
                    // scanWindow:Rect.fromCircle(center: Offset.zero, radius: 30),
                    fit: BoxFit.cover,
                    onDetect: (capture) {
                      setState(() {
                        barcodes = capture.barcodes; // Update the barcodes list inside setState
                        for (final barcode in barcodes) {
                          qrData1 = barcode.rawValue ??
                              "No Data found in QR"; // Update qrData1 for the most recent scan
                        }
                      });
                      print("qrData1: $qrData1");
                    })
                : Image.file(_image!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _pickImage();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pick Image from Gallery',
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _launchUrl(qrData1 == "" ? qrData2 : qrData1);
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  qrData1 == "" ? qrData2 : qrData1,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Scan QR code from the picked image
      _scanQrCodeFromImage(_image!);
    }
  }

  Future<void> _scanQrCodeFromImage(File image) async {
    try {
      String? qrCode = await QrCodeToolsPlugin.decodeFrom(image.path);
      setState(() {
        qrData2 = qrCode ?? "";
      });
    } catch (e) {
      setState(() {
        // qrData2 = "Failed to scan QR code: $e";
      });
    }
  }
}

Future<void> _launchUrl(String _url) async {
  final Uri uri = Uri.parse(_url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $_url');
  }
}
