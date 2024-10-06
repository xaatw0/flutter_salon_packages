import 'package:flutter/material.dart';

import '../../../domain/value_objects/owner_icon_url.dart';
import '../atoms/owner_image.dart';

/// レポジトリの詳細を表示するためのページのOwnerの画像を表示するWidget。
/// 丸く加工する。
class OwnerClip extends StatelessWidget {
  const OwnerClip(
    this.url, {
    super.key,
  });

  final OwnerIconUrl url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 135,
        width: 135,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 8,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey, Colors.white70],
          ),
        ),
        child: ClipOval(
          child: OwnerImage(
            url: url.value!,
          ),
        ),
      ),
    );
  }
}
