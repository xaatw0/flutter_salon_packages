import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flutter Webを使用している場合、漢字入力中にTabを押すと、次にフォーカスが移動し、漢字入力状態が続く。
/// そのため、このWidgetを使用して、この中のTextFieldではTab移動を無効化する。
class CancelTabKey extends StatelessWidget {
  const CancelTabKey({
    super.key,
//    this.onEnterNextFocus = false,
    required this.child,
  });

  final Widget child;

  /// タブ移動ができないので、Enterで次の項目に移動できるようにする
  /* @Deprecated('開発中')
  final bool onEnterNextFocus;
*/
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.physicalKey == PhysicalKeyboardKey.tab) {
            // タブの入力をキャンセルする
            return KeyEventResult.handled;
          } else if ( //onEnterNextFocus &&
              event.physicalKey == PhysicalKeyboardKey.enter) {
            // TODO(xaatw0): Enterで次のフォーカスに移動できるようにする, https://github.com/xaatw0/flutter_engineer_codecheck/issues/91
            node.nextFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// FlutterWebで漢字入力中にTabで推薦文字を選択すると、文字選択で別の場所が指定される。
/// それを防ぐために、文字選択自体をキャンセルする。
class KanjiTextEditingController extends TextEditingController {
  KanjiTextEditingController({super.text}) {
    if (kIsWeb) {
      addListener(_listener);
    }
  }

  /// テキスト指定をなくすためのリスナー
  void _listener() {
    value = value.copyWith(composing: TextRange.empty);
  }

  @override
  void dispose() {
    if (kIsWeb) {
      removeListener(_listener);
    }
    super.dispose();
  }
}
