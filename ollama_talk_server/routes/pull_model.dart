import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl http://localhost:11434/api/pull -d '{ "name": "mxbai-embed-large"}'
///  curl --request POST --url  http://localhost:8080/pull_model --data name=test
Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
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

Future<Response> _onPost(RequestContext context) async {
  final formData = await context.request.formData();
  final modelName = formData.fields['name'];
  if (modelName == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'No "name" field'});
  }
  final result = context.read<OllamaTalkClient>().pullModel(modelName);

  return Response.json(
    body: {'message': await result ? 'Success' : 'Failure'},
  );
}
