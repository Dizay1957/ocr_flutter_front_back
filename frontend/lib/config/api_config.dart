import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081'; // Android emulator localhost
    } else if (Platform.isIOS) {
      return 'http://localhost:8081'; // iOS simulator
    } else {
      return 'http://localhost:8081'; // Web/desktop
    }
  }

  static const String uploadEndpoint = '/api/documents/upload';
}
