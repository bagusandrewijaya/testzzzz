import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout.dart';
import 'package:toasty_snackbar/toasty_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart' as prf;
import 'menuQr.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  TextEditingController nikController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  String apiUrl =
      'http://simrs.onthewifi.com:9192/sdm/getkaryawan'; // Ganti dengan URL API yang sesuai

  void loginUser() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'nokar': nikController.text,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        final Map<String, dynamic> metadata = responseData['metadata'];
        if (metadata['code'] == 200) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MenuQrDart()));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('islogin', true);
          await prefs.setString('Nama', responseData['data'][0]['NAMA']);
          await prefs.setString('Ruang', responseData['data'][0]['RUANG']);
          await prefs.setString('Nokar', nikController.text);
          // Contoh: Navigasi ke halaman utama aplikasi
        } else {
          context.showToastySnackbar("Gagal", "Gagal Login", AlertType.error);
        }
      } else {
        // Tangani status code selain 200
        print(
            'Terjadi kesalahan saat melakukan request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Tangani error yang mungkin terjadi saat request
      print('Terjadi kesalahan saat melakukan request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 5),
        width: double.infinity,
        child: Column(
          // physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 30, left: 39),
              height: SizeConfig.blockSizeVertical! * 60,
              width: SizeConfig.blockSizeVertical! * 70,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('screenfix.png')),
              ),
              child: Text(
                'Silahkan Login\nUntuk Melanjutkan',
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Color(0xff203268),
                      fontSize: 30,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 10.8, left: 28.8, right: 28.8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                child: Column(children: <Widget>[
                  TextFormField(
                    controller: nikController,
                    // Text field NIK (Nomor Induk Karyawan)
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical:
                              30), // Atur nilai vertical untuk mengatur tinggi
                      hintText: "Nomor Karyawan",
                      labelText: "Nomor Karyawan",
                      // icon: Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // InkWell(
                      //   // Link ke reset password
                      //   onTap: () {},
                      //   child: Text("Lupa Password ?",
                      //       style: GoogleFonts.poppins(
                      //           fontWeight: FontWeight.w500,
                      //           fontSize: 13,
                      //           color: Color(0xff203268))),
                      // )
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    child: Container(
                      width: SizeConfig.blockSizeVertical! * 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xff203268),
                      ),
                      alignment: Alignment.center,
                      height: SizeConfig.blockSizeVertical! * 6,
                      child: Text(
                        "Masuk",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    onTap: () {
                      loginUser();
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text("Belum punya akun ? ",
                          //     style: GoogleFonts.poppins(
                          //         fontSize: 14, fontWeight: FontWeight.w500)),
                          // InkWell(
                          //   onTap: () {},
                          //   child: Text("Daftar Disini",
                          //       style: GoogleFonts.poppins(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w500,
                          //           color: Color(0xff203268))),
                          // )

                          Container(
                            height: 50,
                            width: SizeConfig.blockSizeHorizontal! * 70,
                            alignment: Alignment.topCenter,
                            margin: EdgeInsets.all(10),
                            child: Text(
                              "Jika belum memiliki akun silahkan hubungi bagian HRD RS UMMI bogor",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                  Container(
                    height: 100,
                    width: 250,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("Google_Play-Badge.png"))),
                  )
                ]))

            // custom nav
          ],
        ),
      ),
    );
  }
}
