import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

///
/// curl -X POST -F file=@test.txt -F 'memo=めも' http://localhost:8080/insert_document
///
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.badRequest)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final request = context.request;

  final formData = await request.formData();
  final file = formData.files['file'];
  if (file == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final memo = formData.fields['memo'] ?? 'No information';
  final ollamaTalkClient = await context.read<TalkServer>();

  final fileData = utf8.decode(await file.readAsBytes());

  //final jsonData = jsonDecode(await context.request.json());
  try {
    await ollamaTalkClient.insertDocument(file.name, fileData, memo);
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.badRequest, body: {'message': '$e'});
  }
  return Response.json(
    body: {'message': 'Success'},
  );
}
