enum Role { user, assistant, system }

class MessageData {
  const MessageData(this.role, this.content);
  final Role role;
  final String content;
}
