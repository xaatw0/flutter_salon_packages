import '../value_objects/value_objects.dart';

class GitRepositoryData {
  const GitRepositoryData({
    required this.repositoryId,
    required this.repositoryName,
    required this.ownerIconUrl,
    required this.projectLanguage,
    required this.repositoryDescription,
    required this.countStar,
    required this.countWatcher,
    required this.countFork,
    required this.countIssue,
    required this.repositoryHtmlUrl,
    required this.createTime,
    required this.updateTime,
  });

  /// 該当リポジトリのリポジトリID
  final RepositoryId repositoryId;

  /// 該当リポジトリのリポジトリ名
  final RepositoryName repositoryName;

  /// 該当リポジトリのオーナーアイコン
  final OwnerIconUrl ownerIconUrl;

  /// 該当リポジトリのプロジェクト言語
  final ProjectLanguage projectLanguage;

  /// 該当リポジトリの概要
  final RepositoryDescription repositoryDescription;

  /// 該当リポジトリのStar 数
  final CountStar countStar;

  /// 該当リポジトリのWatcher 数
  final CountWatcher countWatcher;

  /// 該当リポジトリのFork 数
  final CountFork countFork;

  /// 該当リポジトリのIssue 数
  final CountIssue countIssue;

  /// 該当レポジトリのHtmlUrl
  final RepositoryHtmlUrl repositoryHtmlUrl;

  /// 該当レポジトリの作成日時
  final RepositoryCreateTime createTime;

  /// 該当レポジトリの更新日時
  final RepositoryUpdateTime updateTime;
}
