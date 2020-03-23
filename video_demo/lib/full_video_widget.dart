import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullVideoModel {
  bool playing = false;
  String url = '';
  int index = 0;
  FullVideoModel({this.playing, this.url, this.index});
}

class FullVideoWidget extends StatefulWidget {
  FullVideoModel model;
  FullVideoWidget({
    Key key,
    this.model,
  }) : super(key: key);

  deallocVideoController() {
    // controller.
    // if (this.controller != null) {
    //   this.controller.dispose();
    //   // this.controller = null;
    // }
    this.currentState._deallocVideoController();
  }

  _FullVideoWidgetState currentState;
  @override
  _FullVideoWidgetState createState() {
    currentState = _FullVideoWidgetState();
    return currentState;
  }
  // @override
  // _FullVideoWidgetState createState() => _FullVideoWidgetState();
}

class _FullVideoWidgetState extends State<FullVideoWidget> {
  VideoPlayerController controller;
  bool _isPlaying = false;
  bool _playDispose = false;
  // String url =
  //     'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2729238_d5132825516cd4603e0d32286474d958_0.mp4';

  _deallocVideoController() {
    setState(() {
      this._playDispose = true;
    });
    if (this.controller != null) {
      this.controller.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    this.controller = VideoPlayerController.network(widget.model.url);
    // 播放状态
    this.controller
      ..addListener(() {
        final bool isPlaying = this.controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      // 在初始化完成后必须更新界面
      ..initialize().then((_) {
        setState(() {});
        if (widget.model.playing) {
          this.controller.play();
        } else {
          this.controller.pause();
        }
      });

    this.controller.setLooping(true);
  }

  @override
  void didUpdateWidget(FullVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model.playing) {
      this.controller.play();
    } else {
      this.controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        // color: Colors.red,
        // height: 300,
        child: AspectRatio(
          aspectRatio: this.controller.value.aspectRatio,
          child:
              //  widget.model.playing != true
              //     ? Container()
              //     :
              VideoPlayer(this.controller),
        ),

        // ),
      ),
    );
  }

  @override
  void deactivate() {
    if (this.controller != null) {
      this.controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (this.controller != null) {
      this.controller.dispose();
    }
    super.dispose();
  }
}
