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

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (images.isNotEmpty) 'images': images,
    };
  }
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
}
