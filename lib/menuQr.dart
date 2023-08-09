import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpegsites/getdevices.dart';
import 'package:dio/dio.dart';
import 'clock/cloclview.dart';
import 'clockpainter.dart';
import 'encrypted/textterencrypt.dart';
import 'layout.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;

class MenuQrDart extends StatefulWidget {
  @override
  State<MenuQrDart> createState() => _MenuQrDartState();
}

class _MenuQrDartState extends State<MenuQrDart> {
  String? _lat, longt = '';
  var hasilArray = '';
  bool statusperizinan = false;
  var TmphasilArray = [];
  String _latitude = '0';
  String _longitude = '0';
  String rangze = '0';
  String? lat, lon, distancez, nama, ruang, nokar;
  int status = 0;

  Timer? qrCodeTimer;
  int countdown = 60; // Menit countdown
  void getnama() async {
    final prefs = await SharedPreferences.getInstance();
    nama = prefs.getString('Nama');
    ruang = prefs.getString('Ruang');
  }

  DateTime? lastQrCodeTimestamp; // Timestamp QR code terakhir dihasilkan
  void getrange() async {
    final url = "http://simrs.onthewifi.com:9192/konfigurasi";
    final dio = Dio();
    try {
      final response = await dio.get(url);
      final responseData = response.data;
      print(responseData);

      if (response.statusCode == 200) {
        setState(() {
          _latitude = responseData['data'][0]['LAT'];
          _longitude = responseData['data'][0]['LON'];
          distancez = responseData['data'][0]['TOLERANSI'];
          generateQrCode();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    nokar = prefs.getString('Nokar');
    final url =
        'http://simrs.onthewifi.com:9192/sdm/getkaryawan'; // URL yang sesuai
    final dio = Dio();

    try {
      final response = await dio.post(
        url,
        data: {"nokar": nokar},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['metadata']['code'] == 200) {
          // Data ditemukan
          final data = responseData['data'];
          print('Data respons: $data');
        } else if (responseData['metadata']['code'] == 404) {
          // Data tidak ditemukan
          print('Data tidak ada');
        }
      } else {
        print('Gagal mengirim data. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
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

  bool mock = false;

  void generateQrCode() async {
    var idx = getId();
    var position = await getCurrentLocation();
    setState(() {
      mock = position!.isMock!;
    });
    if (mock == true) {
      setState(() {
        status = 3;
        hasilArray = "kosong";
      });
    } else {
      double distance = calculateDistance(double.parse(_latitude),
          double.parse(_longitude), position!.latitude, position.longitude);
      if (distance <= double.parse(distancez!)) {
        setState(() {
          status = 1;
          _lat = position!.latitude.toString();
          longt = position.longitude.toString();
          TmphasilArray = [
            {
              'latitudeX': _lat,
              'longitudeX': longt,
              'deviceInfo': idx,
              'nokar': nokar,
              'timestamp': DateTime.now().toString(),
            }
          ];
          hasilArray = encryp(TmphasilArray.toString());
        });
      } else {
        setState(() {
          status = 2;
          hasilArray = "jauh";
        });
      }
    }

    lastQrCodeTimestamp =
        DateTime.now(); // Catat timestamp QR code terakhir dihasilkan
  }

  void startQrCodeTimer() {
    qrCodeTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      generateQrCode(); // Panggil fungsi generateQrCode setiap 1 menit
      setState(() {
        countdown =
            60; // Reset countdown ke 60 detik setelah menghasilkan QR code
      });
    });
  }

  void updateCountdown() {
    if (lastQrCodeTimestamp != null) {
      var now = DateTime.now();
      var difference = now.difference(lastQrCodeTimestamp!);
      setState(() {
        countdown = (60 - difference.inSeconds)
            .clamp(0, 60); // Hitung countdown yang tersisa
      });
    }
  }

  void startCountdownTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--; // Kurangi countdown setiap detik
        });
      } else {
        // Jika countdown habis, generate QR code
        generateQrCode();
        setState(() {
          countdown = 60; // Reset countdown ke 60 detik
        });
      }
    });
  }

  @override
  void initState() {
    getnama();

    getData();
    getrange();
    startQrCodeTimer(); // Memulai timer QR code
    startCountdownTimer(); // Memulai timer countdown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xffE9EEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 40,
                width: 160,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('rsummmi4.png'))),
              ),
              SizedBox(height: 20), // Spasi atas
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 16),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Color(0xff203268),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                                'http://simrs.onthewifi.com:9192/image/$nokar.png')),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            nama == null ? "mohon tunggu..." : "$nama",
                            style: TextStyle(
                                fontSize: 24, color: Color(0xff203268)),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            ruang == null ? "mohon tunggu..." : "$ruang",
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff203268)),
                          ),
                        ],
                      )
                    ],
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 15,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xffE9EEFF),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 13,
                                    offset: Offset(11, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: LayoutBuilder(
                      builder: (BuildContext, BoxConstraints) {
                        return Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                25,
                                (index) => SizedBox(
                                      width: 7,
                                      height: 2,
                                      child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Color(0xffC6C6C6))),
                                    )));
                      },
                    )),
                    Stack(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 15,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xffE9EEFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 13,
                                    offset: Offset(-11, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ), // Spasi atas
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Column(children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Scan Me",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: status == 0
                              ? Container(
                                  child: Text("Lokasi Belum Diizinkan"),
                                )
                              : status == 2
                                  ? Container(
                                      child: Text("Lokasi Terlalu Jauh"),
                                    )
                                  : status == 3
                                      ? Container(
                                          child:
                                              Text("Lokasi palsu Teredeteksi"),
                                        )
                                      : qr.QrImage(
                                          data: '$hasilArray',
                                          version: qr.QrVersions.auto,
                                          size: 450,
                                        ),
                        ),
                        SizedBox(
                            height: 10), // Spasi antara QR code dan countdown
                        Text(
                          "QR Code akan diperbarui dalam:",
                          style: TextStyle(
                              color: Color(0xfff203268), fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$countdown",
                          style: TextStyle(
                              color: Color(0xfff203268),
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ]),
              ),
              Container(
                height: 100,
                width: 250,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("Google_Play-Badge.png"))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
