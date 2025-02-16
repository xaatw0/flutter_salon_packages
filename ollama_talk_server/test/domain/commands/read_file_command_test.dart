import 'dart:io';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/read_file_command.dart';
import 'package:ollama_talk_server/src/domain/commands/write_file_command.dart';
import 'package:test/test.dart';

import 'read_file_command_test.mocks.dart';

class ReadFileCommandMock extends ReadFileCommand {
  ReadFileCommandMock(super.directory, this.file);

  final File file;

  @override
  File getFile(String fullPath) {
    return file;
  }
}

@GenerateNiceMocks([MockSpec<File>()])
void main() {
  final directory =
      Directory.systemTemp.createTempSync('read_file_command_test');

  setUpAll(() {
    directory.createTempSync();
  });
  tearDownAll(() {
    expect(directory.existsSync(), true);
    directory.deleteSync(recursive: true);
    expect(directory.existsSync(), false);
  });
  final writer = WriteFileCommand(directory);
  final reader = ReadFileCommand(directory);

  test('read', () async {
    final fileName = 'fileName';
    final content = 'content';

    final entity = FileEntity.file(fileName, content);
    await writer.execute(entity);

    final result = await reader.execute(fileName);
    expect(result.fileName, fileName);
    expect(result.content, content);
  });

  test('not found', () async {
    final fileName = 'no_file';
    final result = await reader.execute(fileName);
    expect(result.content, '');
    expect(result.fileName, fileName);
    expect(result.errorMessage, ReadFileCommand.kFileNotFound);
  });

  test('error', () async {
    final mockFile = MockFile();
    when(mockFile.existsSync()).thenReturn(true);
    when(mockFile.readAsString())
        .thenAnswer((_) => throw Exception('errorMessage'));

    final target = ReadFileCommandMock(directory, mockFile);
    final result = await target.execute('fileName');
    expect(result.fileName, 'fileName');
    expect(result.content, '');
    expect(result.errorMessage, 'Exception: errorMessage');
  });
}
