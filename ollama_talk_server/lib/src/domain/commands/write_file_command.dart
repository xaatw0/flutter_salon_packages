import 'dart:async';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:path/path.dart' as path;

class WriteFileCommand implements ICommand<FileEntity, File> {
  const WriteFileCommand(this.directory);

  final Directory directory;

  @override
  FutureOr<File> execute(FileEntity entity) {
    final filePath = path.join(directory.path, entity.fileName);
    return File(filePath).writeAsString(entity.content);
  }
}
