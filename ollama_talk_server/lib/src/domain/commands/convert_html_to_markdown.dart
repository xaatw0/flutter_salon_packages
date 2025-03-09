import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:html2md/html2md.dart' as html2md;

class ConvertHtmlToMarkdown implements ICommand<String, String> {
  @override
  String execute(String html) {
    return html2md.convert(html);
  }
}
