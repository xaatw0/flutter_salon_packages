import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

import 'data/generate_response.dart';
import 'data/tags_response_data.dart';

/// Contact to OllamaServer
class OllamaServer {
  const OllamaServer(this.client, this.endpoint);

  final String endpoint;
  final http.Client client;

  /// Generate a completion
  Stream<GenerateResponseData> generate(String model, String prompt) async* {
    var url = Uri.parse('http://$endpoint/generate');
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      'model': model,
      'prompt': prompt,
    });

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    // receive response
    final response = await client.send(request);
    await for (final String dataLine in response.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())) {
      final responseData = GenerateResponseData.fromJson(jsonDecode(dataLine));
      yield responseData;
    }
  }

  /// Generate a completion
  Future<GenerateResponseData> generateWithFuture(
      String model, String prompt) async {
    var url = Uri.parse('http://$endpoint/generate');
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      'model': model,
      'prompt': prompt,
      "stream": false,
    });
    final response = await client.post(url, headers: headers, body: body);
    print('data:' + response.body);
    return GenerateResponseData.fromJson(jsonDecode(response.body));
  }

  /// Generate Embeddings
  Future<EmbedResponseData> embed(String model, String message) async {
    var url = Uri.parse('http://$endpoint/embed');
    var headers = {'Content-Type': 'application/json'};
    String body = jsonEncode({'model': model, 'input': message});

    final response = await client.post(url, body: body, headers: headers);
    return EmbedResponseData.fromJson(jsonDecode(response.body));
  }

  /// List Local Models
  Future<List<TagsResponseData>> tags() async {
    var url = Uri.parse('http://$endpoint/tags');
    var headers = {'Content-Type': 'application/json'};

    final response = await client.get(url, headers: headers);
    final modelList = jsonDecode(response.body)['models'] as List<dynamic>;
    return modelList.map((e) => TagsResponseData.fromJson(e)).toList();
  }

  /// Show Model Information
  Future<ShowResponseData> show(String name) async {
    final url = Uri.parse('http://$endpoint/show');
    final body = {'name': name};
    final response = await client.post(url, body: body);

    return ShowResponseData.fromJson(jsonDecode(response.body));
  }

  /// Pull a Model
  Future<bool> pull(String modelName) async {
    var url = Uri.parse('http://$endpoint/pull');
    String body = jsonEncode({'name': modelName});
    final response = await client.post(url, body: jsonEncode(body));
    return jsonDecode(response.body)['status'] == 'pulling manifest';
  }

  /// Chat Request (Streaming)
  /// curl http://localhost:11434/api/pull -d '{ "name": "mxbai-embed-large"}'
  Stream<ChatResponseData> chat(ChatRequestData chatRequest) async* {
    var url = Uri.parse('http://$endpoint/chat');
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode(chatRequest.toJson());
    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;
    final response = await client.send(request);

    await for (final String dataLine in response.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())) {
      final responseData = ChatResponseData.fromJson(jsonDecode(dataLine));
      yield responseData;
    }
  }

  /// Chat request (No streaming)
  Future<ChatResponseData> chatWithoutStream(
      ChatRequestData chatRequest) async {
    var url = Uri.parse('http://$endpoint/chat');
    var headers = {'Content-Type': 'application/json'};

    var body =
        jsonEncode(chatRequest.toJson()..putIfAbsent('stream', () => false));

    final response = await client.post(url, body: body, headers: headers);
    final result = ChatResponseData.fromJson(jsonDecode(response.body));
    assert(result.done, true);
    return result;
  }
}
