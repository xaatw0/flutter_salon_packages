import 'package:http/http.dart' as http;

class InfraInfo {
  const InfraInfo(this.httpClient, this.apiUrlBase);

  final http.Client httpClient;
  final String apiUrlBase;
}
