import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/domain/commands/command.dart';

class GetWebPageCommand implements ICommand<String, String> {
  const GetWebPageCommand({
    required this.httpClient,
    this.baseUrl,
  });

  final String? baseUrl;
  final http.Client httpClient;

  @override
  FutureOr<String> execute(String data) {
    final uri =
        baseUrl == null ? Uri.parse(data) : Uri.parse(baseUrl!).resolve(data);
    return httpClient.get(uri).then((response) => response.body);
  }
}
