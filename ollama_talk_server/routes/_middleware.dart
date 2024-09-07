import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/objectbox.g.dart';
import 'package:ollama_talk_server/src/ollama_talk_client.dart';

const kBaseUrl = 'http://192.168.1.33:5050/api';

final _client = OllamaTalkClient(
  http.Client(),
  kBaseUrl,
  Store(getObjectBoxModel(), directory: 'object-box-dir'),
);

final storeProvider = provider<OllamaTalkClient>((context) => _client);

Handler middleware(Handler handler) {
  return handler.use(storeProvider);
}
