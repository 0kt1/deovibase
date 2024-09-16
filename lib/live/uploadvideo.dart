import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Uploadvideo extends StatefulWidget {
  const Uploadvideo({super.key});

  @override
  State<Uploadvideo> createState() => _UploadvideoState();
}

class _UploadvideoState extends State<Uploadvideo> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final picker = ImagePicker();
  XFile? pickedFile;
  bool _isLoading = false;

  TextEditingController videoname = TextEditingController();

  Future<void> _chooseVideo() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    final p = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      pickedFile = p;
      _isLoading = false;
    });
    print("dxtcfgvhbj: ${pickedFile?.path}");
  }

  Future<void> _uploadVideo() async {
    if (pickedFile != null) {
      setState(() {
        _isLoading = true; // Set loading to true
      });

      File videoFile = File(pickedFile!.path);

      // Create a reference to the location where the video will be stored
      String fileName = videoname.text;
      // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = _storage.ref().child(
          'videos/${fileName == "" ? DateTime.now().millisecondsSinceEpoch.toString() : fileName}');

      try {
        // Upload the video
        await reference.putFile(videoFile);

        // Get the download URL
        String downloadURL = await reference.getDownloadURL();

        // Save the video metadata to the Realtime Database
        DatabaseReference dbRef = _database.ref().child('videos');
        await dbRef.push().set({
          'url': downloadURL,
          'name': fileName == ""
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : fileName,
          'timestamp': DateTime.now().toString(),
        });

        Navigator.pop(
          context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded successfully!')),
        );
      } catch (e) {
        print('Error uploading video: $e');
      } finally {
        setState(() {
          _isLoading = false; // Set loading to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Upload Video'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 50),
                Padding(padding: EdgeInsets.all(18.0)   ,child: Text("You can upload the video file to the database and test the app. Please make sure the video file size is less than 5MB to avoid long upload times. thank You.", 
                style: TextStyle(color: Colors.white, fontSize: 16)),),
                SizedBox(height: 50),
                Container(
                  width: 200,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Input File Name",
                        hintStyle: TextStyle(color: Colors.white)),
                    // initialValue: "Input file name..",
                    controller: videoname,
                  ),
                ),
                SizedBox(height: 50),
                Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: _chooseVideo, child: Text("choose video")),
                    pickedFile != null
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : Text(""),
                  ],
                )),
                Center(
                    child: ElevatedButton(
                        onPressed: _uploadVideo, child: Text("upload video"))),
              ],
            ),
    );
  }

  @override
  void dispose() {
    videoname.dispose();
    pickedFile = null;
    super.dispose();
  }
}
