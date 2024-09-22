import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl  http://localhost:8080/test_store
Future<Response> onRequest(RequestContext context) async {
  final ollamaTalkClient = await context.read<OllamaTalkServer>();

  final users = ollamaTalkClient.getUsers();

  return Response(body: '${users.length} users are registered');
}
