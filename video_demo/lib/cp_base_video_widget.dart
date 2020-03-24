import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'package:video_player/video_player.dart';

class CPBaseVideoModel {
  bool playing;
  String url;
  int index;

  CPBaseVideoModel({
    this.playing = false,
    this.url = '',
    this.index = 0,
  });
}

class CPBaseVideoView extends StatefulWidget {
  CPBaseVideoModel model;
  double height;
  double width;
  bool toolBarHidden;
  CPBaseVideoView(
      {Key key, this.model, this.height, this.width, this.toolBarHidden = true})
      : super(key: key);

  @override
  _CPBaseVideoViewState createState() => _CPBaseVideoViewState();
}

class _CPBaseVideoViewState extends State<CPBaseVideoView>
    with TickerProviderStateMixin {
  VideoPlayerController controller;
  bool _isPlaying = false;
  bool isLandscape = false;

  double _height;
  double _width;
  Widget videoView;

  @override
  void initState() {
    super.initState();
    if (widget.height == null) {
      widget.height = window.physicalSize.height / window.devicePixelRatio;
    }
    if (widget.width == null) {
      widget.width = window.physicalSize.width / window.devicePixelRatio;
    }
    this._height = widget.height;
    this._width = widget.width;
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
        videoView = VideoView(
          model: widget.model,
          width: this._width,
          height: this._height,
          controller: this.controller,
          toolBarHidden: widget.toolBarHidden,
          isLandscape: this.isLandscape,
          fullVideoCallBack: (bool isLandscape) {
            this.isLandscape = isLandscape;
            if (this.isLandscape == true) {
              Navigator.push(context, PageRouteBuilder(pageBuilder:
                  (BuildContext context, Animation animation,
                      Animation secondaryAnimation) {
                return LandscapeVideoView(
                  videoView: this.videoView,
                );
              }));
            } else {
              Navigator.pop(context);
            }
          },
        );
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
  void didUpdateWidget(CPBaseVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model.playing) {
      this.controller.play();
    } else {
      this.controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: videoView);
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

class VideoView extends StatefulWidget {
  CPBaseVideoModel model;
  double width;
  double height;
  VideoPlayerController controller;
  bool toolBarHidden;
  bool isLandscape;
  Function fullVideoCallBack;
  VideoView(
      {Key key,
      this.model,
      this.width,
      this.height,
      this.controller,
      this.toolBarHidden,
      this.isLandscape,
      this.fullVideoCallBack})
      : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with TickerProviderStateMixin {
  AnimationController toolBarcontroller;
  Animation<Offset> animation;
  double sliderValue = 20;
  // double _height = 0;
  // double _width = 0;
  MethodChannel _methodChannel = MethodChannel('landscape');
  @override
  void initState() {
    super.initState();
    // this._height = double.parse(widget.height.toString());
    // this._width = double.parse(widget.width.toString());
    toolBarcontroller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: Offset.zero, end: Offset(0, -1))
        .animate(toolBarcontroller);
    hiddenToolBar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
                child: Container(
              width: widget.isLandscape == true
                  ? window.physicalSize.height / window.devicePixelRatio
                  : widget.width,
              height: widget.isLandscape == true
                  ? window.physicalSize.width / window.devicePixelRatio
                  : widget.height,
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child:
                      //  widget.model.playing != true
                      //     ? Container()
                      //     :
                      VideoPlayer(widget.controller),
                ),
              ),

              // ),
            )),
            controlView()
          ],
        ),
      ),
    );
  }

  hiddenToolBar() async {
    if (widget.toolBarHidden == true) {
      toolBarcontroller.reverse();
      widget.toolBarHidden = false;
    } else {
      toolBarcontroller.forward();
      widget.toolBarHidden = true;
    }
  }

  controlView() {
    return Positioned(
      child: GestureDetector(
        onTap: () {
          hiddenToolBar();
        },
        child: PhysicalModel(
          color: Colors.transparent, //设置背景底色透明
          borderRadius: BorderRadius.circular(0),
          clipBehavior: Clip.antiAlias, //注意这个属性
          child: Container(
            width: widget.isLandscape == true
                ? window.physicalSize.height / window.devicePixelRatio
                : widget.width,
            height: widget.isLandscape == true
                ? window.physicalSize.width / window.devicePixelRatio
                : widget.height,
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: -60,
                    child: SlideTransition(
                      position: animation,
                      child: Container(
                        // width: 100,
                        height: 60,
                        color: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (widget.model.playing == true) {
                                  widget.controller.pause();
                                  widget.model.playing = false;
                                } else {
                                  widget.controller.play();
                                  widget.model.playing = true;
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.only(
                                  left: 16,
                                ),
                                child: Image.asset(widget.model.playing == true
                                    ? 'images/video_toolbar_pause.png'
                                    : 'images/video_toolbar_play.png'),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                alignment: Alignment.center,
                                // margin: EdgeInsets.only(left: 2, right: 2),
                                // color: Colors.yellow,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Slider(
                                    value: this.sliderValue,
                                    max: 100.0,
                                    min: 0.0,
                                    activeColor: Colors.blue,
                                    onChanged: (double val) {
                                      this.setState(() {
                                        this.sliderValue = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.isLandscape = !widget.isLandscape;
                                if (widget.isLandscape == true) {
                                  if (Platform.isIOS) {
                                    _methodChannel
                                        .invokeMethod('landscapeLeft');
                                  }
                                  // else {
                                  OrientationPlugin.forceOrientation(
                                      DeviceOrientation.landscapeRight);
                                  // }
                                } else {
                                  if (Platform.isIOS) {
                                    _methodChannel
                                        .invokeMethod('landscapePortrait');
                                  }
                                  // else {
                                  OrientationPlugin.forceOrientation(
                                      DeviceOrientation.portraitUp);
                                  // }
                                }
                                setState(() {});
                                if (widget.fullVideoCallBack != null) {
                                  widget.fullVideoCallBack(widget.isLandscape);
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.only(right: 16),
                                child: Image.asset(
                                    'images/video_toolbar_full.png'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LandscapeVideoView extends StatefulWidget {
  Widget videoView;
  LandscapeVideoView({Key key, this.videoView}) : super(key: key);

  @override
  _LandscapeVideoViewState createState() => _LandscapeVideoViewState();
}

class _LandscapeVideoViewState extends State<LandscapeVideoView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: widget.videoView,
    );
  }
}
