import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:simpegsites/getdevices.dart';
import 'package:dio/dio.dart';
import 'layout.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;

class MenuQrDart extends StatefulWidget {
  @override
  State<MenuQrDart> createState() => _MenuQrDartState();
}

class _MenuQrDartState extends State<MenuQrDart> {
  String? _lat, longt = '';
  var hasilArray = [];
  double _latitude = 0;
  double _longitude = 0;
  String rangze = '0';
  String? lat, lon;
  String? res;
  int status = 0;

  void getData() async {
    final response = await http.post(
      Uri.parse("http://api.rsummi.co.id:1842/Production/sdm/cekconfigurasi"),
      headers: {
        'Access-Control-Allow-Origin': '*', // Tambahkan header ini
        'Content-Type': 'application/json', // Contoh header lainnya
      },
    );
    print(jsonDecode(response.body));
    setState(() {
      res = jsonDecode(response.body);
    });
  }

  Future<LocationData?> getCurrentLocation() async {
    var location = Location();
    bool serviceEnabled;
    PermissionStatus permission;

    /// check mock location on Android device.
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  void checklocation() async {
    var position = await getCurrentLocation();
    double distance = calculateDistance(double.parse(lat!), double.parse(lon!),
        position!.latitude, position.longitude);
    bool? mock = position!.isMock;
    if (mock == true) {
      setState(() {
        status = 3;
      });
    } else {
      if (distance <= double.parse(rangze)) {
        setState(() {
          status = 1;
          _latitude = position.latitude!;
          _longitude = position.latitude!;
        });
      } else {
        setState(() {
          status = 2;
        });
      }
    }

    print(position.latitude);
    print(position.longitude);
    print(status);
    print("lat anda $lat");
    print("lon anda $lon");
  }

  void checkloc() async {
    var idx = await getId();
    var position = await getCurrentLocation();

    setState(() {
      _lat = position!.latitude.toString();
      longt = position!.longitude.toString();
      hasilArray = [
        {
          'latitude': _lat,
          'longitude': longt,
          'deviceInfo': idx,
          'nokar': "asdadad"
        }
      ];
    });

    print('Longitude: ${position!.longitude}');

    var hasilJson = jsonEncode(hasilArray);
    print(hasilJson);
  }

  @override
  void initState() {
    checkloc();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xff203268),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Spasi atas
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://cdn.icon-icons.com/icons2/2550/PNG/512/user_circle_icon_152504.png'),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                    Text(
                      "Bagus Andre Wijaya",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              SizedBox(
                  height: SizeConfig.blockSizeVertical! *
                      20), // Spasi antara kontainer
              Center(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: qr.QrImage(
                    data: '$hasilArray',
                    version: qr.QrVersions.auto,
                    size: 450,
                  ),
                ),
              ),

              Center(
                child: Column(children: [
                  Text("lat : $res"),
                  Text("lat : $longt"),
                ]),
              )
              // Add more containers here if needed
            ],
          ),
        ),
      ),
    );
  }
}
