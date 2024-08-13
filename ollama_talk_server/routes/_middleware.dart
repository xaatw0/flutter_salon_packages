import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/objectbox.g.dart';
import 'package:ollama_talk_server/src/ollama_talk_client.dart';

const kBaseUrl = 'http://localhost:11434/api';

final storeProvider = provider<Future<OllamaTalkClient>>((context) async {
  final store = Store(getObjectBoxModel(), directory: 'object-box-dir');
  return OllamaTalkClient(http.Client(), kBaseUrl, await store);
});

Handler middleware(Handler handler) {
  return handler.use(storeProvider);
}
