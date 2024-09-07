import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/test_ws');
  final channel = WebSocketChannel.connect(uri);
  channel.sink.add('hello from the client');

  channel.stream.listen(
    (data) => print(data),
    onDone: () => print('closed'),
  );
}
