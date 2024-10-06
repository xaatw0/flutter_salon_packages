/// SearchPageで表示するWidgetを決めるロジック
class VisibleWidgetLogic {
  const VisibleWidgetLogic({
    required this.isWeb,
    required this.isPortrait,
    required this.isKeyboardShown,
    required this.isTextInputted,
  });

  /// WEBブラウザでの表示か
  final bool isWeb;

  /// 画面が縦向きか
  final bool isPortrait;

  /// キーボードが表示されているか
  final bool isKeyboardShown;

  /// テキストが入力されているか
  final bool isTextInputted;

  /// ロゴを表示するか true:表示 false:非表示
  bool get isLogoVisible =>
      isWeb ||
      isPortrait ||
      (!isPortrait && !isKeyboardShown && !isTextInputted);

  /// 検索ボタンを表示するか true:表示 false:非表示
  bool get isButtonVisible => isWeb || (!isKeyboardShown && isTextInputted);

  /// パディングをつけるか true:つける false:最低限にする
  bool get hasPadding => isWeb || isPortrait || (!isKeyboardShown);
}
