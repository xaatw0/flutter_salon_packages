import 'package:flutter/material.dart';

extension Responsive on BuildContext {
  ///デスクトップPC
  static const breakXLarge = 1280.0;

  /// ラップトップPC,タブレット
  static const breakLarge = 1024.0;

  /// 通常のスマートフォンの縦向き
  static const breakMiddle = 768.0;

  //
  static const breakSmall = 640.0;

  T responsive<T>(
    T defaultVal, {
    T? small,
    T? middle,
    T? large,
    T? xLarge,
  }) {
    final displayWidth = MediaQuery.of(this).size.width;

    final result = displayWidth >= breakXLarge
        ? (xLarge ?? large ?? middle ?? small ?? defaultVal)
        : displayWidth >= breakLarge
            ? (large ?? middle ?? small ?? defaultVal)
            : displayWidth >= breakMiddle
                ? (middle ?? small ?? defaultVal)
                : displayWidth >= breakSmall
                    ? (small ?? defaultVal)
                    : defaultVal;

    return result;
  }
}
