import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

void main() {
  group('ChatRequestModel Tests', () {
    test('1. Create class from constructor', () {
      // 1. コンストラクタからインスタンスを作成
      final message1 = ChatRequestMessage(role: 'user', content: 'Hello!');
      final options = ChatRequestOptions(seed: 101, temperature: 0.0);
      final chatRequestModel = ChatRequestModel(
        model: 'llama3.2',
        messages: [message1],
        options: options,
      );

      // プロパティの確認
      expect(chatRequestModel.model, 'llama3.2');
      expect(chatRequestModel.messages.length, 1);
      expect(chatRequestModel.messages[0].role, 'user');
      expect(chatRequestModel.messages[0].content, 'Hello!');
      expect(chatRequestModel.options?.seed, 101);
      expect(chatRequestModel.options?.temperature, 0.0);
    });

    test('image あり', () {
      final message1 =
          ChatRequestMessage(role: 'user', content: 'Hello!', images: ['test']);
      final chatRequestModel = ChatRequestModel(
        model: 'llama3.2',
        messages: [message1],
      );
      expect(chatRequestModel.toJson()['messages'][0]['images'][0], 'test');
      expect(
          chatRequestModel.toJson()['messages'][0].containsKey('images'), true);
    });
    test('image なし', () {
      final message1 = ChatRequestMessage(role: 'user', content: 'Hello!');
      final chatRequestModel = ChatRequestModel(
        model: 'llama3.2',
        messages: [message1],
      );
      expect(chatRequestModel.toJson()['messages'][0]['images'], isNull);
      expect(
        chatRequestModel.toJson()['messages'][0].containsKey('images'),
        false,
      );
    });
  });

  group('from json', () {
    test('パターン1: 通常', () {
      // パターン1: JSONからインスタンスを作成
      final json1 = {
        "model": "llama3.2",
        "messages": [
          {"role": "user", "content": "why is the sky blue?"}
        ]
      };

      final chatRequestModel = ChatRequestModel.fromJson(json1);

      // プロパティの確認
      expect(chatRequestModel.model, 'llama3.2');
      expect(chatRequestModel.messages.length, 1);
      expect(chatRequestModel.messages[0].role, 'user');
      expect(chatRequestModel.messages[0].content, 'why is the sky blue?');
      expect(chatRequestModel.options, isNull); // オプションなし

      // オブジェクトをJSONに変換
      final convertedJson1 = chatRequestModel.toJson();

      // JSON構造の確認
      expect(convertedJson1['model'], 'llama3.2');
      expect(convertedJson1['messages'][0]['role'], 'user');
      expect(convertedJson1['messages'][0]['content'], 'why is the sky blue?');
    });

    test('メッセージ履歴あり自利歴あり', () {
      // パターン2: JSONからインスタンスを作成
      final json2 = {
        "model": "llama3.2",
        "messages": [
          {"role": "user", "content": "why is the sky blue?"},
          {"role": "assistant", "content": "due to rayleigh scattering."},
          {
            "role": "user",
            "content": "how is that different than mie scattering?"
          }
        ]
      };

      final chatRequestModel = ChatRequestModel.fromJson(json2);

      // プロパティの確認
      expect(chatRequestModel.model, 'llama3.2');
      expect(chatRequestModel.messages.length, 3);
      expect(chatRequestModel.messages[0].role, 'user');
      expect(chatRequestModel.messages[0].content, 'why is the sky blue?');
      expect(chatRequestModel.messages[1].role, 'assistant');
      expect(
          chatRequestModel.messages[1].content, 'due to rayleigh scattering.');
      expect(chatRequestModel.messages[2].role, 'user');
      expect(chatRequestModel.messages[2].content,
          'how is that different than mie scattering?');

      // オブジェクトをJSONに変換
      final convertedJson2 = chatRequestModel.toJson();

      // JSON構造の確認
      expect(convertedJson2['model'], 'llama3.2');
      expect(convertedJson2['messages'][0]['role'], 'user');
      expect(convertedJson2['messages'][0]['content'], 'why is the sky blue?');
      expect(convertedJson2['messages'][1]['role'], 'assistant');
      expect(convertedJson2['messages'][1]['content'],
          'due to rayleigh scattering.');
      expect(convertedJson2['messages'][2]['role'], 'user');
      expect(convertedJson2['messages'][2]['content'],
          'how is that different than mie scattering?');
    });

    test('画像付きのメッセージ', () {
      final json3 = {
        "model": "llava",
        "messages": [
          {
            "role": "user",
            "content": "what is in this image?",
            "images": ["iVBORw0KGgoAAAANSUhEUgAAAG0AAABmCAYAAADBP"]
          }
        ]
      };

      final chatRequestModel = ChatRequestModel.fromJson(json3);

      // プロパティの確認
      expect(chatRequestModel.model, 'llava');
      expect(chatRequestModel.messages.length, 1);
      expect(chatRequestModel.messages[0].role, 'user');
      expect(chatRequestModel.messages[0].content, 'what is in this image?');
      expect(chatRequestModel.messages[0].images.length, 1);
      expect(chatRequestModel.messages[0].images[0],
          'iVBORw0KGgoAAAANSUhEUgAAAG0AAABmCAYAAADBP');

      // オブジェクトをJSONに変換
      final convertedJson3 = chatRequestModel.toJson();

      // JSON構造の確認
      expect(convertedJson3['model'], 'llava');
      expect(convertedJson3['messages'][0]['role'], 'user');
      expect(
          convertedJson3['messages'][0]['content'], 'what is in this image?');
      expect(convertedJson3['messages'][0]['images'][0],
          'iVBORw0KGgoAAAANSUhEUgAAAG0AAABmCAYAAADBP');
    });

    test('optionsつき', () {
      // パターン4: JSONからインスタンスを作成
      final json4 = {
        "model": "llama3.2",
        "messages": [
          {"role": "user", "content": "Hello!"}
        ],
        "options": {"seed": 101, "temperature": 0}
      };

      final chatRequestModel = ChatRequestModel.fromJson(json4);

      // プロパティの確認
      expect(chatRequestModel.model, 'llama3.2');
      expect(chatRequestModel.messages.length, 1);
      expect(chatRequestModel.messages[0].role, 'user');
      expect(chatRequestModel.messages[0].content, 'Hello!');
      expect(chatRequestModel.options?.seed, 101);
      expect(chatRequestModel.options?.temperature, 0.0);

      // オブジェクトをJSONに変換
      final convertedJson4 = chatRequestModel.toJson();

      // JSON構造の確認
      expect(convertedJson4['model'], 'llama3.2');
      expect(convertedJson4['messages'][0]['role'], 'user');
      expect(convertedJson4['messages'][0]['content'], 'Hello!');
      expect(convertedJson4['options']['seed'], 101);
      expect(convertedJson4['options']['temperature'], 0.0);
    });
  });

  group('ChatRequestMessage', () {
    test('MessageData', () {
      final messageData = MessageData(Role.system, 'content');
      final result = ChatRequestMessage.fromData(messageData);
      expect(result.role, 'system');
      expect(result.content, 'content');
    });
  });
}
