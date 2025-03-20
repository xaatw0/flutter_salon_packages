import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('訳す', () async {
    final command = LlmCommand(GeminiModel(), '日本語訳して');
    final result = await command.execute('Hello');
    expect(result.trim(), 'こんにちは');
  });

  test('Ollama', () async {
    final client = http.Client();
    final address = OllamaAddress.create();
    final ollamaServer = OllamaServer(client, address);
    final command = LlmCommand(
        OllamaLlmCommand(ollamaServer, OllamaLlmModel.kElyzaJp8b), '日本語に訳して');

    final result = await command.execute('Hello');
    expect(result.trim(), 'こんにちは');
  });
}
