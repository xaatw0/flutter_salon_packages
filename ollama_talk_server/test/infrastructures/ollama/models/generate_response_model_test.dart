import 'package:ollama_talk_server/src/infrastructures/ollama/models/generate_response_model.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateResponseModel tests', () {
    // 1. 通常のコンストラクタからクラスを作成するテスト
    test('Create instance using constructor', () {
      final model = GenerateResponseModel(
        model: 'llama3.2',
        createdAt: DateTime.parse('2023-08-04T08:52:19.385406455-07:00'),
        response: 'The',
        done: false,
      );

      expect(model.model, 'llama3.2');
      expect(model.createdAt,
          DateTime.parse('2023-08-04T08:52:19.385406455-07:00'));
      expect(model.response, 'The');
      expect(model.done, false);
    });

    // 2. Jsonからクラスを作成し、toJsonメソッドで再変換するテスト
    test('Create instance from JSON and convert back to JSON', () {
      final json = {
        "model": "llama3.2",
        "created_at": "2023-08-04T19:22:45.499127Z",
        "response": "The sky is blue because it is the color of the sky.",
        "done": true,
        "context": [1, 2, 3],
        "total_duration": 5043500667,
        "load_duration": 5025959,
        "prompt_eval_count": 26,
        "prompt_eval_duration": 325953000,
        "eval_count": 290,
        "eval_duration": 4709213000
      };

      final model = GenerateResponseModel.fromJson(json);

      expect(model.model, 'llama3.2');
      expect(model.createdAt, DateTime.parse('2023-08-04T19:22:45.499127Z'));
      expect(model.response,
          'The sky is blue because it is the color of the sky.');
      expect(model.done, true);
      expect(model.context, [1, 2, 3]);
      expect(model.totalDuration, 5043500667);
      expect(model.loadDuration, 5025959);
      expect(model.promptEvalCount, 26);
      expect(model.promptEvalDuration, 325953000);
      expect(model.evalCount, 290);
      expect(model.evalDuration, 4709213000);

      // JSONに戻す
      final jsonBack = model.toJson();
      expect(jsonBack['model'], 'llama3.2');
      expect(jsonBack['created_at'], '2023-08-04T19:22:45.499127Z');
      expect(jsonBack['response'],
          'The sky is blue because it is the color of the sky.');
      expect(jsonBack['done'], true);
      expect(jsonBack['context'], [1, 2, 3]);
      expect(jsonBack['total_duration'], 5043500667);
      expect(jsonBack['load_duration'], 5025959);
      expect(jsonBack['prompt_eval_count'], 26);
      expect(jsonBack['prompt_eval_duration'], 325953000);
      expect(jsonBack['eval_count'], 290);
      expect(jsonBack['eval_duration'], 4709213000);
    });
  });
}
