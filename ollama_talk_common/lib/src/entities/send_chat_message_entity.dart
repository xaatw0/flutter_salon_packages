class SendChatMessageEntity {
  final String prompt;
  final int chatId;

  const SendChatMessageEntity({
    required this.prompt,
    required this.chatId,
  });

  factory SendChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return SendChatMessageEntity(
      prompt: json['prompt'],
      chatId: json['chat_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'chat_id': chatId,
    };
  }
}
