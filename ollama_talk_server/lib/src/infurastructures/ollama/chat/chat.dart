import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';

class Chat {
  const Chat(
    this.llmModel,
    this.chat,
    this.messages,
  );

  final ChatEntity chat;
  final List<ChatMessageEntity> messages;
  final LlmModel llmModel;

  factory Chat.create(LlmModel llmModel, {String systemMessage = ''}) {
    final chat = ChatEntity(
      llmModel: llmModel(),
      system: systemMessage,
    );

    return Chat(llmModel, chat, []);
  }

  factory Chat.load(int chatId) {
    final store = ServiceLocator.instance.store;
    final chatEntity = store.box<ChatEntity>().get(chatId)!;

    // messages
    final orderQuery =
        store.box<ChatMessageEntity>().query().order(ChatMessageEntity_.id);
    orderQuery.link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chatId));

    final messageEntities = orderQuery.build().find();
    return Chat(LlmModel(chatEntity.llmModel), chatEntity, messageEntities);
  }

  Future<Chat> save() async {
    final chatBox = ServiceLocator.instance.store.box<ChatEntity>();

    final chatId = chatBox.put(chat);
    final newChat = await chatBox.getAsync(chatId);

    final messageBox = ServiceLocator.instance.store.box<ChatMessageEntity>();
    for (final message in messages) {
      messageBox.putAsync(message);
    }

    return Chat(llmModel, newChat!, messages);
  }

  void setTitle(String title) {
    chat.title = title;
  }

  void addMessage(ChatMessageEntity message) {
    // for ObjectBox
    message.chat.target = chat;
    chat.messages.add(message);

    // for this instance
    messages.add(message);
  }

  Future<String> sendMessageToOllama(String message, String prompt) async {
    return Future.value('');
  }

  Stream<String> sendMessageToOllamaAndReadStream(
      String userInputMessage, String prompt) async* {
    final newMessage =
        ChatMessageEntity(dateTime: DateTime.now(), message: userInputMessage);
    addMessage(newMessage);

    var url = Uri.parse('http://${ServiceLocator.instance.apiRoot}/generate');
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      'model': chat.llmModel,
      'prompt': prompt,
    });

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    // receive response
    final response = await ServiceLocator.instance.httpClient.send(request);
    await for (final String dataLine in response.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())) {
      final responseData =
          GenerateResponseEntity.fromJson(jsonDecode(dataLine));
      yield responseData.response;

      newMessage.receiveResponse(responseData.response, responseData.done);
    }
    save();
  }
}
