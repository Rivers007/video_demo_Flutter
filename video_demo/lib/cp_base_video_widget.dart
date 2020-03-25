import 'dart:io';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
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

  int currentPosition = 0;
  int totalDuration = 0;

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
      // ..addListener(() {
      //   final bool isPlaying = this.controller.value.isPlaying;
      //   // if (isPlaying != _isPlaying) {
      //   //   _isPlaying = isPlaying;
      //   // }
      //   // setState(() {});
      // })
      // 在初始化完成后必须更新界面
      ..initialize().then((_) {
        videoView = VideoView(
          model: widget.model,
          width: this._width,
          height: this._height,
          controller: this.controller,
          toolBarHidden: widget.toolBarHidden,
          isLandscape: this.isLandscape,
          currentPosition: this.currentPosition,
          totalDuration: this.totalDuration,
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
            // setState(() {});
          },
        );
        setState(() {});
        if (widget.model.playing) {
          this.controller.play();
        } else {
          this.controller.pause();
        }
      });
// this.controller.notifyListeners()
    // this.controller.setLooping(true);
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
  int currentPosition;
  int totalDuration;
  VideoView(
      {Key key,
      this.model,
      this.width,
      this.height,
      this.controller,
      this.toolBarHidden,
      this.isLandscape,
      this.fullVideoCallBack,
      this.currentPosition = 0,
      this.totalDuration = 0})
      : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with TickerProviderStateMixin {
  AnimationController toolBarcontroller;
  Animation<Offset> animation;
  double sliderValue = 0;
  // double _height = 0;
  // double _width = 0;
  String positionStr = '00:00';
  String totalTimeStr = '00:00';
  // bool _isLandscape = false;
  MethodChannel _methodChannel = MethodChannel('landscape');
  @override
  void initState() {
    super.initState();

    // this._isLandscape = widget.isLandscape;
    // this._height = double.parse(widget.height.toString());
    // this._width = double.parse(widget.width.toString());
    toolBarcontroller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: Offset.zero, end: Offset(0, -1))
        .animate(toolBarcontroller);
    hiddenToolBar();

    // widget.controller
    //   ..addListener(() {
    //     widget.currentPosition =
    //         widget.controller.value.position.inMilliseconds;
    //     widget.totalDuration = widget.controller.value.duration.inMilliseconds;
    //     // print(
    //     //     '${widget.controller.value.position.inMilliseconds}---${widget.controller.value.duration.inMicroseconds}');
    //     if (widget.totalDuration == 0) {
    //       this.sliderValue = 0;
    //     } else {
    //       this.sliderValue = widget.controller.value.position.inMicroseconds /
    //           widget.controller.value.duration.inMicroseconds *
    //           100;
    //     }
    //     this.sliderValue = this.sliderValue > 100 ? 100 : this.sliderValue;
    //     timeFormat();
    //     setState(() {});
    //   });
    // timeFormat();
  }

  // @override
  // void didUpdateWidget(VideoView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   timeFormat();
  //   // setState(() {});
  //   // widget.isLandscape=
  // }

  timeFormat() {
    this.positionStr = DateUtil.formatDateMs(
      widget.currentPosition,
      format: 'mm:ss',
    );
    this.totalTimeStr = DateUtil.formatDateMs(
      widget.totalDuration,
      format: 'mm:ss',
    );
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
          color: Colors.transparent, //设置背景底色���明
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
                                child: VideoSliderView(
                                    controller: widget.controller),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (widget.isLandscape == true) {
                                  widget.isLandscape = false;
                                } else {
                                  widget.isLandscape = true;
                                }
                                setState(() {});
                                // this._isLandscape = !this._isLandscape;
                                if (widget.isLandscape == true) {
                                  print('横屏');
                                  if (Platform.isIOS) {
                                    _methodChannel
                                        .invokeMethod('landscapeLeft');
                                  }
                                  OrientationPlugin.forceOrientation(
                                      DeviceOrientation.landscapeLeft);
                                } else {
                                  print('竖屏');
                                  if (Platform.isIOS) {
                                    _methodChannel
                                        .invokeMethod('landscapePortrait');
                                  }

                                  OrientationPlugin.forceOrientation(
                                      DeviceOrientation.portraitDown);
                                }

                                if (widget.fullVideoCallBack != null) {
                                  widget.fullVideoCallBack(widget.isLandscape);
                                }
                                // setState(() {});
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

class VideoSliderView extends StatefulWidget {
  VideoPlayerController controller;
  VideoSliderView({Key key, this.controller}) : super(key: key);

  @override
  _VideoSliderViewState createState() => _VideoSliderViewState();
}

class _VideoSliderViewState extends State<VideoSliderView> {
  double sliderValue = 0;
  int currentPosition;
  int totalDuration;

  String positionStr = '00:00';
  String totalTimeStr = '00:00';

  @override
  void initState() {
    super.initState();

    // timeFormat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.removeListener(_videoListener);
    widget.controller.addListener(_videoListener);
  }

  void _videoListener() {
    this.currentPosition = widget.controller.value.position.inMilliseconds;
    this.totalDuration = widget.controller.value.duration.inMilliseconds;
    // print(
    //     '${widget.controller.value.position.inMilliseconds}---${widget.controller.value.duration.inMicroseconds}');
    if (this.totalDuration == 0) {
      this.sliderValue = 0;
    } else {
      this.sliderValue = widget.controller.value.position.inMicroseconds /
          widget.controller.value.duration.inMicroseconds *
          100;
    }
    this.sliderValue = this.sliderValue > 100 ? 100 : this.sliderValue;
    timeFormat();
    if (mounted) {
      setState(() {});
    }
  }

  timeFormat() {
    this.positionStr = DateUtil.formatDateMs(
      this.currentPosition,
      format: 'mm:ss',
    );
    this.totalTimeStr = DateUtil.formatDateMs(
      this.totalDuration,
      format: 'mm:ss',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          // onTapDown: (e) {
          //   widget.controller.pause();
          // },
          // onTapUp: (e) {
          //   widget.controller.play();
          // },
          child: Slider(
            value: this.sliderValue,
            max: 100.0,
            min: 0.0,
            inactiveColor: Colors.white24,
            activeColor: Colors.white,
            onChangeStart: (double val) {
              widget.controller.pause();
            },
            onChangeEnd: (double val) {
              this.setState(() {
                this.sliderValue = val;
              });
              widget.controller.seekTo(
                  Duration(milliseconds: this.totalDuration * val ~/ 100));
              widget.controller.play();
            },
            onChanged: (double val) {
              setState(() {
                this.sliderValue = val;
              });
            },
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
