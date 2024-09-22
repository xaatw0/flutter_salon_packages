import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

///
Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.post => _onPost(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e) {
    return Future.value(
      Response(statusCode: HttpStatus.internalServerError, body: e.toString()),
    );
  }
}

Future<Response> _onPost(RequestContext context) async {
  final request = context.request;
  final formData = await request.formData();

  final fileName = formData.fields['file_name'];
  if (fileName == null) {
    return Response(
        statusCode: HttpStatus.badRequest, body: 'file_name is not exist');
  }
  context.read<OllamaTalkServer>().removeDocument(fileName);
  return Response.json(
    body: {'message': 'Success'},
  );
}
