import 'dart:convert';

import 'package:ollama_talk_client/ollama_talk_client.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';

class ModelApi {
  ModelApi(this.infraInfo);

  final InfraInfo infraInfo;

  Future<List<LlmModel>> loadLlmModelList() async {
    final apiPath = '/models';

    final url = Uri.parse('http://${infraInfo.apiUrlBase}$apiPath');
    final response = await infraInfo.httpClient.get(url);
    final json = jsonDecode(response.body);

    final list = LlmModel.fromJsonList(jsonDecode(json['llmModels']));
    return list;
  }
}
