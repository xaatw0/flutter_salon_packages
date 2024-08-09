import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ollama_talk/ollama_talk.dart';

void main() {
  group('LlmModel', () {
    test('1. Create class instance using the constructor', () {
      final modelDetails = ModelDetails(
        format: 'gguf',
        family: 'llama',
        families: [],
        parameterSize: '13B',
        quantizationLevel: 'Q4_0',
      );

      final model = LlmModel(
        'codellama:13b',
        modifiedAt: DateTime.parse('2023-11-04T14:56:49.277302595-07:00'),
        size: 7365960935,
        digest:
            '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697',
        details: modelDetails,
      );

      expect(model.name, 'codellama:13b');
      expect(model.modifiedAt,
          DateTime.parse('2023-11-04T14:56:49.277302595-07:00'));
      expect(model.size, 7365960935);
      expect(model.digest,
          '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697');
      expect(model.details?.format, 'gguf');
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
      final model = LlmModel.fromJson(jsonData);

      expect(model.name, 'codellama:13b');
      expect(model.modifiedAt,
          DateTime.parse('2023-11-04T14:56:49.277302595-07:00'));
      expect(model.size, 7365960935);
      expect(model.digest,
          '9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697');
      expect(model.details?.format, 'gguf');
    });
  });
}
