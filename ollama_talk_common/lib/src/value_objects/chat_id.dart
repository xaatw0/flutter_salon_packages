extension type ChatId(int value) {
  Map<String, dynamic> toJson() {
    return {'chat_id': value};
  }

  factory ChatId.fromJson(Map<String, dynamic> map) {
    return ChatId(map['chat_id']);
  }
}
