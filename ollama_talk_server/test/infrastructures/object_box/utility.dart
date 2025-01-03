import 'package:ollama_talk_server/objectbox.g.dart';

Future<Store> getStore() async {
  await Future.delayed(const Duration(milliseconds: 10));
  return openStore(
      directory: 'memory:object-box-${DateTime.now().millisecondsSinceEpoch}');
}
