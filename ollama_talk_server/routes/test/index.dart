import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/infrastructures/object_box/test_box.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

// curl  http://localhost:8080/test
// curl  http://192.168.1.33:8080/test
Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.get => _onGet(context),
      HttpMethod.post => _onPost(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e) {
    return Future.value(Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    ));
  }
}

Future<Response> _onGet(RequestContext context) async {
  final store = context.read<TalkServer>().store;

  final box = TestBox(name: 'name1');
  final box2 = TestBox(name: 'name2');
  final result = box.save(store);
  box2.save(store);
  await result;

  return Response.json(
    body: {'message': 'Success'},
  );
}

Future<Response> _onPost(RequestContext context) async {
  return Response.json(
    body: {'message': 'Success'},
  );
}
