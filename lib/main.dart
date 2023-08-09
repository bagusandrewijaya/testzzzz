import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as prf;
import 'package:simpegsites/login.dart';

import 'checkNik.dart';
import 'menuQr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainRoutes());
  }
}

class MainRoutes extends StatefulWidget {
  const MainRoutes({super.key});

  @override
  State<MainRoutes> createState() => _MainRoutesState();
}

class _MainRoutesState extends State<MainRoutes> {
  bool? islogin;
  void prefsCheck() async {
    final prefs = await prf.SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
    });
    print("is login anda ////////////////////////////////////// $islogin");
  }

  @override
  void initState() {
    prefsCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return islogin == true ? MenuQrDart() : LoginPages();
  }
}
