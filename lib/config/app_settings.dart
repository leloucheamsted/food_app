class AppSettings {
  AppSettings({
    required this.appName,
    required this.apiKey,
    required this.apiUrl,
    required this.xRapidapiHost,
    required this.xRapidapiKey,

//3 Days before rotating logs
  });

  String appName = '';
  String apiKey = '';
  String apiUrl = '';
  String xRapidapiHost = '';
  String xRapidapiKey = '';
}
