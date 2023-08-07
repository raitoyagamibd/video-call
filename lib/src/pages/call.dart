import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../utils/settings.dart';

class CallPage extends StatefulWidget{
  final String? channelName;
  final String? token;
  final ClientRoleType? role;
  const CallPage({
    Key? key,
    this.channelName,
    this.token,
    this.role,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage>{
  int? _user;
  final _infoStrings = <String>[];
  bool muted = false;
  bool cameraOff = false;
  bool viewPanel = false;
  late RtcEngine _engine ;


  @override
  void initState(){
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _user = null;
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> initialize() async {
    if(appId.isEmpty) {
      setState(() {
        _infoStrings.add('App_ID missing, please provide your app id in settings.dart');
        _infoStrings.add('Agora Engine is not starting');
      
      });
      return;
    }
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId
    ));

     await _engine.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await _engine.enableVideo();  
    await _engine.setClientRole(role: widget.role!);
    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    _addAgoraEventHandlers();
    await _engine.joinChannel(
      token: widget.token!,
      channelId: widget.channelName!,
      uid: 0,
      options: options,
    );
  }

  void _addAgoraEventHandlers() {
   _engine.registerEventHandler(
    RtcEngineEventHandler(
       onError: (err, msg) => {
        setState(() {
          final info = 'Error: ' + msg;
          _infoStrings.add(info);
        })
       },
       onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          final info = 'Joint Channel: ${connection.channelId}, ${connection.localUid}';
          _infoStrings.add(info);
        });
       },
       onLeaveChannel: (connection, stats) {
        setState(() {
          _infoStrings.add("Leave Chamnel");
          _user = null;
        });
       },
       onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
            _user = remoteUid;
        });
        },
       onUserOffline: (connection, remoteUid, reason) {
        final info = 'User offline: ${remoteUid}';
        _infoStrings.add(info);
                  _user = null;

       },
       onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
        setState(() {
          final info = 'First Remote Video: ${remoteUid} ${width} x ${height}';
          _infoStrings.add(info);
        });
       }
    ),
    );
  }

  Widget _viewRows() {
    final List<Widget> list =[];
    if(widget.role == ClientRoleType.clientRoleBroadcaster){
      list.add(AgoraVideoView(
        controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
        ),
    ));
    }
    if(_user != null){
      list.add(AgoraVideoView(
        controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _user),
        connection: RtcConnection(channelId: widget.channelName!),
        ),
    ));
    }

    final views = list;

    return Column(
      children: List.generate(
        views.length,
        (index) => Expanded(
          child: views[index],
        )
      ),
    );
    
  }

 

  Widget _toolbar(){

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () {
              setState(() {
                cameraOff = !cameraOff;
              });
              _engine.muteLocalVideoStream(cameraOff);
            },
            child: Icon(
              cameraOff ? Icons.videocam_off : Icons.videocam,
              color: cameraOff ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: cameraOff ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      )
    );
  }

  @override
  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                viewPanel = !viewPanel;
              });
            },
            icon: const Icon(Icons.info_outline),
          )
        ]
      ),
      backgroundColor: Colors.black,
      body: Center(child: Stack(
        children: <Widget>[
          _viewRows(),
          _toolbar()
        ],
      )),
    );
  }
}