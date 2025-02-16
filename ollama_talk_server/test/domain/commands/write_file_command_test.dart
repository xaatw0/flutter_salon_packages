import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/write_file_command.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  final directory =
      Directory.systemTemp.createTempSync('write_file_command_test');

  setUpAll(() {
    directory.createTempSync();
  });
  tearDownAll(() {
    expect(directory.existsSync(), true);
    directory.deleteSync(recursive: true);
    expect(directory.existsSync(), false);
  });

  final target = WriteFileCommand(directory);

  test('write', () async {
    final fileName = 'fileName';
    final entity = FileEntity.file(fileName, 'content');

    final fullPath = path.join(directory.path, fileName);
    expect(File(fullPath).existsSync(), false);
    final result = await target.execute(entity);
    expect(result.path, fullPath);
    expect(File(fullPath).existsSync(), true);

    expect(result.readAsStringSync(), 'content');
  });
}
