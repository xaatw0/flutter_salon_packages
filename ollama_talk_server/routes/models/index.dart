import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

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

Response _onGet(RequestContext context) {
  return Response.json(
    body: {'message': 'success'},
  );
}

Response _onPost(RequestContext context) {
  return Response.json(
    body: {'message': 'success'},
  );
}
