import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final documentId = int.parse(id);
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, documentId),
    HttpMethod.delete => _onDelete(context, documentId),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, int documentId) async {
  final entity = await context.read<OllamaTalkClient>().getDocument(documentId);
  if (entity == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: entity);
}

Future<Response> _onDelete(RequestContext context, int id) async {
  final isDeleted = await context.read<OllamaTalkClient>().deleteDocument(id);

  return Response(
      statusCode: isDeleted ? HttpStatus.noContent : HttpStatus.notFound);
}
