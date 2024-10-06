import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 検索結果がなかったときに残念顔を表示するWidget
class NotFoundResult extends StatelessWidget {
  const NotFoundResult({
    super.key,
  });

  static const _kFace = '(≥o≤)';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        container: true,
        label: AppLocalizations.of(context).notFound,
        child: const AutoSizeText(
          _kFace,
          style: TextStyle(fontSize: 1024),
          maxLines: 1,
        ),
      ),
    );
  }
}
