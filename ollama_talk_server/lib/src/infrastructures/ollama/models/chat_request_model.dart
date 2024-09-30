import 'package:collection/collection.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';

class ChatRequestModel {
  final String model;
  final List<ChatRequestMessage> messages;
  final ChatRequestOptions? options;

  ChatRequestModel({
    required this.model,
    required this.messages,
    this.options,
  });

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatRequestModel(
      model: json['model'],
      messages: (json['messages'] as List)
          .map((message) => ChatRequestMessage.fromJson(message))
          .toList(),
      options: json['options'] != null
          ? ChatRequestOptions.fromJson(json['options'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'options': options?.toJson(),
    };
  }

  @override
  String toString() {
    return 'ChatRequestModel(model: $model, messages: $messages, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRequestModel) return false;
    return model == other.model &&
        ListEquality().equals(messages, other.messages) &&
        options == other.options;
  }

  @override
  int get hashCode => Object.hash(model, messages, options);
}

class ChatRequestMessage {
  final String role;
  final String content;
  final List<String> images;

  ChatRequestMessage({
    required this.role,
    required this.content,
    this.images = const <String>[],
  });

  factory ChatRequestMessage.fromJson(Map<String, dynamic> json) {
    return ChatRequestMessage(
      role: json['role'],
      content: json['content'],
      images: json['images'] == null ? [] : List<String>.from(json['images']),
    );
  }

  factory ChatRequestMessage.fromData(MessageData data) {
    return ChatRequestMessage(role: data.role.name, content: data.content);
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (images.isNotEmpty) 'images': images,
    };
  }

  @override
  String toString() {
    return 'ChatRequestMessage(role: $role, content: $content, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRequestMessage) return false;
    return role == other.role &&
        content == other.content &&
        images == other.images;
  }

  @override
  int get hashCode => Object.hash(role, content, images);
}

class ChatRequestOptions {
  final int? seed;
  final double? temperature;

  ChatRequestOptions({
    this.seed,
    this.temperature,
  });

  factory ChatRequestOptions.fromJson(Map<String, dynamic> json) {
    return ChatRequestOptions(
      seed: json['seed'],
      temperature: json['temperature']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seed': seed,
      'temperature': temperature,
    };
  }

  @override
  String toString() {
    return 'ChatRequestOptions(seed: $seed, temperature: $temperature)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRequestOptions) return false;
    return seed == other.seed && temperature == other.temperature;
  }

  @override
  int get hashCode => Object.hash(seed, temperature);
}
