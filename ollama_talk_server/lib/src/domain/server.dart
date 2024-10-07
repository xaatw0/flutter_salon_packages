import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import '../../ollama_talk_server.dart';
import 'package:ollama_talk_common/src/value_objects/chat_id.dart';

///
///
// 　OllamaTalkの開発者への接点
class TalkServer {
  const TalkServer(
    this.client,
    this.baseUrl,
    this.store,
    this.ollamaServer,
  );

  final http.Client client;
  final String baseUrl;
  final Store store;
  final OllamaServer ollamaServer;

  void dispose() {
    client.close();
    store.close();
  }

  Future<ChatEntity> openChat(String model, String system) async {
    final chatEntity = ChatEntity(llmModel: model, system: system);
    final id = store.box<ChatEntity>().putAsync(chatEntity);
    return store.box<ChatEntity>().get(await id)!;
  }

  /// chat without streaming
  Future<int> sendMessageWithoutStream(
    ChatEntity chat,
    String prompt, {
    DateTime? dateTime,
  }) async {
    // get message from DB
    final queryMessage = store.box<ChatMessageEntity>().query()
      ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat.id));
    final listMessage = queryMessage.build().find();

    // make messages
    final message =
        ChatMessageEntity(dateTime: dateTime ?? DateTime.now(), message: prompt)
          ..chat.target = chat;

    final messages = <ChatMessageEntity>[...listMessage, message]
        .map((data) => [
              MessageData(Role.user, data.message),
              if (data.response.isNotEmpty)
                MessageData(Role.assistant, data.response)
            ])
        .expand((e) => e)
        .map(ChatRequestMessage.fromData)
        .toList()
      ..insert(0,
          ChatRequestMessage.fromData(MessageData(Role.system, chat.system)));

    // send message to ollama server
    final chatRequest =
        ChatRequestModel(model: chat.llmModel, messages: messages);

    final responseModel = await ollamaServer.chatWithoutStream(chatRequest);
    message.receiveResponse(responseModel.message!.content, responseModel.done);
    chat.messages.add(message);

    // save received message to DB
    return message.save();
  }

  /// chat with streaming
  Stream<String> sendMessage(
    ChatEntity chat,
    String prompt, {
    DateTime? dateTime,
    Completer<int>? messageId,
  }) async* {
    // get message from DB
    final queryMessage = store.box<ChatMessageEntity>().query()
      ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat.id));
    final listMessage = queryMessage.build().find();

    // make messages
    final newMessage =
        ChatMessageEntity(dateTime: dateTime ?? DateTime.now(), message: prompt)
          ..chat.target = chat;

    final messages = <ChatMessageEntity>[...listMessage, newMessage]
        .map((data) => [
              MessageData(Role.user, data.message),
              if (data.response.isNotEmpty)
                MessageData(Role.assistant, data.response)
            ])
        .expand((e) => e)
        .map(ChatRequestMessage.fromData)
        .toList()
      ..insert(0,
          ChatRequestMessage.fromData(MessageData(Role.system, chat.system)));

    // send message to ollama server
    final chatRequest =
        ChatRequestModel(model: chat.llmModel, messages: messages);
    final finalMessage = StringBuffer();
    final responseModelStream = await ollamaServer.chat(chatRequest);

    await for (final ChatResponseModel model in responseModelStream) {
      if (model.done == false) {
        final content = model.message!.content;
        finalMessage.write(content);
        yield content;
      } else {
        final message = ChatMessageEntity(
          dateTime: newMessage.dateTime,
          message: newMessage.message,
          response: finalMessage.toString(),
        );
        chat.messages.add(message);
        // save received message to DB
        final id = message.save();
        if (messageId != null) {
          messageId.complete(id);
        }
      }
    }
  }

  /// load chat list in ObjectBox
  Future<List<ChatEntity>> loadChatList() {
    return store.box<ChatEntity>().getAllAsync();
  }

  Future<ChatEntity?> loadChat(int chatId) async {
    final chat = store.box<ChatEntity>().get(chatId);
    if (chat == null) {
      return null;
    }

    final histories = await chat.getHistories(store);
    chat.messages.addAll(histories);

    return chat;
  }

  // Document

  Future<DocumentEmbeddingEntity> _createEmbedding(String message) async {
    final embedResponseModel =
        ollamaServer.embed(EmbeddingModel.kDefaultModel(), message);
    final embeddingData = DocumentEmbeddingEntity(
      message: message,
      vector: (await embedResponseModel).embeddings.first,
    );
    return embeddingData;
  }

  Future<List<DocumentEmbeddingEntity>> findRelatedInformation(
    String message,
  ) async {
    final embedding = await _createEmbedding(message);
    return DocumentEmbeddingEntity.findRelatedInformation(
        store, embedding.vector);
  }

  /// save new document into DB
  Future<List<DocumentEmbeddingEntity>> insertDocument(
    String fileName,
    String fileData, {
    String? memo,
  }) async {
    final existData = _findDocument(fileName);
    if (existData != null) {
      throw Exception(
          '$fileName is exist. Change the file name. If you want to update this file, please delete it before.');
    }

    var document = DocumentEntity(
      fileName: fileName,
      memo: memo ?? '',
      createDate: DateTime.now(),
    ).save(store);

    final futures = <Future<DocumentEmbeddingEntity>>[];
    for (final line in LineSplitter.split(fileData)) {
      if (line.isEmpty) {
        continue;
      }

      final entity = (await _createEmbedding(line))
        ..document.target = await document;
      futures.add(entity.save(store));
    }

    return Future.wait(futures);
  }

  Future<void> removeDocument(String fileName) async {
    final existDocument = _findDocument(fileName);

    if (existDocument == null) {
      throw Exception('$fileName is not exist');
    }

    // remove embedding data
    _deleteDocumentAndEmbedding(existDocument.id);
  }

  bool deleteDocument(int documentId) {
    if (store.box<DocumentEntity>().get(documentId) == null) {
      return false;
    }

    _deleteDocumentAndEmbedding(documentId);

    return true;
  }

  void _deleteDocumentAndEmbedding(int documentId) {
    final embeddingIds = store
        .box<DocumentEmbeddingEntity>()
        .query(DocumentEmbeddingEntity_.document.equals(documentId));

    store.runInTransaction(TxMode.write, () {
      store
          .box<DocumentEmbeddingEntity>()
          .removeMany(embeddingIds.build().findIds());

      // remove document data
      store.box<DocumentEntity>().remove(documentId);
    });
  }

  Stream<Query<DocumentEntity>> watchDocuments() {
    return (store
            .box<DocumentEntity>()
            .query()
            .order(DocumentEntity_.createDate))
        .watch(triggerImmediately: true);
  }

  Future<List<DocumentEntity>> getDocuments() {
    return store.box<DocumentEntity>().getAllAsync();
  }

  Future<DocumentEntity?> getDocument(int id) {
    return store.box<DocumentEntity>().getAsync(id);
  }

  Stream<Query<ChatMessageEntity>> watchMessages(ChatEntity chat) {
    return (store
            .box<ChatMessageEntity>()
            .query(ChatMessageEntity_.chat.equals(chat.id))
          ..order(ChatMessageEntity_.dateTime))
        .watch(triggerImmediately: true);
  }

  DocumentEntity? _findDocument(String fileName) {
    return store
        .box<DocumentEntity>()
        .query(DocumentEntity_.fileName.equals(fileName))
        .build()
        .findFirst();
  }

  // memory

  // find RagData
  Future<List<DocumentEmbeddingEntity>> getRelatedEmbedding(String prompt,
      {int limit = 5}) async {
    final embedding = await _createEmbedding(prompt);
    final query = store.box<DocumentEmbeddingEntity>().query(
        DocumentEmbeddingEntity_.vector
            .nearestNeighborsF32(embedding.vector, limit));
    return query.build().find();
  }

  Future<List<LlmModel>> loadLocalLlmModes() async {
    final models = await ollamaServer.tags();
    return models
        .where((e) => !e.isEmbeddingModel())
        .map((e) => LlmModel(e.name))
        .toList();
  }

  Future<List<EmbeddingModel>> loadLocalEmbeddingModel() async {
    final models = await ollamaServer.tags();
    return models
        .where((e) => e.isEmbeddingModel())
        .map((e) => EmbeddingModel(e.name))
        .toList();
  }

  Future<ShowResponseModel> showModelInformation(LlmModel model) async {
    final url = Uri.parse('$baseUrl/show');
    final body = {'name': model()};
    final response = await client.post(url, body: body);

    return ShowResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<bool> pullModel(String modelName) async {
    var url = Uri.parse('$baseUrl/pull');
    String body = jsonEncode({'name': modelName});
    final response = await client.post(url, body: jsonEncode(body));
    print(response.body);
    return jsonDecode(response.body)['status'] == 'pulling manifest';
  }

  // User
  int insertUser(String name) {
    return store.box<UserEntity>().put(UserEntity(name: name));
  }

  List<UserEntity> getUsers() {
    return store.box<UserEntity>().getAll();
  }

  // Message
  List<ChatMessageEntity> loadMessagesInChat() {
    return store.box<ChatMessageEntity>().getAll();
  }
}
