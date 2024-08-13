import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ollama_talk_common/value_objects.dart';

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

    final ragResult = <String>[];
    final messages = [];

    var url = Uri.parse('$baseUrl/generate');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'model': chat.llmModel,
      'prompt': '''
          Using this data: ${ragResult.join(',')}
          History: ${messages.join(',')} 
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
          ChatMessageEntity(dateTime: DateTime.now(), message: prompt);

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
    final embeddingIds = store
        .box<DocumentEmbeddingEntity>()
        .query(DocumentEmbeddingEntity_.document.equals(existDocument.id));
    store
        .box<DocumentEmbeddingEntity>()
        .removeMany(embeddingIds.build().findIds());

    // remove document data
    store.box<DocumentEntity>().remove(existDocument.id);
  }

  Stream<Query<DocumentEntity>> watchDocuments() {
    return (store
            .box<DocumentEntity>()
            .query()
            .order(DocumentEntity_.createDate))
        .watch(triggerImmediately: true);
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

  ChatEntity openChat(LlmModel model, String system) {
    final chatEntity = ChatEntity(llmModel: model(), system: system);
    return chatEntity;
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
    final modelList = jsonDecode(response.body)['models'] as List<dynamic>;
    return modelList.map((e) => LlmEntity.fromJson(e)).toList();
  }
}
