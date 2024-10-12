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

  static GitRepositoryData empty = GitRepositoryData(
      repositoryId: const RepositoryId(-1),
      repositoryName: const RepositoryName(''),
      ownerIconUrl: const OwnerIconUrl(''),
      projectLanguage: const ProjectLanguage(''),
      repositoryDescription: const RepositoryDescription(''),
      countStar: const CountStar(-1),
      countWatcher: const CountWatcher(-1),
      countFork: const CountFork(-1),
      countIssue: const CountIssue(-1),
      repositoryHtmlUrl: const RepositoryHtmlUrl(''),
      createTime: RepositoryCreateTime(DateTime(0)),
      updateTime: RepositoryUpdateTime(DateTime(0)));
}
