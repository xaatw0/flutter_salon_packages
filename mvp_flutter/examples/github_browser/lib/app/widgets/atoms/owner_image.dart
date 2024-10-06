import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// レポジトリの持ち主の画像
/// (GoldenTest時は、Flutterのログになる)
class OwnerImage extends StatelessWidget {
  const OwnerImage({
    super.key,
    required this.url,
    this.size,
  });

  /// 画像をHeroで使用するときの、tagの接頭語
  static const kHeroKey = 'image_';

  /// レポジトリの持ち主の画像のURL
  final String url;

  /// 画像のサイズ
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST')
          ? Image.network(
              url,
              width: size,
              height: size,
            )
          : FlutterLogo(size: size),
    );
  }
}
