class UnauthenticatedException implements Exception {}

class API {
  static const String apiScheme = "https";
  static const String apiHost = "courses.example.net";
  static const String apiUrl = "$apiScheme://$apiHost/api";
}
