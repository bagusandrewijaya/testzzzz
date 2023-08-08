import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();

  try {
    WebBrowserInfo? webBrowserInfo = await deviceInfo.webBrowserInfo;

    if (webBrowserInfo != null) {
      String userAgent = webBrowserInfo.userAgent ?? '';
      return userAgent;
    } else {
      return null; // Jika informasi tidak tersedia
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
