import 'package:flutter/material.dart';
import 'package:video_demo/full_video_widget.dart';
import 'package:video_demo/play_video_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ListView.builder(
            padding: EdgeInsets.only(top: 160),
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return PlayVideoPage();
                    }));
                  },
                  child: Container(
                    height: 60,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Text(
                      '播放',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 60,
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: Text('录制', style: TextStyle(fontSize: 16)),
                );
              }
            }),
      ),
    );
  }
}
