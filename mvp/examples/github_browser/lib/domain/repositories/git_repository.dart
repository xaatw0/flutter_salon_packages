import '../entities/git_repository_data.dart';

/// Gitの検索結果の表示順
enum SortMethod {
  /// ベストマッチ順
  bestMatch('Best match'),

  /// スターが多い順
  starDesc('Most stars'),

  /// スターが少ない順
  starAsc('Fewest stars'),

  /// フォークが多い順
  forkDesc('Most forks'),

  /// フォークが少ない順
  forkAsc('Fewest forks'),

  /// 更新日時が新しい順
  recentlyUpdated('Recently updated'),

  /// 更新日時が古い順
  leastRecentlyUpdate('Least recently updated');

  const SortMethod(this.title);

  /// 画面に表示するタイトル
  final String title;
  String toJson() => toString();
}

/// Gitからデータを取得するためのレポジトリクラス (Gitのソース解離のレポジトリと間違えやすい)。
/// Githubだけではなく、他のGitでデータ取得をするケースも想定して、抽象クラスを作成する。
abstract class GitRepository {
  /// キーワードに対する検索結果を取得する
  /// [page]で何ページ目かを指定する。Githubでは、最初のページは1ページ目。
  Future<List<GitRepositoryData>> search(
    String keyword, {
    int page = 1,
    SortMethod sortMethod,
  });

  /// 最初の1ページ目のインデックス
  int getFirstPageIndex();
}
