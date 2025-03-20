import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';

import '../command.dart';
import '../llm_models/llm_model.dart';

class AdditionalInformationNode implements ICommand<String, String> {
  const AdditionalInformationNode(
    this.model,
    this.commandForInformation,
  );

  final ILlmCommand model;
  final LlmCommand commandForInformation;

  @override
  Future<String> execute(String data) async {
    final additionalInformation = await commandForInformation.execute(data);

    final prompt = '$data\n--------------\n'
        'answer to the above, based on the following information:\n$additionalInformation';

    final response = await model.execute(prompt);
    return response;
  }
}
