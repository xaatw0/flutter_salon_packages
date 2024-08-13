import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/value_objects.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context) async {
  final ollamaTalkClient = await context.read<Future<OllamaTalkClient>>();

  final models = await ollamaTalkClient.loadLocalModels();
  final jsonData =
      models.map((e) => e as LlmModel).map((e) => e.toJson()).join('", "');

  return Response(body: '{"models": ["$jsonData"]}');
}
