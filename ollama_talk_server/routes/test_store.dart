import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context) async {
  final ollamaTalkClient = await context.read<OllamaTalkClient>();

  final users = ollamaTalkClient.getUsers();
  final id = ollamaTalkClient.insertUser('name${users.length}');

  return Response(body: 'user was created: $id');
}
