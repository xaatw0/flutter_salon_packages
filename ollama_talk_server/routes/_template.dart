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

///
Response _onGet(RequestContext context) {
  final value = context.request.uri.queryParameters['value'];
  return Response.json(
    body: {'message': 'success'},
  );
}

Future<Response> _onPost(RequestContext context) async {
  final formData = await context.request.formData();
  final name = formData.fields['name'];

  return Response.json(
    body: {'message': 'success'},
  );
}
