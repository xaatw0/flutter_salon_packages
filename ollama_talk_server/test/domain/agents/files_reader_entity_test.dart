import 'dart:io';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/files_reader_entity.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'files_reader_entity_test.mocks.dart';

@GenerateNiceMocks([MockSpec<File>()])
void main() {
  final path1 = 'test/domain/agents/files_reader_entity_test.data1';
  final path2 = 'test/domain/agents/files_reader_entity_test.data2';
  final path3 = 'test/domain/agents/files_reader_entity_test.data3';

  final absolutePath1 = path.absolute(path1);
  final absolutePath2 = path.absolute(path2);
  final absolutePath3 = path.absolute(path3);

  group('前段階', () {
    test('ファイル確認', () {
      expect(File(path1).existsSync(), true);
      expect(File(path2).existsSync(), true);
      expect(File(path3).existsSync(), false);
    });

    test('パス', () {
      expect(path.isRelative(path1), true);
      expect(path.isAbsolute(path1), false);

      final absolutePath = path.absolute(path1);
      expect(absolutePath.length, greaterThan(path1.length));
    });
  });

  group('ディレクトリなし', () {
    final agent = FilesReaderAgent();

    test('相対パス', () async {
      final fileNames =
          [path1, path2, path3].map((e) => FileNameEntity(e)).toList();
      final data = await agent.execute(fileNames);
      final files = data.toList()
        ..sort((e1, e2) => e1.fileName.compareTo(e2.fileName));
      expect(files.length, 3);

      expect(files[0].fileName, path1);
      expect(files[0].content, 'data1');
      expect(files[0].errorMessage?.isEmpty, isNull);

      expect(files[1].fileName, path2);
      expect(files[1].content, 'data2');
      expect(files[1].errorMessage?.isEmpty, isNull);

      expect(files[2].fileName, path3);
      expect(files[2].content.isEmpty, true);
      expect(files[2].errorMessage, FilesReaderAgent.kFileNotFound);
    });
    test('絶対パス', () async {
      final fileNames = [absolutePath1, absolutePath2, absolutePath3]
          .map((e) => FileNameEntity(e))
          .toList();
      final data = await agent.execute(fileNames);
      final files = data.toList()
        ..sort((e1, e2) => e1.fileName.compareTo(e2.fileName));
      expect(files.length, 3);

      expect(files[0].fileName, absolutePath1);
      expect(files[0].content, 'data1');
      expect(files[0].errorMessage?.isEmpty, isNull);

      expect(files[1].fileName, absolutePath2);
      expect(files[1].content, 'data2');
      expect(files[1].errorMessage?.isEmpty, isNull);

      expect(files[2].fileName, absolutePath3);
      expect(files[2].content.isEmpty, true);
      expect(files[2].errorMessage, FilesReaderAgent.kFileNotFound);
    });
  });
  group('ディレクトリあり', () {
    final agent = FilesReaderAgent(directory: Directory('').absolute);
    print(agent.directory);

    test('相対パス', () async {
      final fileNames =
          [path1, path2, path3].map((e) => FileNameEntity(e)).toList();
      final data = await agent.execute(fileNames);
      final files = data.toList()
        ..sort((e1, e2) => e1.fileName.compareTo(e2.fileName));
      expect(files.length, 3);

      expect(files[0].fileName, path1);
      expect(files[0].content, 'data1');
      expect(files[0].errorMessage?.isEmpty, isNull);

      expect(files[1].fileName, path2);
      expect(files[1].content, 'data2');
      expect(files[1].errorMessage?.isEmpty, isNull);

      expect(files[2].fileName, path3);
      expect(files[2].content.isEmpty, true);
      expect(files[2].errorMessage, FilesReaderAgent.kFileNotFound);
    });

    test('絶対パス', () {
      final fileNames = [
        absolutePath1,
      ].map((e) => FileNameEntity(e)).toList();
      expect(
        () => agent.execute(fileNames),
        throwsA(isA<AssertionError>().having((e) => e.message, 'check message',
            'Do not use absolute paths when directory is not null')),
      );
    });
  });

  group('read', () {
    final agent = FilesReaderAgent();

    test('mock', () async {
      final mock = MockFile();
      when(mock.readAsString()).thenAnswer((_) async => 'content');
      when(mock.path).thenReturn('fileName');
      when(mock.exists()).thenAnswer((_) async => true);

      expect(mock.path, 'fileName');
      expect(await mock.readAsString(), 'content');
      expect(await mock.exists(), true);
    });

    test('通常', () async {
      final mock = MockFile();
      when(mock.readAsString()).thenAnswer((_) async => 'content');
      when(mock.path).thenReturn('fileName');
      when(mock.exists()).thenAnswer((_) async => true);

      final result = await agent.read(mock);
      expect(result.fileName, 'fileName');
      expect(result.content, 'content');
      expect(result.errorMessage, isNull);
    });

    test('ファイルなし', () async {
      final mock = MockFile();
      when(mock.path).thenReturn('fileName');
      when(mock.exists()).thenAnswer((_) async => false);

      final result = await agent.read(mock);
      expect(result.fileName, 'fileName');
      expect(result.content, '');
      expect(result.errorMessage, FilesReaderAgent.kFileNotFound);
    });

    test('読み込み中にエラー', () async {
      final mock = MockFile();
      when(mock.readAsString())
          .thenAnswer((_) async => throw Exception('error'));
      when(mock.path).thenReturn('fileName');
      when(mock.exists()).thenAnswer((_) async => true);

      final result = await agent.read(mock);
      expect(result.fileName, 'fileName');
      expect(result.content, '');
      expect(result.errorMessage, 'Exception: error');
    });
  });
}
