import 'dart:convert';
import 'dart:io';
import 'package:ollama_talk_server/src/domain/agents/file_input_agent.dart';
import 'package:path/path.dart' as path;

import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';

import 'file_output_agent.dart';

class DartCompileAgent extends AbstractAgent {
  static const _kPromptForCorrectDart = r'''
Here are Flutter code files with build errors. Build error is included "buildErrorMessage". Fix them so that they can be built.
- Write "%corrected source%" parts in ONE LINE using escape characters
- This is JSON data. Pay particular attention to the closing parentheses.
- Output only this format part
- output only files you corrected
- Use the output format below:
[
  {
    "fileName": "%file_name1%",
    "content": "%corrected source%",
  },
    ...continue if more files
  {
    "fileName": "%file_name2%",
    "content": "%corrected source%",
  }
]
''';
  DartCompileAgent(
    this.model, {
    this.countTryCompile = 10,
  });

  final LlmModel model;
  final int countTryCompile;

  late final _correctDartAgent = LlmAgent(model, _kPromptForCorrectDart);

  static const _kMessageWithNoIssue = 'No issues found!';

  @override
  Future<AgentResponse> process(String message) async {
    final jsonList = jsonDecode(message) as List<dynamic>;
    final files = jsonList.map((e) => FileEntity.fromJson(e)).toList();

    // Extract files from file information to a directory
    final tempDir = Directory.systemTemp.createTempSync();
    await Directory(path.join(tempDir.path, 'lib')).create(recursive: true);
    final futureWriteFiles = files.map(
      (entity) => File(path.join(tempDir.path, entity.fileName))
          .writeAsString(entity.content),
    );
    print(tempDir.path);

    await Future.wait(futureWriteFiles);
    final fileOutputAgent = FileOutputAgent(model, directory: tempDir);

    for (int counter = 0; counter < countTryCompile; counter++) {
      // Analyze the files in the current directory to find build errors
      await Process.run('fvm', ['flutter', 'pub', 'get', tempDir.path]);
      final processResult =
          await Process.run('fvm', ['flutter', 'analyze', tempDir.path]);

      final isCompileSuccess =
          processResult.stdout.toString().contains(_kMessageWithNoIssue);

      if (isCompileSuccess) {
        return _buildSuccess(tempDir);
      }

      // Fix the files based on the files and build errors
      final files = tempDir
          .listSync(recursive: true)
          .where((e) => e.path.endsWith('.dart'))
          .map((file) =>
              FileEntity.file(file.path, File(file.path).readAsStringSync()));

      final correctData = await correctDart(files, processResult.stdout);

      // Fix the files
      final response = await fileOutputAgent.input(correctData.message);
      print(response.message);

      await Future.delayed(const Duration(milliseconds: 5));
      // Return if there are no more build errors
      // If there are still build errors after 10 attempts, return an error
    }
    tempDir.delete(recursive: true);
    return AgentResponse('cannot build', handle: HandleReplies.replace);
  }

  Future<AgentResponse> _buildSuccess(Directory directory) {
    final filePaths = directory.listSync().map((e) => e.path).join(',');
    final fileInputAgent = FileInputAgent();
    final result = fileInputAgent.process(filePaths);
    result.then((_) {
      directory.delete(recursive: true);
    });

    return result;
  }

  Future<AgentResponse> correctDart(
      Iterable<FileEntity> files, String error) async {
    final jsonData = {'buildErrorMessage': error, 'files': jsonEncode(files)};
    final json = jsonEncode(jsonData);
    final correctData = await _correctDartAgent.process(json);
    return correctData;
  }
}
