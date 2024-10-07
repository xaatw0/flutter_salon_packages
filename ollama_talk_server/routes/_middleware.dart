import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/objectbox.g.dart';
import 'package:ollama_talk_server/src/domain/server.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

const kBaseUrl = '192.168.1.33:5050/api';

final httpClient = http.Client();

final _client = TalkServer(
    httpClient,
    kBaseUrl,
    Store(getObjectBoxModel(), directory: 'object-box-dir'),
    OllamaServer(httpClient, kBaseUrl));

final storeProvider = provider<TalkServer>((context) => _client);

Handler middleware(Handler handler) {
  return handler.use(storeProvider);
}
