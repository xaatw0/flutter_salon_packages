import 'dart:async';
import 'dart:convert';

import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/llm_model.dart';

import '../../../ollama_talk_server.dart';
import '../service_locator.dart';
import 'command.dart';
import 'llm_command.dart';
import 'llm_models/embedding_model.dart';

// 必要な情報：データを入れるDB、RAGのメソッド
/// 本文自体をRAGの本文にする。RAGのベクトルデータとして、要約を使う
class InsertMessagesIntoRagWithNewlineSummary
    implements ICommand<String, void> {
  const InsertMessagesIntoRagWithNewlineSummary(
    this._model, {
    required this.llmCommandForSummary,
    this.store,
  });

  final IEmbeddingModel _model;

  final LlmCommand llmCommandForSummary;

  final Store? store;

  @override
  Future<List<int>> execute(final String messages) async {
    return _summaryMessage(messages).then(
      (summaries) => _getEmbeddingVectors(summaries).then((vectors) {
        assert(summaries.length == vectors.length);
        print(summaries.join('///'));
        return _insertMessageWithEmbeddingVectorsIntoRag(messages, vectors);
      }),
    );
  }

  Future<List<String>> _summaryMessage(String message) {
    return llmCommandForSummary
        .execute(message)
        .then((messages) => LineSplitter().convert(messages));
  }

  Future<List<List<double>>> _getEmbeddingVectors(List<String> messages) {
    return _model.execute(messages);
  }

  Future<List<int>> _insertMessageWithEmbeddingVectorsIntoRag(
      final String originalMessage, final List<List<double>> embeddingVectors) {
    final data = embeddingVectors.map((vector) =>
        DocumentEmbeddingBox(vector: vector, message: originalMessage));
    final box = (this.store ?? ServiceLocator.instance.store)
        .box<DocumentEmbeddingBox>();
    return box.putManyAsync(data.toList());
  }
}
