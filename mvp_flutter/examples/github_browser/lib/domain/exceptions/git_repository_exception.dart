import 'dart:io';

/// Gitシステムに通信時に発生するエラー
/// ・ネットワークが繋がっていない
/// ・URLを間違えている
/// ・データが欠けている→TCP/IPを信じるので、ひとまず考えない
class GitRepositoryException implements Exception {
  const GitRepositoryException({
    this.exception,
    required this.message,
    this.stackTrace,
  });

  /// 通信エラーによる例外(サーバに達しなかった場合)
  const GitRepositoryException.notConnected(
    SocketException exception, {
    StackTrace? stackTrace,
  }) : this(
          exception: exception,
          stackTrace: stackTrace,
          message: _notConnectionMessage,
        );

  /// データフォーマットによる例外(サーバには達したが、無効なデータが返信された場合)
  const GitRepositoryException.validationFailed({StackTrace? stackTrace})
      : this(
          message: _incorrectFormat,
          stackTrace: stackTrace,
        );

  /// 未接続時の対応依頼メッセージ
  static const _notConnectionMessage =
      'Cannot connect to Github API. Check internet connection.'
      'If you have no problem with the connection,'
      'please connect after a while';

  /// リクエストに問題があったときの対応以来メッセージ
  static const _incorrectFormat =
      'Data not accepted due to incorrect data format.'
      'Try again, and if not, contact the administrator. ';

  /// 基の例外
  final Exception? exception;

  /// ユーザへの対応メッセージ
  final String message;

  /// スタックトレース
  final StackTrace? stackTrace;
}
