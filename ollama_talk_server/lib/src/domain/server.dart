import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import '../../ollama_talk_server.dart';

import '../infrastructures/ollama/data/chat_request_data.dart';

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

  Future<ChatBox> openChat(String model, String system) async {
    final chatEntity = ChatBox(llmModel: model, system: system);
    final id = store.box<ChatBox>().putAsync(chatEntity);
    return store.box<ChatBox>().get(await id)!;
  }

  /// chat without streaming
  Future<int> sendMessageWithoutStream(
    ChatBox chat,
    String prompt, {
    DateTime? dateTime,
  }) async {
    // get message from DB
    final queryMessage = store.box<ChatMessageBox>().query()
      ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat.id));
    final listMessage = queryMessage.build().find();

    // make messages
    final message =
        ChatMessageBox(dateTime: dateTime ?? DateTime.now(), message: prompt)
          ..chat.target = chat;

    final messages = <ChatMessageBox>[...listMessage, message]
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
        ChatRequestData(model: chat.llmModel, messages: messages);

    final responseModel = await ollamaServer.chatWithoutStream(chatRequest);
    message.receiveResponse(responseModel.message!.content, responseModel.done);
    chat.messages.add(message);

    // save received message to DB
    return message.save();
  }

  /// chat with streaming
  Stream<String> sendMessage(
    ChatBox chat,
    String prompt, {
    DateTime? dateTime,
    Completer<int>? messageId,
  }) async* {
    // get message from DB
    final queryMessage = store.box<ChatMessageBox>().query()
      ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat.id));
    final listMessage = queryMessage.build().find();

    // make messages
    final newMessage =
        ChatMessageBox(dateTime: dateTime ?? DateTime.now(), message: prompt)
          ..chat.target = chat;

    final messages = <ChatMessageBox>[...listMessage, newMessage]
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
        ChatRequestData(model: chat.llmModel, messages: messages);
    final finalMessage = StringBuffer();
    final responseModelStream = await ollamaServer.chat(chatRequest);

    await for (final ChatResponseData model in responseModelStream) {
      if (model.done == false) {
        final content = model.message!.content;
        finalMessage.write(content);
        yield content;
      } else {
        final message = ChatMessageBox(
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
  Future<List<ChatBox>> loadChatList() {
    return store.box<ChatBox>().getAllAsync();
  }

  Future<ChatBox?> loadChat(int chatId) async {
    final chat = store.box<ChatBox>().get(chatId);
    if (chat == null) {
      return null;
    }

    final histories = await chat.getHistories(store);
    chat.messages.addAll(histories);

    return chat;
  }

  // Document

  Future<DocumentEmbeddingBox> _createEmbedding(String message) async {
    final embedResponseModel =
        ollamaServer.embed(EmbeddingModel.kDefaultModel(), message);
    final embeddingData = DocumentEmbeddingBox(
      message: message,
      vector: (await embedResponseModel).embeddings.first,
    );
    return embeddingData;
  }

  Future<List<DocumentEmbeddingBox>> findRelatedInformation(
    String message,
  ) async {
    final embedding = await _createEmbedding(message);
    return DocumentEmbeddingBox.findRelatedInformation(store, embedding.vector);
  }

  /// save new document into DB
  Future<List<DocumentEmbeddingBox>> insertDocument(
    String fileName,
    String fileData, {
    String? memo,
  }) async {
    final existData = _findDocument(fileName);
    if (existData != null) {
      throw Exception(
          '$fileName is exist. Change the file name. If you want to update this file, please delete it before.');
    }

    var document = DocumentBox(
      fileName: fileName,
      memo: memo ?? '',
      createDate: DateTime.now(),
    ).save(store);

    final futures = <Future<DocumentEmbeddingBox>>[];
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
    if (store.box<DocumentBox>().get(documentId) == null) {
      return false;
    }

    _deleteDocumentAndEmbedding(documentId);

    return true;
  }

  void _deleteDocumentAndEmbedding(int documentId) {
    final embeddingIds = store
        .box<DocumentEmbeddingBox>()
        .query(DocumentEmbeddingEntity_.document.equals(documentId));

    store.runInTransaction(TxMode.write, () {
      store
          .box<DocumentEmbeddingBox>()
          .removeMany(embeddingIds.build().findIds());

      // remove document data
      store.box<DocumentBox>().remove(documentId);
    });
  }

  Stream<Query<DocumentBox>> watchDocuments() {
    return (store.box<DocumentBox>().query().order(DocumentEntity_.createDate))
        .watch(triggerImmediately: true);
  }

  Future<List<DocumentBox>> getDocuments() {
    return store.box<DocumentBox>().getAllAsync();
  }

  Future<DocumentBox?> getDocument(int id) {
    return store.box<DocumentBox>().getAsync(id);
  }

  Stream<Query<ChatMessageBox>> watchMessages(ChatBox chat) {
    return (store
            .box<ChatMessageBox>()
            .query(ChatMessageEntity_.chat.equals(chat.id))
          ..order(ChatMessageEntity_.dateTime))
        .watch(triggerImmediately: true);
  }

  DocumentBox? _findDocument(String fileName) {
    return store
        .box<DocumentBox>()
        .query(DocumentEntity_.fileName.equals(fileName))
        .build()
        .findFirst();
  }

  // memory

  // find RagData
  Future<List<DocumentEmbeddingBox>> getRelatedEmbedding(String prompt,
      {int limit = 5}) async {
    final embedding = await _createEmbedding(prompt);
    final query = store.box<DocumentEmbeddingBox>().query(
        DocumentEmbeddingEntity_.vector
            .nearestNeighborsF32(embedding.vector, limit));
    return query.build().find();
  }

  Future<List<LlmModel>> loadLocalLlmModels() async {
    return _convertModels<LlmModel>(true, (e) => LlmModel(e));
  }

  Future<List<EmbeddingModel>> loadLocalEmbeddingModels() async {
    return _convertModels<EmbeddingModel>(false, (e) => EmbeddingModel(e));
  }

  Future<List<T>> _convertModels<T>(
    bool isEmbeddingModel,
    T convert(String value),
  ) async {
    final models = await ollamaServer.tags();
    return models
        .where((e) => e.isEmbeddingModel() == isEmbeddingModel)
        .map((e) => convert(e.name))
        .toList();
  }

  Future<ShowResponseData> showModelInformation(LlmModel model) async {
    final url = Uri.parse('$baseUrl/show');
    final body = {'name': model()};
    final response = await client.post(url, body: body);

    return ShowResponseData.fromJson(jsonDecode(response.body));
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
    return store.box<UserBox>().put(UserBox(name: name));
  }

  List<UserBox> getUsers() {
    return store.box<UserBox>().getAll();
  }

  // Message
  List<ChatMessageBox> loadMessagesInChat() {
    return store.box<ChatMessageBox>().getAll();
  }
}
