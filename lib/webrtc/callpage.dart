import 'package:deovibase/webrtc/webrtc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Callpage extends StatefulWidget {
  Callpage({Key? key}) : super(key: key);

  @override
  _CallpageState createState() => _CallpageState();
}

class _CallpageState extends State<Callpage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    },
                    child: Container(
                      child: Icon(Icons.photo_camera_outlined)
                    ),
                    // child: Text("Open camera & microphone"),
                  ),
                  Text(
                    "Open camera",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 18,
                child: Center(child: Text("-->", style: TextStyle(color: Colors.white),))
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      roomId = await signaling.createRoom(_remoteRenderer);
                      textEditingController.text = roomId!;
                      setState(() {});
                    },
                    child: Icon(Icons.house_outlined),
                    // child: Text("Create room"),
                  ),
                  Text(
                    "Create Room",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 18,
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add roomId
                      signaling.joinRoom(
                        textEditingController.text.trim(),
                        _remoteRenderer,
                      );
                    },
                    child: Icon(Icons.add_alert)
                    // child: Text("Join room"),
                  ),
                  Text(
                    "Join Room",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 18,
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                    },
                    child: Icon(Icons.mobile_off)
                    // child: Text("Hangup"),
                  ),
                  Text(
                    "Hangup",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.deepPurple,
                      ),
                    ),
                    child: RTCVideoView(_localRenderer, mirror: true))
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.deepPurple,
                      ),
                    ),
                    child: RTCVideoView(_remoteRenderer))
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Join the following Room and share this code with your friends:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              
                TextFormField(
                  controller: textEditingController,
                  style: TextStyle(
                    color: Colors.deepPurple,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}