import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/llm_model.dart';

class TrimJsonCommand implements ICommand<String, String> {
  static const _kStartPart = '```json';
  static const _kEndPart = '```';

  @override
  String execute(String data) {
    if (data.trim().startsWith(_kStartPart) &&
        data.trim().endsWith(_kEndPart)) {
      return data
          .replaceFirst(_kStartPart, '')
          .replaceFirst(_kEndPart, '',
              data.length - _kStartPart.length - _kEndPart.length - 1)
          .trim();
    }
    return data;
  }
}
