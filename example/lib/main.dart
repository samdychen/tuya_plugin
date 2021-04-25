import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuya_plugin/tuya_plugin.dart';
import 'wifi_picker.dart';
import 'package:system_setting/system_setting.dart';
import 'package:wifi/wifi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage()
    );
  }
}

// class _MyAppState extends State<MyApp> {
//   TuyaPlugin _controller = new TuyaPlugin();
//   Dio dio = new Dio();
//   final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
//   String ssid;
//   String password;
//   String token_region;
//   String token_token;
//   String token_secret;
//   String token_all;
//   String tuya_user_id = "ay1610868497240G8hqs";
//   String tuya_user_passwd = "331b005c778bebb65984708ee234ea5b";
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                     hintText: "ssid"
//                 ),
//                 onSaved: (v){
//                   setState(() {
//                     ssid=v;
//                   });
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                     hintText: "password"
//                 ),
//                 onSaved: (v){
//                   setState(() {
//                     password=v;
//                   });
//                 },
//               ),
//
//               RaisedButton(
//                   child: Text('uid 登陆'),
//                   onPressed: () {
//                     this._controller.uidLogin("86", this.tuya_user_id, this.tuya_user_passwd).then((value) {
//                       Fluttertoast.showToast(msg: value.msg.toString());
//                       print("接受到返回数据"+value.toString());
//                     });
//                   }
//               ),
//
//               RaisedButton(
//                 child: Text('获取设备配网token'),
//                 onPressed: () {
//                   _formKey.currentState.save();
//
//                   dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": this.tuya_user_id}).then((response) {
//                     if(response.data["code"]==200){
//                       print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
//                       this.token_region = response.data['data']['region'];
//                       this.token_token  = response.data['data']['token'];
//                       this.token_secret = response.data['data']['secret'];
//                       this.token_all = this.token_region + this.token_token + this.token_secret;
//                     }
//                   });
//                 },
//               ),
//
//               RaisedButton(
//                 child: Text('EC 配网'),
//                 onPressed: () {
//                   _formKey.currentState.save();
//                   // dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "az1610690682767tJ4ZJ"}).then((response) {
//                   //   if(response.data["code"]==200){
//                   //     print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
//                   //     this._controller.setECNet(ssid, password,response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
//                   //       Fluttertoast.showToast(msg: value.msg.toString());
//                   //     });
//                   //   }
//                   // });
//
//                   print(this.token_all);
//                   this._controller.setECNet("WeWork", "P@ssw0rd", this.token_all).then((value) {
//                     Fluttertoast.showToast(msg: value.msg.toString());
//                   });
//                 },
//               ),
//
//               RaisedButton(
//                 child: Text('Ap 配网'),
//                 onPressed: () {
//                   _formKey.currentState.save();
//
//                   // dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "az1610690682767tJ4ZJ"}).then((response) {
//                   //   if(response.data["code"]==200){
//                   //     print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
//                   //     this._controller.setApNet("WeWork", "P@ssw0rd", response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
//                   //       Fluttertoast.showToast(msg: value.msg.toString());
//                   //     });
//                   //   }
//                   // });
//
//                   //print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
//                   //WeWork, P@ssw0rd
//                   print(this.token_all);
//                   this._controller.setApNet("WeWork", "P@ssw0rd", this.token_all).then((value) {
//                     Fluttertoast.showToast(msg: value.msg.toString());
//                   });
//                 },
//               ),
//
//               RaisedButton(
//                 child: Text('销毁插件实例'),
//                 onPressed: () {
//                   _formKey.currentState.save();
//                   this._controller.destroy().then((value) {
//                     Fluttertoast.showToast(msg: "销毁插件实例成功");
//                   });
//                 },
//               ),
//
//               RaisedButton(
//                 child: Text('Wifi Demo'),
//                 onPressed: () {
//                   _formKey.currentState.save();
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => WifiPage()));
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  // 初始化涂鸦SDK插件
  TuyaPlugin _controller = new TuyaPlugin();

  // 初始化DIO对象
  Dio dio = new Dio();

  // 常量
  final String tuya_user_country_code = "86";
  final String tuya_user_id = "ay1610868497240G8hqs";
  final String tuya_user_passwd = "331b005c778bebb65984708ee234ea5b";
  final String pairing_token_api_url = "https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token";
  final String pairing_result_api_url = "https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_result";
  final String tuya_ap_ssid_prefix = "SmartLife";

  // 用户配置的wifi名称和密码
  String ssid;
  String password;
  TextEditingController ssid_controller = TextEditingController();

  String token_region;
  String token_token;
  String token_secret;
  String token_all;

  Timer looper;
  Timer ap_checker;

  @override
  void initState() {
    // 登陆tuya账号
    this._controller.uidLogin(this.tuya_user_country_code, this.tuya_user_id, this.tuya_user_passwd);
    super.initState();
  }

  @override
  void dispose() {
    if (looper != null) {
      looper.cancel();
    }
    if (_controller != null) {
      _controller.destroy();
    }
    super.dispose();
  }

  void loopPairingResult() {
    if (looper != null) {
      looper.cancel();
    }
    int __tot_time = 0;
    looper = Timer.periodic(Duration(seconds: 1), (timer) {
      __tot_time = __tot_time + 1;
      if (__tot_time > 300) {
        looper.cancel();
        return;
      }
      dio.post(this.pairing_result_api_url, data: {"pairing_token": this.token_token}).then((response) {
        if(response.data["code"]==200){
          print(response.data);
          // 检查是否配网成功
          if (response.data["data"]["success"].length > 0) {
            Fluttertoast.showToast(msg: "配网成功。开始添加设备到SPS, " + response.data["data"]["success"][0]["name"]);
            looper.cancel();
            this._controller.stopAP();
            this._controller.destroy();
          }

          // 检查是否配网失败
          if (response.data["data"]["failed"].length > 0) {
            Fluttertoast.showToast(msg: "配网失败");
            looper.cancel();
            this._controller.stopAP();
            this._controller.destroy();
          }

        }
      });
    });

  }

  /// 检查当前wifi连接，是否连接到了涂鸦设备的热点
  void loopCheckIsConnectToAP() {
    if (ap_checker != null) {
      ap_checker.cancel();
    }
    int __tot_time = 0;
    ap_checker = Timer.periodic(Duration(seconds: 1), (timer) async {
      __tot_time = __tot_time + 1;
      if (__tot_time > 300) {
        ap_checker.cancel();
        return;
      }

      String __cur_ssid = await Wifi.ssid;
      if (__cur_ssid.contains(this.tuya_ap_ssid_prefix)) {
        this._controller.setApNet(this.ssid, this.password, this.token_all).then((value) {
          Fluttertoast.showToast(msg: "发送wifi信息成功");
        });
        loopPairingResult();
        ap_checker.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuya HomeSDK Plugin Demo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20
          ),
          child: Column(
            children: [
              /// Step.1
              Offstage(
                offstage: false,
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Step.1 Config device into AP network configuration mode.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "arial",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Divider(
                color: Colors.black,
              ),

              /// Step.2
              Offstage(
                offstage: false,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Step.2 Config wifi name and password.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "arial",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      child: TextFormField(
                                        controller: ssid_controller,
                                        decoration: InputDecoration(
                                          // border: UnderlineInputBorder(),
                                            hintText: "wifi ssid name",
                                            icon: Icon(Icons.wifi),
                                            labelText: "Wifi Name"
                                        ),
                                        onSaved: (v){
                                          setState(() {
                                            ssid=v;
                                          });
                                        },
                                      ),
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.search),
                                        iconSize: 24,
                                        onPressed: () {
                                          print("打开选择wifi页面");
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => WifiPickerPage())).then(
                                              (_picked_ssid) {
                                                setState(() {
                                                  this.ssid_controller.text = _picked_ssid;
                                                });
                                              }
                                          );
                                        }
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          // border: UnderlineInputBorder(),
                                            hintText: "password",
                                            icon: Icon(Icons.lock_outline),
                                            labelText: "Wifi Password"
                                        ),
                                        onSaved: (v){
                                          setState(() {
                                            password=v;
                                          });
                                        },
                                      ),
                                    ),
                                    // RaisedButton(
                                    //     child: Text("扫描"),
                                    //     onPressed: () {
                                    //       print("打开选择wifi页面");
                                    //     }
                                    // )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RaisedButton(
                                  child: Text("保存"),
                                  onPressed: () {
                                    _formKey.currentState.save();
                                  }
                              )
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Divider(
                color: Colors.black,
              ),

              /// Step.3
              Offstage(
                offstage: false,
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Step.3 Fetch the user network pairing token",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "arial",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                        child: Text('获取设备配网token'),
                        onPressed: () {
                          dio.post(this.pairing_token_api_url, data: {"tuya_user_id": this.tuya_user_id}).then((response) {
                            if(response.data["code"]==200){
                              print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
                              this.token_region = response.data['data']['region'];
                              this.token_token  = response.data['data']['token'];
                              this.token_secret = response.data['data']['secret'];
                              this.token_all = this.token_region + this.token_token + this.token_secret;
                            }
                          });
                        }
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "If you have your phone connected by the VPN, you better disconnect the VPN before go forward",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontFamily: "arial",
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Divider(
                color: Colors.black,
              ),

              /// Step.4
              Offstage(
                offstage: false,
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Step.4 Connect to the device AP HotPot",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "arial",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                          child: Text('连接设备AP热点'),
                          onPressed: () async {
                            print("打开wifi连接页面");
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => WifiPickerPage(onlyPickName: false, ssidFilter: "SmartLife",))).then(
                            //   (is_connected) {
                            //     print(is_connected);
                            //     this._controller.setApNet(this.ssid, this.password, this.token_all).then((value) {
                            //       Fluttertoast.showToast(msg: value.msg.toString());
                            //     });
                            //     /// 开始轮询配网结果
                            //     this.loopPairingResult();
                            //   }
                            // );

                            await SystemSetting.goto(SettingTarget.WIFI);

                            loopCheckIsConnectToAP();

                          }
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Divider(
                color: Colors.black,
              ),

              /// Step.5
              Offstage(
                offstage: false,
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Step.5 Automatically sending the wifi info to the device, and keep checking the net paring result.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "arial",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                        child: Text('开始发送wifi信息'),
                        onPressed: () {
                          print(this.token_all);
                          this._controller.setApNet(this.ssid, this.password, this.token_all).then((value) {
                            Fluttertoast.showToast(msg: "发送wifi信息成功");
                          });
                        },
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        )
      ),

      // Form(
      //   key: _formKey,
      //   child: Column(
      //     children: [
      //       TextFormField(
      //         decoration: InputDecoration(
      //             hintText: "ssid"
      //         ),
      //         onSaved: (v){
      //           setState(() {
      //             ssid=v;
      //           });
      //         },
      //       ),
      //       TextFormField(
      //         decoration: InputDecoration(
      //             hintText: "password"
      //         ),
      //         onSaved: (v){
      //           setState(() {
      //             password=v;
      //           });
      //         },
      //       ),
      //
      //       RaisedButton(
      //           child: Text('uid 登陆'),
      //           onPressed: () {
      //             this._controller.uidLogin("86", this.tuya_user_id, this.tuya_user_passwd).then((value) {
      //               Fluttertoast.showToast(msg: value.msg.toString());
      //               print("接受到返回数据"+value.toString());
      //             });
      //           }
      //       ),
      //
      //       RaisedButton(
      //         child: Text('获取设备配网token'),
      //         onPressed: () {
      //           _formKey.currentState.save();
      //
      //           dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": this.tuya_user_id}).then((response) {
      //             if(response.data["code"]==200){
      //               print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
      //               this.token_region = response.data['data']['region'];
      //               this.token_token  = response.data['data']['token'];
      //               this.token_secret = response.data['data']['secret'];
      //               this.token_all = this.token_region + this.token_token + this.token_secret;
      //             }
      //           });
      //         },
      //       ),
      //
      //       RaisedButton(
      //         child: Text('EC 配网'),
      //         onPressed: () {
      //           _formKey.currentState.save();
      //           // dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "az1610690682767tJ4ZJ"}).then((response) {
      //           //   if(response.data["code"]==200){
      //           //     print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
      //           //     this._controller.setECNet(ssid, password,response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
      //           //       Fluttertoast.showToast(msg: value.msg.toString());
      //           //     });
      //           //   }
      //           // });
      //
      //           print(this.token_all);
      //           this._controller.setECNet("WeWork", "P@ssw0rd", this.token_all).then((value) {
      //             Fluttertoast.showToast(msg: value.msg.toString());
      //           });
      //         },
      //       ),
      //
      //       RaisedButton(
      //         child: Text('Ap 配网'),
      //         onPressed: () {
      //           _formKey.currentState.save();
      //
      //           // dio.post("https://us-central1-my-first-action-project-96da6.cloudfunctions.net/get_tuya_pairing_token", data: {"tuya_user_id": "az1610690682767tJ4ZJ"}).then((response) {
      //           //   if(response.data["code"]==200){
      //           //     print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
      //           //     this._controller.setApNet("WeWork", "P@ssw0rd", response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']).then((value) {
      //           //       Fluttertoast.showToast(msg: value.msg.toString());
      //           //     });
      //           //   }
      //           // });
      //
      //           //print(response.data['data']['region']+response.data['data']['token']+response.data['data']['secret']);
      //           //WeWork, P@ssw0rd
      //           print(this.token_all);
      //           this._controller.setApNet("WeWork", "P@ssw0rd", this.token_all).then((value) {
      //             Fluttertoast.showToast(msg: value.msg.toString());
      //           });
      //         },
      //       ),
      //
      //       RaisedButton(
      //         child: Text('销毁插件实例'),
      //         onPressed: () {
      //           _formKey.currentState.save();
      //           this._controller.destroy().then((value) {
      //             Fluttertoast.showToast(msg: "销毁插件实例成功");
      //           });
      //         },
      //       ),
      //
      //       RaisedButton(
      //         child: Text('Wifi Demo'),
      //         onPressed: () {
      //           _formKey.currentState.save();
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => WifiPage()));
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}