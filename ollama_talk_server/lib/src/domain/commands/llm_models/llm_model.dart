import 'package:ollama_talk_server/src/domain/commands/command.dart';

abstract class ILlmModel implements ICommand<String, String> {}
