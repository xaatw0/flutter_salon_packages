import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// シマーを扱いやすくするためのWidget
class ShimmerWidget extends StatelessWidget {
  /// 長方形
  const ShimmerWidget.rectangular({
    this.width = double.infinity,
    required this.height,
    super.key,
  }) : shapeBorder = const RoundedRectangleBorder();

  /// 円形
  const ShimmerWidget.circular({
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
    super.key,
  });

  /// 幅
  final double width;

  /// 高さ
  final double height;

  /// 形
  final ShapeBorder shapeBorder;

  /// ベースカラー
  static final _kbaseColor = Colors.grey[400]!;

  /// ハイライトカラー
  static final _kHighlightColor = Colors.grey[300]!;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: _kbaseColor,
        highlightColor: _kHighlightColor,
        child: Container(
          height: height,
          width: width,
          decoration: ShapeDecoration(color: _kbaseColor, shape: shapeBorder),
        ),
      );
}
