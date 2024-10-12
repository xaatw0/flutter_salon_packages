import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// curl http://localhost:8080/test/get/1
Future<Response> onRequest(RequestContext context, String id) async {
  print('test $id');
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context),
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context) async {
  return Response.json(
    body: {'message': 'Success'},
  );
}

Future<Response> _onPost(RequestContext context) async {
  return Response.json(
    body: {'message': 'Success'},
  );
}
