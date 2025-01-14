import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';

class FileOutputAgent extends AbstractAgent {
  static const kKeyFileName = 'fileName';
  static const kKeyContent = 'content';
  static const kPrompt = '''[
      {"$kKeyFileName":"%$kKeyFileName%","$kKeyContent":"%$kKeyContent%"},
      ....
      {"$kKeyFileName":"%$kKeyFileName%","$kKeyContent":"%$kKeyContent%"}
  ]
  Please extract the part to be output as a file from the "input" data and rewrite them in the format above. Please only output the part in the format above.
''';

  FileOutputAgent(this.model, {this.directory})
      : llmAgent = LlmAgent(model, kPrompt);

  final LlmModel model;
  final LlmAgent llmAgent;
  final Directory? directory;

  @override
  Future<AgentResponse> process(String message) async {
    final response = await llmAgent.process(message);
    final files = jsonDecode(response.message) as List<dynamic>;
    final fileNames = <String>[];

    for (var fileData in files) {
      final fileName = fileData[kKeyFileName];
      fileNames.add(fileName);

      final file = File(path.join(directory?.path ?? '', fileName));
      file.writeAsString(fileData[kKeyContent]);
    }

    final json = jsonEncode(fileNames);
    return AgentResponse(json, handle: HandleReplies.replace);
  }
}
