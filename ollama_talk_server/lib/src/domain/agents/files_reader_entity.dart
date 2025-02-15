import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/command.dart';

class FilesReaderAgent
    implements ICommand<Iterable<FileNameEntity>, Iterable<FileEntity>> {
  static const kFileNotFound = 'File not found';

  FilesReaderAgent({this.directory});
  final Directory? directory;

  @override
  FutureOr<Iterable<FileEntity>> execute(Iterable<FileNameEntity> data) async {
    final entities =
        data.map((e) => File(e.fileName)).map((file) => read(file));

    return Future.wait(entities);
  }

  Future<FileEntity> read(File file) {
    assert(path.isRelative(file.path) || directory == null,
        'Do not use absolute paths when directory is not null');

    final checkFile =
        directory == null ? file : File(path.join(directory!.path, file.path));

    return checkFile.exists().then((isExist) {
      if (!isExist) {
        return FileEntity.error(file.path, kFileNotFound);
      }

      return file
          .readAsString()
          .then((content) => FileEntity.file(file.path, content))
          .catchError((e, st) => FileEntity.error(file.path, e.toString()));
    });
  }
}
