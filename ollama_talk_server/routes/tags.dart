import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/value_objects.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl http://localhost:11434/api/tags
/// curl -X GET http://localhost:8080/tags
Future<Response> onRequest(RequestContext context) async {
  final ollamaTalkClient = await context.read<OllamaTalkClient>();

  final models = await ollamaTalkClient.loadLocalModels();

  return Response.json(
      body: {"models": models.map((e) => e as LlmModel).toList()});
}
