import 'dart:async';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:path/path.dart' as path;

class ReadFileCommand implements ICommand<String, FileEntity> {
  static const kFileNotFound = 'File not found';

  const ReadFileCommand(this.directory);

  final Directory directory;

  @override
  FutureOr<FileEntity> execute(String fileName) {
    final fullPath = path.join(directory.path, fileName);
    final file = getFile(fullPath);
    if (!file.existsSync()) {
      return FileEntity.error(fileName, kFileNotFound);
    }
    try {
      return file
          .readAsString()
          .then((content) => FileEntity.file(fileName, content))
          .onError((ex, st) => FileEntity.error(fileName, st.toString()));
    } catch (e) {
      return FileEntity.error(fileName, e.toString());
    }
  }

  File getFile(String fullPath) {
    return File(fullPath);
  }
}
