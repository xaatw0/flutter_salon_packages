import 'dart:async';

import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';

class CheckDocument implements ICommand<String, bool> {
  const CheckDocument({this.store});

  final Store? store;

  @override
  Future<bool> execute(String title) {
    final store = this.store ?? ServiceLocator.instance.ollamaTalkServer.store;
    return DocumentBox.findByFileName(store, title).then((e) => e.isNotEmpty);
  }
}
