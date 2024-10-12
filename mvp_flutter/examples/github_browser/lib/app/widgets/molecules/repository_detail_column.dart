import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// レポジトリの詳細を表示する画面での、スターとスター数、などの組み合わせのWidget
class RepositoryDetailColumn extends StatelessWidget {
  const RepositoryDetailColumn(
    this.title,
    this.value, {
    super.key,
  });

  /// タイトル(Stars, Watchers, Forks, issues)
  final String title;

  /// 値(9など)
  final int value;

  static final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      // 「Stars ナイン」とタイトルを先に呼び上げる。
      // そのままだと、「ナイン Stas」と詠まれる
      label: '$title $value',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              formatter.format(value),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.merge(const TextStyle(color: Colors.pinkAccent)),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
