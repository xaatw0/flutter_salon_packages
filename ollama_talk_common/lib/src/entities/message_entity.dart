enum Role { user, assistant, system }

class MessageEntity {
  const MessageEntity(this.role, this.content);
  final Role role;
  final String content;
}
