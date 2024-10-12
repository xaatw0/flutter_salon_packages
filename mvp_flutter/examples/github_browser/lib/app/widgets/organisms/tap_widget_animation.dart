import 'package:flutter/material.dart';

/// 対象のWidgetを押すと、少し小さくなって、それから元の大きさになるアニメーションを実施する。
/// アニメーション後、[onTap]が実施される。
class TapWidgetAnimation extends StatefulWidget {
  const TapWidgetAnimation({
    super.key,
    required this.child,
    this.onTap,
  });

  /// アニメーションするWidget
  final Widget child;

  /// アニメーション後に実施されるイベント
  final void Function()? onTap;

  @override
  State<StatefulWidget> createState() => _TapWidgetAnimationState();
}

class _TapWidgetAnimationState extends State<TapWidgetAnimation>
    with TickerProviderStateMixin<TapWidgetAnimation> {
  /// 小さくなるアニメーションの値の初期値(元の大きさ)
  static const animationBeginValue = 1.0;

  /// 小さくなるアニメーションの値の終了値(95%の大きさになる)
  static const animationEndValue = 0.95;

  /// 100ミリ秒でアニメーションが実施される。
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 100,
    ),
    value: 1,
  );

  // 最初が1で最後に0.95になるようにする。つまり、100%の大きさを95%の大きさに変化させる。
  late final Animation<double> _easeInAnimation =
      Tween(begin: animationBeginValue, end: animationEndValue).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // 1→0.95に変化させて、サイズを変える
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse().then((_) {
          // 元の大きさに戻ったら、onTapのイベントがあれば実行する
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      },
      // childの大きさを1→0.95→1にアニメーションさせる
      child: ScaleTransition(
        scale: _easeInAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
