import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/ollama/entities/show_model_information_entity.dart';

import '../ollama_talk_server.dart';

///
///
// 　OllamaTalkの開発者への接点
class OllamaTalkClient {
  const OllamaTalkClient(
    this.client,
    this.baseUrl,
    this.store,
  );

  final http.Client client;
  final String baseUrl;
  final Store store;

  void dispose() {
    client.close();
    store.close();
  }

  /// Generate a completion
  Stream<String> sendMessageAndWaitResponse(
      ChatEntity chat, String prompt) async* {
    final futureRagResult = _getEmbeddingVector(prompt);
    final futureMessages = chat.getHistories(store);

    var url = Uri.parse('$baseUrl/generate');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'model': chat.llmModel,
      'prompt': '''
          Using this data: ${(await futureRagResult).join(',')}
          History: ${(await futureMessages).join(',')} 
          characterization:  ${chat.system}
          Question：$prompt''',
    });
    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    try {
      // collect information

      // send message
      final messageEntity =
          ChatMessageEntity(dateTime: DateTime.now(), message: prompt)
            ..chat.target = chat;

      final response = await client.send(request);

      // receive response
      await for (final String dataLine in response.stream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())) {
        final responseData =
            GenerateResponseEntity.fromJson(jsonDecode(dataLine));
        yield responseData.response;

        messageEntity.receiveResponse(
            store, responseData.response, responseData.done);
      }

      // save message in database
    } finally {
      print('finished');
    }
  }

  /// Generate a chat completion
  Stream<String> chatAndWaitResponse(ChatEntity chat, String prompt) async* {
    final futureRagResult = findRelatedInformation(prompt);
    final futureMessages = chat.getHistories(store);

    final messages = (await futureMessages)
        .map(MessageEntity.fromChatMessageEntity)
        .expand((e) => e)
        .toList();

    final systemMessage = chat.getSystemMessage();
    if (systemMessage != null) {
      messages.insert(0, systemMessage);
    }

    final referenceData =
        '{"data":[\n  {"${(await futureRagResult).map((e) => e.message).join('"},\n  {"')}"}\n]}';

    final newMessage = MessageEntity(
        role: Role.user, content: '$prompt\n\nUse these data:$referenceData');
    messages.add(newMessage);

    final chatRequest = chat.request(messages);

    final messageEntity = chat.sendMessage(store, prompt, DateTime.now());

    var url = Uri.parse('$baseUrl/chat');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode(chatRequest.toJson());
    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    try {
      // send message
      final response = await client.send(request);

      // receive response
      await for (final String dataLine in response.stream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())) {
        final responseData = ChatResponseEntity.fromJson(jsonDecode(dataLine));
        yield responseData.message.content;

        messageEntity.receiveResponse(
            store, responseData.message.content, responseData.done);
      }
    } finally {
      print('finished');
    }
  }

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
    final vectorData = _getEmbeddingVector(message);
    final embeddingData = DocumentEmbeddingEntity(
      message: message,
      vector: await vectorData,
    );
    return embeddingData;
  }

  Future<List<double>> _getEmbeddingVector(String message) async {
    var url = Uri.parse('$baseUrl/embeddings');
    var headers = {'Content-Type': 'application/json'};
    String body = jsonEncode(
        {'model': EmbeddingModel.kMxbaiEmbedLarge(), 'prompt': message});

    final response = await client.post(url, body: body, headers: headers);
    final vectorList = jsonDecode(response.body)['embedding'] as List<dynamic>;
    return vectorList.map((e) => e as double).toList();
  }

  Future<List<DocumentEmbeddingEntity>> findRelatedInformation(
    String message,
  ) async {
    final vector = await _getEmbeddingVector(message);
    return DocumentEmbeddingEntity.findRelatedInformation(store, vector);
  }

  Future<void> insertDocument(
      String fileName, String fileData, String memo) async {
    final existData = _findDocument(fileName);

    if (existData != null) {
      throw Exception('$fileName is exist');
    }

    final document = DocumentEntity(
        fileName: fileName, memo: memo, createDate: DateTime.now());

    store.box<DocumentEntity>().put(document);

    final lines = const LineSplitter().convert(fileData);
    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      final entity = await _createEmbedding(line);
      entity.document.target = document;
      store.box<DocumentEmbeddingEntity>().put(entity);
    }
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

  Future<int> openChat(LlmModel model, String system) {
    final chatEntity = ChatEntity(llmModel: model(), system: system);
    return store.box<ChatEntity>().putAsync(chatEntity);
  }

  // memory

  // find RagData
  Future<List<DocumentEmbeddingEntity>> getRelatedEmbedding(String prompt,
      {int limit = 5}) async {
    final vector = _getEmbeddingVector(prompt);
    final query = store.box<DocumentEmbeddingEntity>().query(
        DocumentEmbeddingEntity_.vector
            .nearestNeighborsF32(await vector, limit));
    return query.build().find();
  }

  Future<List<LlmEntity>> loadLocalModels() async {
    var url = Uri.parse('$baseUrl/tags');
    var headers = {'Content-Type': 'application/json'};

    final response = await client.get(url, headers: headers);
    print(response.body);
    final modelList = jsonDecode(response.body)['models'] as List<dynamic>;
    return modelList.map((e) => LlmEntity.fromJson(e)).toList();
  }

  Future<ShowModelInformationEntity> showModelInformation(
      LlmModel model) async {
    final url = Uri.parse('$baseUrl/show');
    final body = {'name': model()};
    final response = await client.post(url, body: body);

    return ShowModelInformationEntity.fromJson(jsonDecode(response.body));
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
}
