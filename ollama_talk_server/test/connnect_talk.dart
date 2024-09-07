import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/talk');
  final channel = WebSocketChannel.connect(uri);
  channel.sink.add('elyza:jp8b');
  channel.sink.add('Why is sky blue?');

  channel.stream.listen(
    (data) => print(data),
    onDone: () => print('closed'),
  );
}
