import 'package:flutter/cupertino.dart';
import 'package:github_browser/domain/repositories/git_repository.dart';
import 'package:github_browser/infrastructures/github_repositories/github_repository.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ?? ServiceLocator._();

  ServiceLocator._();

  @visibleForTesting
  static void setMock(ServiceLocator mock) {
    _instance = mock;
  }

  final http.Client _httpClient = http.Client();
  http.Client get httpClient => _httpClient;

  final GitRepository _gitRepository = GithubRepository();
  GitRepository get gitRepository => _gitRepository;
}
