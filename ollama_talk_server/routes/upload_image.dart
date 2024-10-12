import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

///
/// curl --request POST \
///   --url http://localhost:8080/upload_image \
///   --form photo=@image.png
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  final formData = await request.formData();

  final photo = formData.files['photo'];
  final data = photo?.readAsBytes();

  if (photo == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  return Response.json(
    body: {
      'message': 'Successfully uploaded ${photo.name} ${(await data)?.length}'
    },
  );
}
