import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingModel Tests', () {
    test('1. Create class from constructor', () {
      // 1. Create an instance using the constructor
      final embeddingModel = EmbedResponseData(
        model: 'all-minilm',
        embeddings: [
          [
            0.010071029,
            -0.0017594862,
            0.05007221,
            0.04692972,
            0.054916814,
            0.008599704,
            0.105441414,
            -0.025878139,
            0.12958129,
            0.031952348
          ],
          [
            -0.0098027075,
            0.06042469,
            0.025257962,
            -0.006364387,
            0.07272725,
            0.017194884,
            0.09032035,
            -0.051705178,
            0.09951512,
            0.09072481
          ]
        ],
        totalDuration: 14143917,
        loadDuration: 1019500,
        promptEvalCount: 8,
      );

      // Verify the properties
      expect(embeddingModel.model, 'all-minilm');
      expect(embeddingModel.embeddings.length, 2);
      expect(embeddingModel.embeddings[0][0], 0.010071029);
      expect(embeddingModel.embeddings[1][1], 0.06042469);
      expect(embeddingModel.totalDuration, 14143917);
      expect(embeddingModel.loadDuration, 1019500);
      expect(embeddingModel.promptEvalCount, 8);
    });

    group('fromJson', () {
      test('2. Create class from JSON and convert back to JSON', () {
        // 2. Create an instance from JSON
        final json = {
          "model": "all-minilm",
          "embeddings": [
            [
              0.010071029,
              -0.0017594862,
              0.05007221,
              0.04692972,
              0.054916814,
              0.008599704,
              0.105441414,
              -0.025878139,
              0.12958129,
              0.031952348
            ],
            [
              -0.0098027075,
              0.06042469,
              0.025257962,
              -0.006364387,
              0.07272725,
              0.017194884,
              0.09032035,
              -0.051705178,
              0.09951512,
              0.09072481
            ]
          ]
        };

        // Create the object from JSON
        final embeddingModel = EmbedResponseData.fromJson(json);

        // Verify the properties
        expect(embeddingModel.model, 'all-minilm');
        expect(embeddingModel.embeddings.length, 2);
        expect(embeddingModel.embeddings[0][0], 0.010071029);
        expect(embeddingModel.embeddings[1][1], 0.06042469);
        expect(embeddingModel.totalDuration, isNull);
        expect(embeddingModel.loadDuration, isNull);
        expect(embeddingModel.promptEvalCount, isNull);

        // Convert the object back to JSON
        final convertedJson = embeddingModel.toJson();

        // Verify the JSON structure
        expect(convertedJson['model'], 'all-minilm');
        expect(convertedJson['embeddings'][0][0], 0.010071029);
        expect(convertedJson['embeddings'][1][1], 0.06042469);
        expect(convertedJson['total_duration'], null);
        expect(convertedJson['load_duration'], null);
        expect(convertedJson['prompt_eval_count'], null);
      });
    });
    test('2. Create class from JSON and convert back to JSON', () {
      // 2. Create an instance from JSON
      final json = {
        "model": "all-minilm",
        "embeddings": [
          [
            0.010071029,
            -0.0017594862,
            0.05007221,
            0.04692972,
            0.054916814,
            0.008599704,
            0.105441414,
            -0.025878139,
            0.12958129,
            0.031952348
          ]
        ],
        "total_duration": 14143917,
        "load_duration": 1019500,
        "prompt_eval_count": 8
      };

      // Create the object from JSON
      final embeddingModel = EmbedResponseData.fromJson(json);

      // Verify the properties
      expect(embeddingModel.model, 'all-minilm');
      expect(embeddingModel.embeddings.length, 1);
      expect(embeddingModel.embeddings[0][0], 0.010071029);
      expect(embeddingModel.embeddings[0][9], 0.031952348);
      expect(embeddingModel.totalDuration, 14143917);
      expect(embeddingModel.loadDuration, 1019500);
      expect(embeddingModel.promptEvalCount, 8);

      // Convert the object back to JSON
      final convertedJson = embeddingModel.toJson();

      // Verify the JSON structure
      expect(convertedJson['model'], 'all-minilm');
      expect(convertedJson['embeddings'][0][0], 0.010071029);
      expect(convertedJson['total_duration'], 14143917);
      expect(convertedJson['load_duration'], 1019500);
      expect(convertedJson['prompt_eval_count'], 8);
    });
  });
}
