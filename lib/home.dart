import 'package:deovibase/live/live.dart';
import 'package:deovibase/live/stream.dart';
import 'package:deovibase/main.dart';
import 'package:deovibase/photo_align/pdf.dart';
import 'package:deovibase/qrscanner.dart';
import 'package:deovibase/webrtc/callpage.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  BottomBar({
    super.key,
  });

  @override
  State<BottomBar> createState() => _HomeState();
}

class _HomeState extends State<BottomBar> {

  late int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> pagelist = [StreamPage(), PhotoCapturePage(), QrScanner(), Callpage()];



    return Scaffold(
      body: SafeArea(
        top: true,
        child: pagelist[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Set the background color to black
        selectedItemColor: Colors.white, // Set the selected item color to white
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [BottomNavigationBarItem(icon: Icon(Icons.live_tv_outlined), label: "Stream"), BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf_outlined), label: "Pdf"), BottomNavigationBarItem(icon: Icon(Icons.qr_code_outlined), label: "QR"), BottomNavigationBarItem(icon: Icon(Icons.video_call_outlined), label: "RTC")],
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }
}
