import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import './call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  final _chanelController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _validateError = false;
  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;

  @override
  void dispose() {
    _chanelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: const Text('Agora'),
      centerTitle: true,
    ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: <Widget>[
            const SizedBox(height: 40),
            Image.network('https://tinyurl.com/2p889y4k'),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                errorText: _validateError ? 'Token is mandatory' : null,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
                hintText: 'Token',
              ),
            ),
            TextField(
              controller: _chanelController,
              decoration: InputDecoration(
                errorText: _validateError ? 'Chanal name is mandatory' : null,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
                hintText: 'Chanel name',
              ),
            ),
            RadioListTile(
              title: const Text('Broadcaster'),
              onChanged: (ClientRoleType? value) {
                setState(() {
                  _role = value;
                });
              },
              value: ClientRoleType.clientRoleBroadcaster,
              groupValue: _role,
            ),
            RadioListTile(
              title: const Text('Audience'),
              onChanged: (ClientRoleType? value) {
                setState(() {
                  _role = value;
                });
              },
              value: ClientRoleType.clientRoleAudience,
              groupValue: _role,
            ),
            ElevatedButton(onPressed: onJoin, child: const Text('Join'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40),))
          ]),
          )),
    );

  }

  Future<void> onJoin() async {
    setState(() {
      _chanelController.text.isEmpty ? _validateError = true : _validateError = false;
    });
    if(_chanelController.text.isNotEmpty){
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: _chanelController.text,
          token: _tokenController.text,
          role: _role,
        )));
    }
  }

  Future<void>  _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }

}