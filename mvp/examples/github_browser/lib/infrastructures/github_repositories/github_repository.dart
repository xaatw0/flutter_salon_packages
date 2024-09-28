import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:github_browser/domain/service_locator.dart';

import '../../domain/entities/git_repository_data.dart';
import '../../domain/repositories/git_repository.dart';
import 'entities.dart';
import 'package:github_browser/domain/value_objects/value_objects.dart';

/// Githubからデータを取得するためのレポジトリクラス。
/// 検索時に発生するエラー
/// ・ネットワークが繋がっていない、または遅い
/// ・WebAPIの形式が変更された
class GithubRepository implements GitRepository {
  /// パラメータのキーワードの置換用文字列
  static const kParamKeyword = '<keyword>';

  /// パラメータのページ数の置換用文字列
  static const kParamPage = '<page>';

  /// パラメータのソート方法の置換用文字列
  static const kParamSort = '<sort>';

  /// パラメータのソートの昇順・降順の置換用文字列
  static const kParamOrder = '<order>';

  /// Github APIへソート条件をベストマッチ(デフォルト)でアクセスするためのURL
  static const String kApiUrlForBestMatch =
      'https://api.github.com/search/repositories?q=$kParamKeyword&page=$kParamPage';

  /// Github APIへソート条件をつけてアクセスするためのURL
  static const String kApiUrl =
      '$kApiUrlForBestMatch&sort=$kParamSort&order=$kParamOrder';

  /// 「検索結果の表示順」のソートの並び順とパラメータのキーワードとの対応表
  /// asc,descはGithub特有のため、SortMethodではなく、本クラスに入れる
  static const kMapOrder = <String, List<SortMethod>>{
    'asc': [
      SortMethod.starAsc,
      SortMethod.forkAsc,
      SortMethod.leastRecentlyUpdate
    ],
    'desc': [
      SortMethod.starDesc,
      SortMethod.forkDesc,
      SortMethod.recentlyUpdated,
    ],
  };

  /// 「検索結果の表示順」のソートの方法とパラメータのキーワードとの対応表
  /// start, forks, updatedは、Github特有のため、SortMethodではなく、本クラスに入れる
  static const kMapSort = <String, List<SortMethod>>{
    'stars': [SortMethod.starAsc, SortMethod.starDesc],
    'forks': [SortMethod.forkAsc, SortMethod.forkDesc],
    'updated': [
      SortMethod.recentlyUpdated,
      SortMethod.leastRecentlyUpdate,
    ],
  };

  @override
  Future<List<GitRepositoryData>> search(
    String keyword, {
    int page = 1,
    SortMethod sortMethod = SortMethod.bestMatch,
  }) async {
    final uri = getSearchUrl(keyword, page, sortMethod);
    final apiUri = Uri.parse(uri);

    final client = ServiceLocator.instance.httpClient;
    final response = await client.get(apiUri);

    return useIsolateIfPossible(response.body);
  }

  /// キーワード、ページ、ソート条件に基づいた検索用のURLを発行する
  String getSearchUrl(String keyword, int page, SortMethod sortMethod) {
    if (sortMethod == SortMethod.bestMatch) {
      return kApiUrlForBestMatch
          .replaceFirst(kParamKeyword, keyword)
          .replaceFirst(kParamPage, page.toString());
    } else {
      final paramSort = kMapSort.keys
          .where((key) => kMapSort[key]!.contains(sortMethod))
          .first;
      final paramOrder = kMapOrder.keys
          .where((key) => kMapOrder[key]!.contains(sortMethod))
          .first;

      return kApiUrl
          .replaceFirst(kParamKeyword, keyword)
          .replaceFirst(kParamPage, page.toString())
          .replaceFirst(kParamSort, paramSort)
          .replaceFirst(kParamOrder, paramOrder);
    }
  }

  /// Web APIにて取得したデータをJSON処理してレポジトリの情報を返す
  List<GitRepositoryData> fromJson(String jsonData) {
    final gitHubResponse = GitHubResponse.fromJson(jsonDecode(jsonData));

    return gitHubResponse.items
        .map((item) => convertToDomainData(item))
        .toList();
  }

  GitRepositoryData convertToDomainData(Item item) {
    return GitRepositoryData(
      repositoryId: RepositoryId(item.id),
      repositoryName: RepositoryName(item.name),
      ownerIconUrl: OwnerIconUrl(item.owner.avatarUrl),
      projectLanguage: ProjectLanguage(item.language),
      repositoryDescription: RepositoryDescription(item.description),
      countStar: CountStar(item.stargazersCount),
      countWatcher: CountWatcher(item.watchersCount),
      countFork: CountFork(item.forksCount),
      countIssue: CountIssue(item.openIssuesCount),
      repositoryHtmlUrl: RepositoryHtmlUrl(item.htmlUrl),
      createTime: RepositoryCreateTime(item.createdAt),
      updateTime: RepositoryUpdateTime(item.updatedAt),
    );
  }

  /// Isolateを使ってJsonの処理をする。ただし、テストの場合はIsolateは使えない。
  Future<List<GitRepositoryData>> useIsolateIfPossible(String json) async {
    // Webもしくは、アプリ起動時(テストでない)
    if (kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST')) {
      return compute<String, List<GitRepositoryData>>(
        fromJson,
        json,
      );
    }

    return fromJson(json);
  }

  @override
  int getFirstPageIndex() {
    return 1;
  }
}
