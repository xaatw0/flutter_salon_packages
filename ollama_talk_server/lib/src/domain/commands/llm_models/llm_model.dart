import 'package:ollama_talk_server/src/domain/commands/command.dart';

abstract class ILlmCommand implements ICommand<String, String> {
  @override
  Future<String> execute(String data);
}
