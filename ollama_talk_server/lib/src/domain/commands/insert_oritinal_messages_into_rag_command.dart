import 'dart:async';

import '../../../ollama_talk_server.dart';
import '../service_locator.dart';
import 'command.dart';
import 'llm_models/embedding_model.dart';

// 必要な情報：データを入れるDB、RAGのメソッド
class InsertOriginalMessagesIntoRagCommand
    implements ICommand<(String originalMessage, List<String> messages), void> {
  const InsertOriginalMessagesIntoRagCommand(this._model, {this.store});

  final IEmbeddingModel _model;

  final Store? store;

  @override
  Future<List<int>> execute((String, List<String>) data) async {
    final box =
        (store ?? ServiceLocator.instance.store).box<DocumentEmbeddingBox>();

    final (originalMessage, messages) = data;

    return _model.execute(messages).then((vectors) {
      assert(vectors.length == messages.length);

      return List.generate(
        messages.length,
        (index) => DocumentEmbeddingBox(
          vector: vectors[index],
          message: originalMessage,
        ),
      );
    }).then((boxes) => box.putManyAsync(boxes));
  }
}
