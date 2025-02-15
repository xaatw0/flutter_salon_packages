import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/domain/commands/llm_models/llm_model.dart';

class GeminiModel implements ILlmModel {
  final _kUrl =
      Uri.parse('https://geminiapi-477639193964.asia-northeast2.run.app');

  @override
  Future<String> execute(String message) async {
    final response = await http.post(_kUrl, body: {'message': message});
    return response.body;
  }
}
