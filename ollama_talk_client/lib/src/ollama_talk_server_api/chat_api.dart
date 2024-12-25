import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ollama_talk_client/ollama_talk_client.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatApi {
  ChatApi(this.infraInfo);

  final InfraInfo infraInfo;

  Stream<String> sendMessage(int chatId, String prompt) {
    final apiPath = '/send_message';

    final url = Uri.parse('ws://${infraInfo.apiUrlBase}$apiPath');

    final channel = WebSocketChannel.connect(url);

    final controller = StreamController<String>();
    channel.stream.listen(
      (data) => controller.sink.add(data.toString()),
      onDone: () => controller.sink.close(),
    );

    // サーバに初期設定を送る
    final data = SendChatMessageEntity(chatId: chatId, prompt: prompt);
    channel.sink.add(jsonEncode(data.toJson()));

    return controller.stream;
  }

  Future<String> sendMessageAsFuture(int chatId, String prompt) async {
    final apiPath = '/send_message_as_future';

    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final body = {'id': chatId, 'prompt': prompt};
    final response = await infraInfo.httpClient.post(url,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(body));
    final json = jsonDecode(response.body);
    return json['data'];
  }

  Future<String> sendMessageWithAgent(int chatId, String prompt) async {
    final apiPath = '/send_message_with_agents2';

    final url = Uri.parse('ws://${infraInfo.apiUrlBase}$apiPath');

    final channel = WebSocketChannel.connect(url);

    final completer = Completer<String>();
    final buffer = StringBuffer();
    channel.stream.listen(
      (data) => buffer.write(data.toString()),
      onDone: () => completer.complete(buffer.toString()),
    );
    // サーバに初期設定を送る
    final data = SendChatMessageEntity(chatId: chatId, prompt: prompt);
    channel.sink.add(jsonEncode(data.toJson()));

    return completer.future;
  }

  Future<List<ChatEntity>> loadChatList() async {
    final apiPath = '/chat';
    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);
    final list = (jsonDecode(json['chat_list']) as List<dynamic>)
        .map((e) => ChatEntity.fromJson(e))
        .toList();
    return list;
  }

  Future<ChatEntity> loadChat(int chatId) async {
    final apiPath = '/chat/$chatId';
    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);
    final data = ChatEntity.fromJson(json);
    return data;
  }

  Future<int> openChat(LlmModel llmModel, String systemMessage) async {
    final apiPath = '/open_chat';
    final url = Uri.parse(
        'http://${infraInfo.apiUrlBase}$apiPath?model=${llmModel()}&system=${Uri.encodeFull(systemMessage)}');

    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);
    if (response.statusCode == 400) {
      throw Exception(json['message']);
    }

    final chatId = json['chat_id'];
    return chatId;
  }

  Future<ChatEntity> updateTitle(int chatId, String title) async {
    final apiPath = '/chat/$chatId';
    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final chat = ChatEntity(
        id: chatId, title: title, llmModel: '', system: '', messages: []);
    final body = chat.toJson()
      ..removeWhere((_, value) => value != title && value != chatId);

    final response =
        await infraInfo.httpClient.post(url, body: jsonEncode(body));
    final json = jsonDecode(response.body);
    if (response.statusCode == HttpStatus.ok) {
      return ChatEntity.fromJson(json);
    }
    throw Exception(json['message']);
  }
}
