import 'package:deovibase/live/uploadvideo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class StreamPage extends StatefulWidget {
  @override
  StreamPageState createState() => StreamPageState();
}

class StreamPageState extends State<StreamPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Map<String, VideoPlayerController> _controllers = {};
  String? _playingVideoKey;

  Future<void> _uploadVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);

      // Create a reference to the location where the video will be stored
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = _storage.ref().child('videos/$fileName');

      try {
        // Upload the video
        await reference.putFile(videoFile);

        // Get the download URL
        String downloadURL = await reference.getDownloadURL();

        // Save the video metadata to the Realtime Database
        DatabaseReference dbRef = _database.ref().child('videos');
        await dbRef.push().set({
          'url': downloadURL,
          'name': fileName,
          'timestamp': DateTime.now().toString(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded successfully!')),
        );
      } catch (e) {
        print('Error uploading video: $e');
      }
    }
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    return Column(
      children: [
        if (controller.value.isInitialized)
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                if (!controller.value.isPlaying && !controller.value.isBuffering)
                  IconButton(icon: Icon(Icons.play_arrow, color: Colors.white, size: 50), onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },),
                if (controller.value.isBuffering)
                  CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        if (controller.value.isInitialized)
          Column(
            children: [
              VideoProgressIndicator(controller, allowScrubbing: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(controller.value.position),
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    _formatDuration(controller.value.duration),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.deepPurple,
                    icon: Icon(controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                  ),
                  IconButton(
                    color: Colors.deepPurple,
                    icon: Icon(Icons.fast_forward),
                    onPressed: () {
                      final newPosition =
                          controller.value.position + Duration(seconds: 10);
                      controller.seekTo(
                          newPosition < controller.value.duration
                              ? newPosition
                              : controller.value.duration);
                    },
                  ),
                  DropdownButton<double>(
                    value: controller.value.playbackSpeed,
                    items: [0.5, 1.0, 1.5, 2.0].map((speed) {
                      return DropdownMenuItem<double>(
                        value: speed,
                        child: Text('${speed}x'),
                      );
                    }).toList(),
                    onChanged: (speed) {
                      if (speed != null) {
                        setState(() {
                          controller.setPlaybackSpeed(speed);
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          )
        else
          CircularProgressIndicator(),
      ],
    );
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return "${twoDigits(position.inHours)}:$minutes:$seconds";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream Videos'), backgroundColor: Colors.black, titleTextStyle: TextStyle(color:Colors.white, fontSize: 20),),
      backgroundColor: Colors.black,
      body: StreamBuilder<DatabaseEvent>(
        stream: _database.ref().child('videos').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data?.snapshot.value as Map?;
            if (data == null) {
              return Center(child: Text('No videos found.'));
            }

            List<Widget> videoWidgets = [];
            data.forEach((key, value) {
              String videoUrl = value['url'] ?? '';
              // bool isPlaying = _playingVideoKey == key;
              VideoPlayerController? controller = _controllers[key];

              // bool isBuffering = controller?.value.isBuffering ?? false;
              // Duration position = controller?.value.position ?? Duration.zero;
              // Duration duration = controller?.value.duration ?? Duration.zero;

              if (controller == null) {
                controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
                  ..initialize().then((_) {
                    setState(() {}); 
                    controller?.addListener(() {
                      setState(() {}); // Keep the UI in sync with the player
                    });// Refresh to show video player
                  });
                _controllers[key] = controller;
              }

              videoWidgets.add(
                Card(
                  color: Colors.black,
                  elevation: 10,
                  margin: EdgeInsets.all(8.0),
                  child: buildVideoPlayer(controller),
                ),
              );
            });

            return ListView(children: videoWidgets);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Uploadvideo()),
          );
        },
        child: Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black,
            border: Border.all(
              color: Colors.deepPurple,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
    );
  }

  // void _playVideo(String url) {
  //   if (_controller != null) {
  //     _controller!.dispose();
  //   }
  //   _controller = VideoPlayerController.network(url)
  //     ..initialize().then((_) {
  //       setState(() {
  //         _isPlaying = true;
  //         _controller!.play();
  //       });
  //     });

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Video Player'),
  //         content: AspectRatio(
  //           aspectRatio: _controller!.value.aspectRatio,
  //           child: VideoPlayer(_controller!),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 _isPlaying = false;
  //                 _controller!.pause();
  //               });
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    // Dispose all controllers to free resources
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
}
