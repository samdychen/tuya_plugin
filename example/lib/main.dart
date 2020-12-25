import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuya_plugin/tuya_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TuyaPlugin _controller = new TuyaPlugin();
  Dio dio = new Dio();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String ssid;
  String password;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    hintText: "ssid"
                ),
                onSaved: (v){
                  setState(() {
                    ssid=v;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: "password"
                ),
                onSaved: (v){
                  setState(() {
                    password=v;
                  });
                },
              ),

              RaisedButton(
                child: Text('EC 配网'),
                onPressed: () {
                  _formKey.currentState.save();
                  dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "ay15956109400526lf4b"}).then((response) {
                    if(response.data["code"]==200){
                      print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
                      this._controller.setECNet(ssid, password,response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
                        Fluttertoast.showToast(msg: value.msg.toString());
                      });
                    }
                  });
                },
              ),
              RaisedButton(
                child: Text('Ap 配网'),
                onPressed: () {
                  _formKey.currentState.save();
                  dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "ay15956109400526lf4b"}).then((response) {
                    if(response.data["code"]==200){
                      print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
                      this._controller.setApNet(ssid, password,response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
                        Fluttertoast.showToast(msg: value.msg.toString());
                      });
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
