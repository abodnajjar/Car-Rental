class ApiConfig {
  // Point this to where the FastAPI server is reachable from your device/browser.
  // - Flutter web on the same machine: http://127.0.0.1:8000
  // - Android emulator: http://10.0.2.2:8000
  // - iOS simulator: http://127.0.0.1:8000
  // - Physical device: use your machine LAN IP (e.g., http://192.168.x.x:8000)
  static const String baseUrl = 'http://127.0.0.1:8000';
}