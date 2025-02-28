import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

class TrimWikipediaCommand implements ICommand<String, String> {
  static const _kStartPart = '出典: フリー百科事典';
  static const _kEndPart = '典拠管理データベース';

  @override
  FutureOr<String> execute(String data) {
    final indexStart = data.indexOf(_kStartPart);
    final indexEnd = data.indexOf(_kEndPart);

    return data.substring(indexStart, indexEnd);
  }
}
