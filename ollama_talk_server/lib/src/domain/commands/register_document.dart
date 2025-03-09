import 'dart:async';

import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';

class RegisterDocument implements ICommand<String, void> {
  const RegisterDocument({this.store});

  final Store? store;

  @override
  Future<void> execute(String title) {
    final store = this.store ?? ServiceLocator.instance.ollamaTalkServer.store;
    final box =
        DocumentBox(fileName: title, memo: '', createDate: DateTime.now());
    return box.save(store);
  }
}
