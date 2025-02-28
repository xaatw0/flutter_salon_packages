import 'dart:async';

import 'command.dart';
import 'package:http/http.dart' as http;

class GetWikipediaCommand implements ICommand<String, String> {
  static const _kPrefixWiki = 'https://ja.wikipedia.org/wiki/';

  final http.Client _client;

  const GetWikipediaCommand(this._client);

  @override
  FutureOr<String> execute(String data) {
    final url = Uri.parse(_kPrefixWiki + data);
    return _client.get(url).then((response) => response.body);
  }
}
