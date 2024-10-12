import 'package:flutter/material.dart';
import 'package:github_browser/app/pages/search_page/search_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app/widgets/templates/day_night_template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DayNightTemplate(child: const SearchPage());
  }
}
