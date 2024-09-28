import 'package:flutter/material.dart';

/// 画像を動かしながら、フェードインするアニメーション
class MovingFadeinAnimation extends StatefulWidget {
  const MovingFadeinAnimation({
    required this.child,
    super.key,
  });

  /// アニメーションするWidget
  final Widget child;
  @override
  State<MovingFadeinAnimation> createState() => _MovingFadeinAnimationState();
}

class _MovingFadeinAnimationState extends State<MovingFadeinAnimation>
    with TickerProviderStateMixin<MovingFadeinAnimation> {
  /// フェードインアニメーションの値の初期値
  static const fadeBeginValue = 0.0;

  /// フェードインアニメーションの値の終了値
  static const fadeEndValue = 1.0;

  /// 300ミリ秒でアニメーションが実施される。
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 300,
    ),
    value: fadeBeginValue,
  );

  // フェードインのアニメーション
  late final Animation<double> _fadeInAnimation =
      Tween(begin: fadeBeginValue, end: fadeEndValue).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ),
  );

  // 移動するアニメーション
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ),
  );

  @override
  void initState() {
    super.initState();

    // 起動してから少し置いてからアニメーションが始まる
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}
