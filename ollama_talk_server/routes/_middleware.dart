import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/objectbox.g.dart';
import 'package:ollama_talk_server/src/server.dart';

const kBaseUrl = 'http://192.168.1.33:5050/api';

final _client = OllamaTalkServer(
  http.Client(),
  kBaseUrl,
  Store(getObjectBoxModel(), directory: 'object-box-dir'),
);

final storeProvider = provider<OllamaTalkServer>((context) => _client);

Handler middleware(Handler handler) {
  return handler.use(storeProvider);
}
