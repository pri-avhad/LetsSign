import 'dart:async';
import 'dart:typed_data';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

import '../utils/settings.dart';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:path_provider/path_provider.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:carousel_pro/carousel_pro.dart';

class VCallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const VCallPage({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _VCallPageState createState() => _VCallPageState();
}

class _VCallPageState extends State<VCallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;
  String channelName;

  int stop = 0;

  Future<void> _capturePng() async {
    String path = await NativeScreenshot.takeScreenshot();
    print(path);
    if (path == null || path.isEmpty) {
      print("Error taking the screenshot :(");
    } else {
      File imgFile = File(path);
      print('The screenshot has been saved to: $path');

      //TODO use model here

      await imgFile.delete();
      print("file deleted....");
      //print("imgFile: $imgFile");
    }

    if (stop == 0) {
      Timer(Duration(seconds: 1), () {
        _capturePng();
      });
    }
  }

  @override
  void dispose() {
    stop = 1;
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    _capturePng();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, widget.channelName, null, UID);
    // await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      stop = 1;
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows(double width) {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        return Container(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Container(width: width, child: _expandedVideoRow([views[1]])),
              Container(width: width, child: _expandedVideoRow([views[0]]))
            ],
          ),
        );
      default:
    }
    return Container();
  }

  String searchedWord = "";
  List<Widget> alphabets = [];
  void learn(String word, double imgSize, double textSize) {
    word.runes.forEach((int rune) {
      var ch = new String.fromCharCode(rune);
      ch = ch.toLowerCase();
      if (ch != " ") {
        setState(() {
          alphabets.add(
            Column(
              children: [
                Image(
                  height: imgSize,
                  image: AssetImage("assets/images/$ch.png"),
                ),
                Text(
                  ch.toUpperCase(),
                  style: TextStyle(fontSize: textSize),
                )
              ],
            ),
          );
        });
      }
    });
    learnDialog();
  }

  Future<void> learnDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actionsPadding: EdgeInsets.all(0),
          content: Container(
            height: 350,
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: 200,
                      height: 300,
                      child: alpha(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget alpha() {
    if (alphabets.length != 0)
      return Carousel(
          boxFit: BoxFit.cover,
          images: alphabets,
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: Duration(milliseconds: 1500),
          showIndicator: false);
    else
      return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.black,
              size: 30.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Color(0xFF2EC4B6) : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 40.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Color(0xffE71D36),
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.black,
              size: 30.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffFF9F1C),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFF2EC4B6), size: 30),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'LetsSign',
            style: TextStyle(color: Colors.black, fontSize: 26),
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              _viewRows(constraints.maxWidth),
              _panel(),
              _toolbar(),
              Container(
                alignment: Alignment.topCenter,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 300,
                      height: 50,
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              if (searchedWord != "") {
                                alphabets = [];
                                setState(() {
                                  learn(searchedWord, 250, 20);
                                });
                              }
                            },
                          ),
                          labelText: 'Need a sign?',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        onChanged: (value) {
                          searchedWord = value;
                          if (value == "")
                            setState(() {
                              alphabets = [];
                            });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
