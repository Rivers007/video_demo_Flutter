import 'package:flutter/material.dart';
import 'package:video_demo/full_video_widget.dart';
import 'package:video_player/video_player.dart';

class PlayVideoPage extends StatefulWidget {
  PlayVideoPage({Key key}) : super(key: key);

  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  ScrollController _scrollController = new ScrollController();
  Offset pointerStart;
  Offset pointerEnd;
  double touchRangeX = 0;
  double touchRangeY = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  double nextOffset = 0;
  int lastPage = 0;
  Size screenSize;

  int count = 10;

  List<FullVideoWidget> videoPlayerList = [];

  List<FullVideoModel> videoModelList = [
    FullVideoModel(
        playing: true,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2729238_d5132825516cd4603e0d32286474d958_0.mp4',
        index: 0),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2254819_a91cbcd3e0b2d3f7e91f841af7521533_0.mp4',
        index: 1),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2410119_c0266426979b4ffaaa57f8413b40f905_0.mp4',
        index: 2),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/3830561_5acdf9a52e60062c2ccf1244d302a47f_0.mp4',
        index: 3),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2729238_d5132825516cd4603e0d32286474d958_0.mp4',
        index: 4),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2254819_a91cbcd3e0b2d3f7e91f841af7521533_0.mp4',
        index: 5),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2410119_c0266426979b4ffaaa57f8413b40f905_0.mp4',
        index: 6),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/3830561_5acdf9a52e60062c2ccf1244d302a47f_0.mp4',
        index: 7),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2729238_d5132825516cd4603e0d32286474d958_0.mp4',
        index: 8),
    FullVideoModel(
        playing: false,
        url:
            'http://tb-video.bdstatic.com/tieba-smallvideo-transcode/2254819_a91cbcd3e0b2d3f7e91f841af7521533_0.mp4',
        index: 9)
  ];
  //获取屏幕宽度
  @override
  void initState() {
    super.initState();
    videoPlayerList.add(FullVideoWidget());
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;

    return Scaffold(
      body: Listener(
        onPointerDown: (event) {
          //保存触摸按下的位置信息
          pointerStart = event.position;
        },
        onPointerUp: getPonitUpListenerInHorizontal(),
        child: ListView.builder(
            padding: EdgeInsets.all(0),
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemCount: videoModelList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: index % 2 == 0 ? Colors.red : Colors.yellow,
                width: screenWidth,
                height: screenHeight,
                alignment: Alignment.center,
                // child: Text('$index'),
                child: FullVideoWidget(
                  model: videoModelList[index],
                ),
                // )
              );
            }),
      ),
    );
  }

  /*
 * 构造纵向滑动时候的触摸抬起监听
 */
  PointerUpEventListener getPonitUpListenerInHorizontal() {
    return (event) {
      pointerEnd = event.position;
      touchRangeX = pointerStart.dx - pointerEnd.dx;
      touchRangeY = pointerStart.dy - pointerEnd.dy;
      //所有的操作必须要满足滑动距离>10才算是滑动
      if (touchRangeY.abs() < 10) {
        nextOffset = screenHeight * lastPage;
        scrollAnimToOffset(_scrollController, nextOffset, () {
          if (lastPage < 0) {
            lastPage = 0;
          }
          print(lastPage);
        });
        return;
      }
      //纵向操作大于横向操作三倍视为纵向操作
      //这个判断拦截只有在纵向操作距离大于20.0的时候才生效
      if (touchRangeY.abs() < touchRangeX.abs() && touchRangeX > 20) {
        nextOffset = screenHeight * lastPage;
        scrollAnimToOffset(_scrollController, nextOffset, () {
          if (lastPage < 0) {
            lastPage = 0;
          }
          print(lastPage);
        });
        return;
      }

      //如果滑动小于当前屏幕1/8，那么就回弹复原，超过则移动到下一页
      //跳转到下一页或者上一页或者不动
      if (touchRangeY > screenHeight / 8) {
        nextOffset = screenHeight * (lastPage + 1);
        // print("2animate to ${nextOffset}");
        if (lastPage < videoModelList.length - 1) {
          scrollAnimToOffset(_scrollController, nextOffset, () {
            lastPage++;
            if (lastPage >= videoModelList.length - 1) {
              lastPage = videoModelList.length - 1;
            }
            print(lastPage);
            for (FullVideoModel model in videoModelList) {
              model.playing = false;
            }
            videoModelList[lastPage].playing = true;
            setState(() {});
            // videoPlayerList[0].deallocVideoController();
            // videoPlayerList.removeLast();
            // videoPlayerList.add(FullVideoWidget());
          });
        }
      } else if (touchRangeY < -1 * screenHeight / 8) {
        nextOffset = screenHeight * (lastPage - 1);
        // print("1animate to ${nextOffset}");
        if (lastPage > 0) {
          scrollAnimToOffset(_scrollController, nextOffset, () {
            lastPage--;
            if (lastPage < 0) {
              lastPage = 0;
            }
            print(lastPage);
            for (FullVideoModel model in videoModelList) {
              model.playing = false;
            }
            videoModelList[lastPage].playing = true;
            setState(() {});
            // videoPlayerList[0].deallocVideoController();
            // videoPlayerList.removeLast();
            // videoPlayerList.add(FullVideoWidget());
          });
        }
      } else {
        scrollAnimToOffset(_scrollController, screenHeight * lastPage, null);
      }
    };
  }

  /**
 * 滑动到指定位置
 */
  void scrollAnimToOffset(ScrollController controller, double offset,
      void Function() onScrollCompleted) {
    controller
        .animateTo(offset,
            duration: Duration(
              milliseconds: 200,
            ),
            curve: Curves.easeIn)
        .then((v) {
      if (onScrollCompleted != null) {
        onScrollCompleted();
      }
    }).catchError((e) {
      print(e);
    });
  }
}
