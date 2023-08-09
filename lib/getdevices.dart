import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();

  try {
    IosDeviceInfo? informasiPerangkat = await deviceInfo.iosInfo;

    if (informasiPerangkat != null) {
      String userAgent = informasiPerangkat.identifierForVendor ?? '';
      return userAgent;
    } else {
      return null; // Jika informasi tidak tersedia
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
