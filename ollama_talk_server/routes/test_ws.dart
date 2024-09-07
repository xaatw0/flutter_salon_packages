import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      print('connected');

      // Send a message to the client.
      channel.sink.add('hello from the server #1');
      channel.sink.add('hello from the server #2');

      channel.sink.close();
    },
  );

  return handler(context);
}
