import 'dart:async';

import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';

class DeleteDocument implements ICommand<String, List<DocumentBox>> {
  const DeleteDocument({this.store});

  final Store? store;

  @override
  Future<List<DocumentBox>> execute(String title) {
    final store = this.store ?? ServiceLocator.instance.store;
    return DocumentBox.remove(store, title);
  }
}
