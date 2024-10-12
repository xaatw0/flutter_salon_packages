import 'package:flutter/material.dart';

import '../../../domain/string_resources.dart';

/// レポジトリの詳細を表示する画面のDescription部分のWidget
class RepositoryDetailDescription extends StatelessWidget {
  const RepositoryDetailDescription({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            StringResources.kDescription,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
