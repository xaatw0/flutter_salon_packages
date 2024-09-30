import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/infrastructures/ollama/models/generate_response_model.dart';
import '../../../ollama_talk_server.dart';
import 'models/tags_response_model.dart';

/// Contact to OllamaServer
class OllamaServer {
  const OllamaServer(this.client, this.endpoint);

  final String endpoint;
  final http.Client client;

  Stream<GenerateResponseModel> generate(String model, String prompt) async* {
    var url = Uri.parse('https://$endpoint/generate');
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
      final responseData = GenerateResponseModel.fromJson(jsonDecode(dataLine));
      yield responseData;
    }
  }

  Future<EmbedResponseModel> embed(String model, String message) async {
    var url = Uri.parse('http://$endpoint/embed');
    var headers = {'Content-Type': 'application/json'};
    String body = jsonEncode({'model': model, 'input': message});

    final response = await client.post(url, body: body, headers: headers);
    return EmbedResponseModel.fromJson(jsonDecode(response.body));
  }

  /// List Local Models
  Future<List<TagsResponseModel>> tags() async {
    var url = Uri.parse('http://$endpoint/tags');
    var headers = {'Content-Type': 'application/json'};

    final response = await client.get(url, headers: headers);
    final modelList = jsonDecode(response.body)['models'] as List<dynamic>;
    return modelList.map((e) => TagsResponseModel.fromJson(e)).toList();
  }

  /// Show Model Information
  Future<ShowResponseModel> show(String name) async {
    final url = Uri.parse('$endpoint/show');
    final body = {'name': name};
    final response = await client.post(url, body: body);

    return ShowResponseModel.fromJson(jsonDecode(response.body));
  }

  /// Pull a Model
  Future<bool> pull(String modelName) async {
    var url = Uri.parse('$endpoint/pull');
    String body = jsonEncode({'name': modelName});
    final response = await client.post(url, body: jsonEncode(body));
    return jsonDecode(response.body)['status'] == 'pulling manifest';
  }

  /// Chat Request (Streaming)
  Stream<ChatResponseModel> chat(ChatRequestModel chatRequest) async* {
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
      final responseData = ChatResponseModel.fromJson(jsonDecode(dataLine));
      yield responseData;
    }
  }

  /// Chat request (No streaming)
  Future<ChatResponseModel> chatWithoutStream(
      ChatRequestModel chatRequest) async {
    var url = Uri.parse('http://$endpoint/chat');
    var headers = {'Content-Type': 'application/json'};

    var body =
        jsonEncode(chatRequest.toJson()..putIfAbsent('stream', () => false));

    final response = await client.post(url, body: body, headers: headers);
    return ChatResponseModel.fromJson(jsonDecode(response.body));
  }
}
