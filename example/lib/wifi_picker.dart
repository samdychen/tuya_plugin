import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/wifi.dart';

class WifiPickerPage extends StatefulWidget {
  WifiPickerPage({
    Key key,
    this.onlyPickName = true,
    this.ssidFilter,
  }) : super(key: key);

  // 是否只选择wifi名称，不执行连接操作
  final bool onlyPickName;
  final String ssidFilter;

  @override
  _WifiPickerPageState createState() => new _WifiPickerPageState();
}

class _WifiPickerPageState extends State<WifiPickerPage> {
  int level = 0;

  List<WifiResult> ssidList = [];
  String selected_ssid = '';

  String current_connected_wifi_ssid = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wifi Picker'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: ssidList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return itemSSID(index);
          },
        ),
      ),
    );
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Container();
    } else {
      if (ssidList[index - 1].ssid != "") {
        return GestureDetector(
          onTap: () {
            if (widget.onlyPickName) {
              Navigator.pop(context, ssidList[index - 1].ssid);
            } else {
              this.connect_to_wifi(ssidList[index - 1].ssid, null);
            }
          },
          child: Column(children: <Widget>[
            ListTile(
              leading: Image.asset('images/wifi${ssidList[index - 1].level}.png', width: 28, height: 21),
              title: Text(
                ssidList[index - 1].ssid,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                ),
              ),
              dense: true,
            ),
            Divider(),
          ]),
        );
      } else {
        Container();
      }

    }
  }

  void loadData() async {
    String __filter = '';
    if (widget.ssidFilter != null) {
      __filter = widget.ssidFilter;
    }
    Wifi.list(__filter).then((list) {
      setState(() {
        List<WifiResult> __ssidList = [];
        list.forEach((e) {
          if (e.ssid != "") {
            __ssidList.add(e);
          }
        });
        ssidList = __ssidList;
      });
    });
  }

  Future<Null> _getWifiName() async {
    int l = await Wifi.level;
    String wifiName = await Wifi.ssid;
    setState(() {
      level = l;
      current_connected_wifi_ssid = wifiName;
    });
  }

  // Future<Null> _getIP() async {
  //   String ip = await Wifi.ip;
  //   setState(() {
  //     _ip = ip;
  //   });
  // }

  Future<Null> connect_to_wifi(String ssid, String password) async {
    Wifi.connection(ssid, password).then((v) {
      print(v);
      Navigator.pop(context, true);
    }).catchError((error) {
      Navigator.pop(context, false);
    });
  }
}