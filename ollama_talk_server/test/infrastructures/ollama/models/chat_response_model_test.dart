import 'package:ollama_talk_server/src/infrastructures/ollama/models/chat_response_model.dart';
import 'package:test/test.dart';

void main() {
  group('ChatResponseModel Tests', () {
    test('1. Create class from constructor', () {
      // コンストラクタからインスタンスを作成
      final message = ChatResponseMessage(
        role: 'assistant',
        content: 'Hello! How are you today?',
        images: null,
      );

      final chatResponse = ChatResponseModel(
        model: 'llama3.2',
        createdAt: DateTime.parse('2023-12-12T14:13:43.416799Z'),
        message: message,
        done: true,
        totalDuration: 5191566416,
        loadDuration: 2154458,
        promptEvalCount: 26,
        promptEvalDuration: 383809000,
        evalCount: 298,
        evalDuration: 4799921000,
      );

      // プロパティの確認
      expect(chatResponse.model, 'llama3.2');
      expect(chatResponse.createdAt.toIso8601String(),
          '2023-12-12T14:13:43.416799Z');
      expect(chatResponse.message?.role, 'assistant');
      expect(chatResponse.message?.content, 'Hello! How are you today?');
      expect(chatResponse.done, true);
      expect(chatResponse.totalDuration, 5191566416);
      expect(chatResponse.loadDuration, 2154458);
      expect(chatResponse.promptEvalCount, 26);
      expect(chatResponse.promptEvalDuration, 383809000);
      expect(chatResponse.evalCount, 298);
      expect(chatResponse.evalDuration, 4799921000);
    });

    group('fromJson', () {
      test('未完了', () {
        // パターン1: JSONからインスタンスを作成
        final json = {
          "model": "llama3.2",
          "created_at": "2023-08-04T08:52:19.385406455-07:00",
          "message": {"role": "assistant", "content": "The", "images": null},
          "done": false
        };

        // JSONからオブジェクトを作成
        final chatResponse = ChatResponseModel.fromJson(json);

        // プロパティの確認
        expect(chatResponse.model, 'llama3.2');
        expect(chatResponse.createdAt.toIso8601String(),
            '2023-08-04T15:52:19.385406Z'); // -7で時差補正分
        expect(chatResponse.message?.role, 'assistant');
        expect(chatResponse.message?.content, 'The');
        expect(chatResponse.message?.images, isNull);
        expect(chatResponse.done, false);
      });

      test('完了', () {
        final json = {
          "model": "llama3.2",
          "created_at": "2023-08-04T19:22:45.499127Z",
          "done": true,
          "total_duration": 4883583458,
          "load_duration": 1334875,
          "prompt_eval_count": 26,
          "prompt_eval_duration": 342546000,
          "eval_count": 282,
          "eval_duration": 4535599000
        };

        // JSONからオブジェクトを作成
        final chatResponse = ChatResponseModel.fromJson(json);

        // プロパティの確認
        expect(chatResponse.model, 'llama3.2');
        expect(chatResponse.createdAt.toIso8601String(),
            '2023-08-04T19:22:45.499127Z');
        expect(chatResponse.done, true);
        expect(chatResponse.totalDuration, 4883583458);
        expect(chatResponse.loadDuration, 1334875);
        expect(chatResponse.promptEvalCount, 26);
        expect(chatResponse.promptEvalDuration, 342546000);
        expect(chatResponse.evalCount, 282);
        expect(chatResponse.evalDuration, 4535599000);
      });

      test('画像付き', () {
        final json = {
          "model": "llava",
          "created_at": "2023-12-13T22:42:50.203334Z",
          "message": {
            "role": "assistant",
            "content":
                "The image features a cute, little pig with an angry facial expression. It's wearing a heart on its shirt and is waving in the air. This scene appears to be part of a drawing or sketching project.",
            "images": null
          },
          "done": true,
          "total_duration": 1668506709,
          "load_duration": 1986209,
          "prompt_eval_count": 26,
          "prompt_eval_duration": 359682000,
          "eval_count": 83,
          "eval_duration": 1303285000
        };

        // JSONからオブジェクトを作成
        final chatResponse = ChatResponseModel.fromJson(json);

        // プロパティの確認
        expect(chatResponse.model, 'llava');
        expect(chatResponse.createdAt.toIso8601String(),
            '2023-12-13T22:42:50.203334Z');
        expect(chatResponse.message?.role, 'assistant');
        expect(chatResponse.message?.content,
            "The image features a cute, little pig with an angry facial expression. It's wearing a heart on its shirt and is waving in the air. This scene appears to be part of a drawing or sketching project.");
        expect(chatResponse.done, true);
        expect(chatResponse.totalDuration, 1668506709);
        expect(chatResponse.loadDuration, 1986209);
        expect(chatResponse.promptEvalCount, 26);
        expect(chatResponse.promptEvalDuration, 359682000);
        expect(chatResponse.evalCount, 83);
        expect(chatResponse.evalDuration, 1303285000);
      });

      test('No streaming/Reproducible outputs', () {
        final json = {
          "model": "llama3.2",
          "created_at": "2023-12-12T14:13:43.416799Z",
          "message": {
            "role": "assistant",
            "content": "Hello! How are you today?"
          },
          "done": true,
          "total_duration": 5191566416,
          "load_duration": 2154458,
          "prompt_eval_count": 26,
          "prompt_eval_duration": 383809000,
          "eval_count": 298,
          "eval_duration": 4799921000
        };

        // JSONからオブジェクトを作成
        final chatResponse = ChatResponseModel.fromJson(json);

        // プロパティの確認
        expect(chatResponse.model, 'llama3.2');
        expect(chatResponse.createdAt.toIso8601String(),
            '2023-12-12T14:13:43.416799Z');
        expect(chatResponse.message?.role, 'assistant');
        expect(chatResponse.message?.content, 'Hello! How are you today?');
        expect(chatResponse.done, true);
        expect(chatResponse.totalDuration, 5191566416);
        expect(chatResponse.loadDuration, 2154458);
        expect(chatResponse.promptEvalCount, 26);
        expect(chatResponse.promptEvalDuration, 383809000);
        expect(chatResponse.evalCount, 298);
        expect(chatResponse.evalDuration, 4799921000);
      });
    });
  });
}
