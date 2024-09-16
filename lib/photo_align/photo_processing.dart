import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class PhotoProcessingPage extends StatefulWidget {
  final String imagePath;

  PhotoProcessingPage({required this.imagePath});

  @override
  _PhotoProcessingPageState createState() => _PhotoProcessingPageState();
}

class _PhotoProcessingPageState extends State<PhotoProcessingPage> {
  img.Image? _image;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final file = File(widget.imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      // Apply image processing to align and straighten
      final alignedImage = _alignImage(image);
      setState(() {
        _image = alignedImage;
      });

      // Save or display the processed image
      final processedImagePath = await _saveImage(alignedImage);
      print('Processed image saved to: $processedImagePath');
    }
  }

  img.Image _alignImage(img.Image image) {
    // Implement your image alignment logic here
    // For simplicity, we will just return the original image
    return image;
  }

  Future<String> _saveImage(img.Image image) async {
    final file = File(widget.imagePath);
    final newPath = '${file.parent.path}/aligned_${file.uri.pathSegments.last}';
    final newFile = File(newPath);
    await newFile.writeAsBytes(img.encodeJpg(image));
    return newFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processed Image'),
      ),
      body: Center(
        child: _image == null
            ? Column(
              children: [
                CircularProgressIndicator(),
                Text('Processing...'),
              ],
            )
            : Image.file(File(widget.imagePath)),
      ),
    );
  }
}
