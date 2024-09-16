import 'package:deovibase/photo_align/photo_processing.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoCapturePage extends StatefulWidget {
  @override
  _PhotoCapturePageState createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoProcessingPage(imagePath: _image!.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Document'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _takePicture,
          child: Text('Take Picture'),
        ),
      ),
    );
  }
}
