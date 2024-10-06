/*
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/ui/app_theme.dart' as app_theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../gen/assets.gen.dart';

/// コインの状態
enum CoinStatus {
  /// 太陽
  sun,

  /// 月
  moon;
}

/// 太陽と月がそれぞれ表と裏に書かれているコインをイメージして作成しました。
class SunAndMoonCoin extends ConsumerStatefulWidget {
  const SunAndMoonCoin({
    super.key,
    this.callback,
    this.duration = const Duration(milliseconds: 100),
    this.size = 32,
    this.color = Colors.orangeAccent,
  });

  /// 太陽と月が入れ替わるときに実施されるコールバックを設定します
  /// 例：テーマの入れ替え
  final void Function(CoinStatus coinStatus)? callback;

  /// アニメーションの時間
  final Duration duration;

  /// サイズ
  final double size;

  ///アイコンの色
  final Color color;

  @override
  ConsumerState<SunAndMoonCoin> createState() => _SunAndMoonCoinState();
}

class _SunAndMoonCoinState extends ConsumerState<SunAndMoonCoin>
    with TickerProviderStateMixin<SunAndMoonCoin> {
  /// 太陽のアイコン
  late final sunIcon = SvgPicture.asset(
    Assets.images.dayIcon,
    color: widget.color,
    height: widget.size,
    width: widget.size,
  );

  /// 月のアイコン
  late final moonIcon = SvgPicture.asset(
    Assets.images.nightIcon,
    color: widget.color,
    height: widget.size,
    width: widget.size,
  );

  /// アニメーションの値の初期値
  static const startValue = 0.0;

  /// アニメーションの値の終了値
  static const endValue = 1.0;

  /// コインの表裏の入れ替わり値
  static const breakValue = (startValue + endValue) / 2;

  /// 現在の状態
  CoinStatus get _currentStatus =>
      ref.watch(app_theme.themeMode) == ThemeMode.light
          ? CoinStatus.sun
          : CoinStatus.moon;

  /// アニメーションのコントローラ
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: startValue,
  );

  // アニメーションで変化する値
  late final Animation<double> _animationValue =
      Tween(begin: startValue, end: endValue).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ),
  )..addListener(
          () {
            // 太陽→月に変えるタイミング
            if (_currentStatus == CoinStatus.sun &&
                breakValue < _animationValue.value) {
              _callback();
            }
            //  月→太陽 に変えるタイミング
            else if (_currentStatus == CoinStatus.moon &&
                _animationValue.value < breakValue) {
              _callback();
            }
          },
        );

  /// 太陽と月が入れ替わるときにコースバックを実施する
  void _callback() {
    if (widget.callback != null) {
      widget.callback!(
        _currentStatus == CoinStatus.sun ? CoinStatus.moon : CoinStatus.sun,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 次のページに行ってから、ダークモードを切り替えて、戻ったときに
    // 元のページは以前とアニメーションの値を保持している。
    // その場合、アニメーションを進めてアニメーションの値を合わせる。
    // fromを使うことで、アニメーションしているところを省略する
    if (_animationValue.value == 0 && _currentStatus == CoinStatus.moon) {
      _controller.forward(from: endValue);
    }

    return GestureDetector(
      onTap: () {
        if (_animationValue.value == startValue) {
          _controller.forward();
        } else if (_animationValue.value == endValue) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(math.pi * (1.0 - _animationValue.value)),
            child: _currentStatus == CoinStatus.sun ? sunIcon : moonIcon,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
*/