import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mvp_flutter/mvp_flutter.dart';

import '../../pages/common/day_night_template_views.dart';

/// ライトテーマとダークテーマの切り替えボタンのあるテンプレート。
class DayNightTemplate extends StatefulWidget {
  const DayNightTemplate({
    super.key,
    required this.child,
    this.title = '',
  });

  /// 中身のWidget
  final Widget child;

  final String title;

  @override
  State<DayNightTemplate> createState() => _DayNightTemplateState();
}

class _DayNightTemplateState extends State<DayNightTemplate>
    implements BaseView {
  late final _presenter = DayNightTemplatePresenter(this);

  @override
  Widget build(BuildContext context) {
    print('build DayNightTemplate');

    return MaterialApp(
      theme: ThemeData(),
      darkTheme: ThemeData(brightness: Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: _presenter.themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(_presenter.themeMode == ThemeMode.dark
                  ? Icons.nightlight
                  : Icons.sunny),
              onPressed: _presenter.changeTheme,
            ),
          ],
        ),
        body: widget.child,
      ),
    );
  }
}
