import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ollama_talk_common/ollama_talk_common.dart';

import 'abstract_agent.dart';
import 'llm_agent.dart';

class FileInputAgent extends AbstractAgent {
  FileInputAgent();

  @override
  Future<AgentResponse> process(String message) async {
    final paths = message.split(',');
    final files = <Future<_FileData>>[];
    for (final path in paths) {
      files.add(_processFile(path.trim()));
    }

    final jsonData = jsonEncode(await Future.wait(files));
    return AgentResponse(jsonData, handle: HandleReplies.replace);
  }

  Future<_FileData> _processFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return _FileData(path, error: 'not found');
    }
    try {
      return _FileData(path, content: file.readAsStringSync());
    } on IOException catch (ex) {
      return _FileData(path, error: ex.toString());
    }
  }
}

class _FileData {
  const _FileData(
    this.fileName, {
    this.content = '',
    this.error = '',
  });
  final String fileName;
  final String content;
  final String error;

  String toJson() {
    if (error.isEmpty) {
      return '{"fileName":"$fileName","content":"$content"}';
    }
    return '{"fileName":"$fileName","error":"$error"${_getContentWhenError()}}';
  }

  String _getContentWhenError() {
    if (content.isEmpty) {
      return '';
    }
    return ',"content":"$content"';
  }

  factory _FileData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    return _FileData(
      jsonMap['fileName'],
      content: jsonMap['content'] ?? '',
      error: jsonMap['error'] ?? '',
    );
  }
}
