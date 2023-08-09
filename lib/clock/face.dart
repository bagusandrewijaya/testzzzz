import 'dart:async';
import 'dart:math';


import 'package:flutter/material.dart';
import 'package:simpegsites/clock/dial_painer.dart';

class ClockFace extends StatefulWidget {
  @override
  _ClockFaceState createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  Timer? _timer;
  DateTime? dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = new DateTime.now();
    _timer = new Timer.periodic(const Duration(seconds: 1), setTime);
  }

  void setTime(Timer timer) {
    setState(() {
      dateTime = new DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
  // DateTime dateTime = calculateRandomTime();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: GestureDetector(
            onTap: () {
              // Scaffold.of(context).removeCurrentSnackBar();
              // var snackebar = createSnackBar(dateTime);
              // Scaffold.of(context).showSnackBar(snackebar);
            },
            // onDoubleTap: () {
            //   setState(() {
            //     dateTime = calculateRandomTime();
            //   });
            // },
            child: Stack(
              children: <Widget>[
                //dial and numbers go here
                new Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  child: new CustomPaint(
                    painter: new ClockDialPainter(clockText: ClockText.arabic),
                  ),
                ),

                //clock hands go here
                // the point in the middle
                Centerpoint(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

SnackBar createSnackBar(DateTime date) {
  TimeOfDay time = TimeOfDay.fromDateTime(date);
  int myhour = time.hour == 0 ? 12 : time.hour;

  var snackbar = SnackBar(
    content: Text("$myhour:${time.minute}"),
    action: SnackBarAction(
      label: 'Done',
      onPressed: () {},
    ),
  );
  return snackbar;
}

class Centerpoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 15.0,
        height: 15.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
      ),
    );
  }
}

DateTime calculateRandomTime() {
  int newHour = Random().nextInt(13);
  var newMinute = Random().nextInt(61);
  var datae = DateTime.now();
  DateTime time = datae.toLocal();
  time = new DateTime(
      time.year, time.month, time.day, newHour, newMinute, 0, 0, 0);
  return time;
}