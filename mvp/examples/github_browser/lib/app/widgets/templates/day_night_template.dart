/*
import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/ui/app_theme.dart' as app_theme;
import 'package:flutter_engineer_codecheck/ui/responsive.dart';
import 'package:flutter_engineer_codecheck/ui/widgets/organisms/sun_and_moon_coin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/string_resources.dart';

/// ライトテーマとダークテーマの切り替えボタンのあるテンプレート。
class DayNightTemplate extends StatelessWidget {
  const DayNightTemplate({
    super.key,
    this.title,
    required this.child,
    this.isAppBarShown = true,
    this.hasPadding = true,
  });

  /// 中身のWidget
  final Widget child;

  /// アップバーに表示するタイトル
  final String? title;

  /// アップバーを表示するか(true:表示 false:非表示)
  /// 画面を横向きにしたときのスペース確保のために非表示にできる
  final bool isAppBarShown;

  /// 標準のパディングをつけるか
  final bool hasPadding;

  /// 標準のパディングの幅
  static const normalPaddingSize = 16.0;

  /// 狭いパディングの幅
  static const narrowPaddingSize = 4.0;

  /// パッディング
  static const paddingSize = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAppBarShown && hasPadding
          ? AppBar(
              toolbarHeight: 64,
              title: Text(title ?? StringResources.kEmpty),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(paddingSize),
                  child: Semantics(
                    container: true,
                    label: AppLocalizations.of(context).swapTheme,
                    child: Consumer(
                      builder: (_, WidgetRef ref, __) {
                        return SunAndMoonCoin(
                          // パディングを増やすと、SVGの大きさが小さくなるっぽい
                          size: 48 + paddingSize * 2,
                          callback: (CoinStatus status) =>
                              changeTheme(ref, status),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            normalPaddingSize,
            hasPadding ? normalPaddingSize : narrowPaddingSize,
            normalPaddingSize,
            0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Responsive.breakLarge,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// テーマモードを変更する
  void changeTheme(WidgetRef ref, CoinStatus status) {
    ref.read(app_theme.themeMode.notifier).state =
        status == CoinStatus.sun ? ThemeMode.light : ThemeMode.dark;
  }
}
*/
