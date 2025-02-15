/// FileEntity クラス
/// ファイル情報を保持するエンティティクラスです。
/// このクラスは、ファイル名、内容、およびエラー情報を保持します。
class FileEntity {
  /// ファイル名
  final String fileName;

  /// ファイルのコンテンツ
  final String content;

  /// エラー内容 (null許可)
  final String? errorMessage;

  /// 全てを含むコンストラクタ
  const FileEntity({
    required this.fileName,
    required this.content,
    this.errorMessage,
  });

  factory FileEntity.file(String fileName, String content) {
    return FileEntity(fileName: fileName, content: content);
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is FileEntity) {
      return this.runtimeType == other.runtimeType &&
          this.fileName == other.fileName &&
          this.content == other.content &&
          this.errorMessage == other.errorMessage;
    } else {
      return false;
    }
  }

  factory FileEntity.error(String fileName, String errorMessage) {
    return FileEntity(
      fileName: fileName,
      content: '',
      errorMessage: errorMessage,
    );
  }

  /// JSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'content': content,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  /// JSONからクラスを作成するメソッド
  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      fileName: json['fileName'],
      content: json['content'],
      errorMessage: json['errorMessage'],
    );
  }
}
