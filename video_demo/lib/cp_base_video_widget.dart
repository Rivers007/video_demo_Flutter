import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CPBaseVideoModel {
  bool playing = false;
  String url = '';
  int index = 0;
  CPBaseVideoModel({this.playing, this.url, this.index});
}

class CPBaseVideoView extends StatefulWidget {
  CPBaseVideoModel model;
  double height;
  double width;
  CPBaseVideoView({Key key, this.model, this.height, this.width})
      : super(key: key);

  @override
  _CPBaseVideoViewState createState() => _CPBaseVideoViewState();
}

class _CPBaseVideoViewState extends State<CPBaseVideoView>
    with TickerProviderStateMixin {
  VideoPlayerController controller;
  bool _isPlaying = false;

  AnimationController toolBarcontroller;
  Animation<Offset> animation;
  bool toolBarHidden = true;
  double sliderValue = 20;

  @override
  void initState() {
    super.initState();
    if (widget.height == null) {
      widget.height = window.physicalSize.height / window.devicePixelRatio;
    }
    if (widget.width == null) {
      widget.width = window.physicalSize.width / window.devicePixelRatio;
    }
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
    toolBarcontroller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation =
        Tween(begin: Offset.zero, end: Offset(0, 1)).animate(toolBarcontroller);
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
    return Center(
      child: Stack(
        children: <Widget>[
          Positioned(
              child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: this.controller.value.aspectRatio,
                child:
                    //  widget.model.playing != true
                    //     ? Container()
                    //     :
                    VideoPlayer(this.controller),
              ),
            ),

            // ),
          )),
          controlView()
        ],
      ),
    );
  }

  controlView() {
    return Positioned(
      child: GestureDetector(
        onTap: () {
          if (this.toolBarHidden == true) {
            toolBarcontroller.forward();
            this.toolBarHidden = false;
          } else {
            toolBarcontroller.reverse();
            this.toolBarHidden = true;
          }
        },
        child: PhysicalModel(
          color: Colors.transparent, //设置背景底色透明
          borderRadius: BorderRadius.circular(0),
          clipBehavior: Clip.antiAlias, //注意这个属性
          child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
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
                                  this.controller.pause();
                                  widget.model.playing = false;
                                } else {
                                  this.controller.play();
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
                            Container(
                              color: Colors.transparent,
                              width: 30,
                              height: 30,
                              margin: EdgeInsets.only(right: 16),
                              child:
                                  Image.asset('images/video_toolbar_full.png'),
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
