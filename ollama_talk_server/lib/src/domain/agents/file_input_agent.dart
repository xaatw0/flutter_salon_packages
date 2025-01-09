import 'dart:convert';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';

import 'abstract_agent.dart';

class FileInputAgent extends AbstractAgent {
  FileInputAgent();

  @override
  Future<AgentResponse> process(String message) async {
    final paths = message.split(',');
    final files = paths.map((path) => _processFile(path.trim()));
    final jsonData = jsonEncode(await Future.wait(files));
    return AgentResponse(jsonData, handle: HandleReplies.replace);
  }

  Future<FileEntity> _processFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return FileEntity.error(path, 'not found');
    }
    try {
      return FileEntity.file(path, file.readAsStringSync());
    } on IOException catch (ex) {
      return FileEntity.error(path, ex.toString());
    }
  }
}
