import 'dart:convert';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:test/test.dart';

void main() {
  test('fromJsonList', () {
    final source = '{\"models\": [\"model1\", \"model2\"]}';
    final json = jsonDecode(source);
    final result = LlmModel.fromJsonList(json['models']);
    expect(result.length, 2);
    expect(result[0](), 'model1');
    expect(result[1](), 'model2');
  });

  test('fromJsonList2', () {
    final source =
        '[\"elyza:jp8b\",\"gozaru:latest\",\"sha:latest\",\"yuko:latest\",\"llama3:latest\"]';
    final result = LlmModel.fromJsonList(jsonDecode(source));
    expect(result.length, 5);
    expect(result[0](), 'elyza:jp8b');
    expect(result[1](), 'gozaru:latest');
    expect(result[2](), 'sha:latest');
    expect(result[3](), 'yuko:latest');
    expect(result[4](), 'llama3:latest');
  });
}
