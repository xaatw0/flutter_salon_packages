import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

class TrimLinkInMarkdown implements ICommand<String, String> {
  final _reg = RegExp(r'\(.*?\)');

  @override
  String execute(String data) {
    return data.replaceAll(_reg, '');
  }
}
