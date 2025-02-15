import 'dart:async';

import '../command.dart';
import '../llm_models/llm_model.dart';

class RouterNode implements ICommand<String, ICommand> {
  static const kKeyOther = 'other case';

  const RouterNode(this.model, this.command, this.routers, this.otherCase);

  final ILlmModel model;
  final String command;
  final Map<String, ICommand> routers;
  final ICommand otherCase;

  @override
  FutureOr<ICommand> execute(String data) async {
    final prompt = '$command--------------\n'
        '$data\n--------------\n'
        'result must be one of {${{
      ...routers,
      ...{kKeyOther: otherCase}
    }.keys.join(',')}';

    final response = await model.execute(prompt);
    return routers[response.trim()] ?? otherCase;
  }
}
