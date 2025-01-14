import 'dart:convert';
import 'dart:io';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:path/path.dart' as path;
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/dart_compile_agent.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'dart_compile_agent_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ServiceLocator>(),
  MockSpec<TalkServer>(),
])
void main() async {
  final llmMode = LlmModel('elyza:jp8b');
  final dirDartCompile = Directory('test/domain/agents/dart_compile');
  final pathPubspecYaml = 'pubspec.yaml';
  final filePubspecYaml = File(path.join(dirDartCompile.path, pathPubspecYaml));
  final pathMainDart = 'lib/main.dart';
  final fileMainDart = File(path.join(dirDartCompile.path, pathMainDart));
  final pathErrorDart = 'lib/main_run_app_x.dart';
  final fileErrorDart = File(path.join(dirDartCompile.path, pathErrorDart));

  final ollamaServer = OllamaServer(
    http.Client(),
    OllamaAddress.create(),
  );

  final serviceLocator = MockServiceLocator();
  final talkServer = MockTalkServer();
  when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);
  when(talkServer.ollamaServer).thenReturn(ollamaServer);

  ServiceLocator.setMock(serviceLocator);

  test('exist test resource', () {
    expect(dirDartCompile.existsSync(), true);
    expect(filePubspecYaml.existsSync(), true);
    expect(fileMainDart.existsSync(), true);
    expect(fileErrorDart.existsSync(), true);
  });

  test('compile files without error', () async {
    final entities = [
      FileEntity.file(pathPubspecYaml, filePubspecYaml.readAsStringSync()),
      FileEntity.file(pathMainDart, fileMainDart.readAsStringSync()),
    ];
    final source = jsonEncode(entities);

    final target = DartCompileAgent(llmMode);
    final compileResult = await target.process(source);
  });

  test(timeout: Timeout(Duration(seconds: 60)), 'correct files with error',
      () async {
    final files = [
      FileEntity.file(pathMainDart, fileErrorDart.readAsStringSync()),
    ];
    final target = DartCompileAgent(llmMode);
    final errorMessage =
        "  error • The function 'runAppX' isn't defined lib/main.dart:4:3";
    expect(files.first.content.contains('runAppX('), true);

    final result = await target.correctDart(files, errorMessage);
    expect(result.message.contains('runApp('), true);
    expect(result.message.contains('runAppX('), false);

    expect(result.message.contains('fileName'), true);
    print(result.message);
    final list = jsonDecode(result.message) as List<dynamic>;
    final correctedFile = list.map((e) => FileEntity.fromJson(e)).toList();
    expect(correctedFile.length, 1);
    expect(correctedFile.first.fileName, 'lib/main.dart');
    expect(correctedFile.first.content.contains('runApp('), true);
    expect(correctedFile.first.content.contains('runAppX('), false);
  });

  test('compile files with error', () async {
    final dirDartCompile = Directory('test/domain/agents/dart_compile');
    expect(dirDartCompile.existsSync(), true);

    final pathPubspecYaml = 'pubspec.yaml';
    final filePubspecYaml =
        File(path.join(dirDartCompile.path, pathPubspecYaml));
    expect(filePubspecYaml.existsSync(), true);

    final pathMainDart = 'lib/main.dart';
    final pathMainDartWithError = 'lib/main_run_app_x.dart';
    final fileMainDart =
        File(path.join(dirDartCompile.path, pathMainDartWithError));
    expect(fileMainDart.existsSync(), true);

    final entities = [
      FileEntity.file(pathPubspecYaml, filePubspecYaml.readAsStringSync()),
      FileEntity.file(pathMainDart, fileMainDart.readAsStringSync()),
    ];
    final source = jsonEncode(entities);

    final target = DartCompileAgent(llmMode);
    final compileResult = await target.process(source);
  });
}
