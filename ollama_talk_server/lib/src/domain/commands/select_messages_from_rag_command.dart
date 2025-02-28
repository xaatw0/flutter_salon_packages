import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import '../../../ollama_talk_server.dart';
import '../service_locator.dart';
import 'llm_models/embedding_model.dart';

class SelectMessagesFromRagCommand
    implements ICommand<String, Iterable<String>> {
  const SelectMessagesFromRagCommand(
    this._model, {
    this.store,
    this.count = 5,
  });
  final IEmbeddingModel _model;

  final Store? store;
  final int count;

  @override
  Future<Iterable<String>> execute(final String message) {
    final store = this.store ?? ServiceLocator.instance.store;

    final response = _model.execute([message]);
    return response.then((vectors) async {
      assert(vectors.length == 1);

      return DocumentEmbeddingBox.findRelatedInformation(
        store,
        vectors.single,
        count: count,
      ).then((data) => data.map((e) => e.message));
    });
  }
}
