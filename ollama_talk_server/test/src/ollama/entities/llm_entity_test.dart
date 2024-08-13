import 'dart:convert';

import 'package:ollama_talk_common/value_objects.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

void main() {
  test('1. Create class instance using the constructor', () {
    final llmDetailsEntity = LlmDetailsEntity(
      format: 'gguf',
      family: 'llama',
      families: [],
      parameterSize: '13B',
      quantizationLevel: 'Q4_0',
    );

    final llmEntity = LlmEntity(
      name: 'codellama:13b',
      modifiedAt: DateTime.parse('2023-11-04T14:56:49.277302595-07:00'),
      size: 7365960935,
      digest:
          '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697',
      details: llmDetailsEntity,
    );

    expect(llmEntity.name, 'codellama:13b');
    expect(llmEntity.modifiedAt,
        DateTime.parse('2023-11-04T14:56:49.277302595-07:00'));
    expect(llmEntity.size, 7365960935);
    expect(llmEntity.digest,
        '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697');
    expect(llmEntity.details?.format, 'gguf');

    expect(llmEntity is LlmModel, true);
    final llmModel = llmEntity as LlmModel;
    expect(llmModel(), 'codellama:13b');
  });

  test('2. Create class instance from JSON and convert back to JSON', () {
    final jsonString = '''
      {
        "name": "codellama:13b",
        "modified_at": "2023-11-04T14:56:49.277302595-07:00",
        "size": 7365960935,
        "digest": "9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697",
        "details": {
          "format": "gguf",
          "family": "llama",
          "families": null,
          "parameter_size": "13B",
          "quantization_level": "Q4_0"
        }
      }
      ''';

    final jsonData = json.decode(jsonString);
    final model = LlmEntity.fromJson(jsonData);

    expect(model.name, 'codellama:13b');
    expect(model.modifiedAt,
        DateTime.parse('2023-11-04T14:56:49.277302595-07:00'));
    expect(model.size, 7365960935);
    expect(model.digest,
        '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697');
    expect(model.details?.format, 'gguf');
  });
}
