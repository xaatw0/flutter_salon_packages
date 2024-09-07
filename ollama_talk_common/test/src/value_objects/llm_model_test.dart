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
}
