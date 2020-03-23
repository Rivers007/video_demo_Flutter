import 'package:flutter/material.dart';
import 'package:video_demo/cp_base_video_widget.dart';

class SmallVideoPage extends StatefulWidget {
  SmallVideoPage({Key key}) : super(key: key);

  @override
  _SmallVideoPageState createState() => _SmallVideoPageState();
}

class _SmallVideoPageState extends State<SmallVideoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 300,
      // width: 414,
      color: Colors.red,
      child: CPBaseVideoView(
        model: CPBaseVideoModel(
            playing: true,
            url:
                'http://video.pearvideo.com/mp4/adshort/20181120/cont-1479130-13260196_adpkg-ad_hd.mp4',
            index: 0),
        height: 300,
      ),
    );
  }
}
