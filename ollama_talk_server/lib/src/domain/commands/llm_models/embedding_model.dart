import 'dart:async';
import 'package:ollama_talk_server/src/domain/commands/command.dart';

abstract interface class IEmbeddingModel
    implements ICommand<List<String>, List<List<double>>> {
  @override
  Future<List<List<double>>> execute(List<String> data);
}
