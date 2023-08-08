import 'package:flutter/material.dart';

import 'menuQr.dart';

class CheckNikBeforeMenu extends StatefulWidget {
  const CheckNikBeforeMenu({Key? key}) : super(key: key);

  @override
  State<CheckNikBeforeMenu> createState() => _CheckNikBeforeMenuState();
}

class _CheckNikBeforeMenuState extends State<CheckNikBeforeMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Masukkan NIK Anda',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // Tombol
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => MenuQrDart()));
              },
              child: Text('Cek NIK'),
            ),
          ],
        ),
      ),
    );
  }
}
