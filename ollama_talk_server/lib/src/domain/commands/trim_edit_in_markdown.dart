import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

class TrimEditInMarkdown implements ICommand<String, String> {
  final _regEdit = RegExp('\\\\\\[\\[編集]\\\\\\]');
  @override
  String execute(String data) {
    return data.replaceAll(_regEdit, '');
  }
}
