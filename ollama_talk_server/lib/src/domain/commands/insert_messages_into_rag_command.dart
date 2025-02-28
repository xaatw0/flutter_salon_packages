import 'dart:async';

import '../../../ollama_talk_server.dart';
import '../service_locator.dart';
import 'command.dart';
import 'llm_models/embedding_model.dart';

// 必要な情報：データを入れるDB、RAGのメソッド
class InsertMessagesIntoRagCommand implements ICommand<List<String>, void> {
  const InsertMessagesIntoRagCommand(this._model, {this.store});

  final IEmbeddingModel _model;

  final Store? store;

  @override
  Future<List<int>> execute(final List<String> messages) async {
    final box =
        (store ?? ServiceLocator.instance.store).box<DocumentEmbeddingBox>();

    return _model.execute(messages).then((vectors) {
      assert(vectors.length == messages.length);

      return List.generate(
        messages.length,
        (index) => DocumentEmbeddingBox(
          vector: vectors[index],
          message: messages[index],
        ),
      );
    }).then((boxes) => box.putManyAsync(boxes));
  }
}
