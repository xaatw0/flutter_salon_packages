import 'dart:async';
import 'dart:convert';

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

    final data = SendChatMessageEntity(chatId: chatId, prompt: prompt);

    channel.sink.add(jsonEncode(data.toJson()));
    return controller.stream;
  }

  Future<List<ChatModel>> loadChatList() async {
    final apiPath = '/chat';
    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);
    final list = (jsonDecode(json['chat_list']) as List<dynamic>)
        .map((e) => ChatModel.fromJson(e))
        .toList();
    return list;
  }

  Future<ChatModel> loadChat(int chatId) async {
    final apiPath = '/chat/$chatId';
    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');

    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);
    final data = ChatModel.fromJson(json);
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
}
