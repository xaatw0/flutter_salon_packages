import 'dart:async';

import 'package:flutter/material.dart';

class ModelessDrawer<T> extends StatefulWidget {
  const ModelessDrawer({
    super.key,
    this.icon = const Icon(Icons.double_arrow_outlined),
    this.widthWhenClose = 0,
    this.widthCloseIconWhenOpen = 32,
    this.width = 200,
    this.duration = const Duration(milliseconds: 100),
    this.onToggleChange,
    this.initiallyClosed = true,
    this.backgroundColor,
    required this.builder,
  });

  final Widget icon;
  final double widthWhenClose;
  final double widthCloseIconWhenOpen;
  final double width;
  final Duration duration;
  final bool initiallyClosed;
  final Color? backgroundColor;

  final void Function(bool isClosed)? onToggleChange;

  final Widget Function(BuildContext context, T? value) builder;

  @override
  State<ModelessDrawer<T>> createState() => ModelessDrawerState();
}

class ModelessDrawerState<T> extends State<ModelessDrawer<T>> {
  late bool _isClosed = widget.initiallyClosed;

  T? value;

  Completer<void>? _drawerAnimationFinished;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      right: _isClosed ? -widget.width : 0,
      width: widget.width + widget.widthWhenClose,
      height: MediaQuery.sizeOf(context).height,
      duration: widget.duration,
      onEnd: () {
        if (_drawerAnimationFinished != null &&
            !_drawerAnimationFinished!.isCompleted) {
          _drawerAnimationFinished!.complete();
        }
      },
      child: Drawer(
        width: widget.width,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
          ),
        ),
        backgroundColor: widget.backgroundColor,
        child: Row(
          children: [
            SizedBox(
              width: _isClosed
                  ? widget.widthWhenClose
                  : widget.widthCloseIconWhenOpen,
              child: AnimatedRotation(
                turns: _isClosed && 0 < widget.widthWhenClose ? 0.5 : 1,
                duration: widget.duration,
                child: IconButton(
                  onPressed: () {
                    setState(() => _isClosed = !_isClosed);
                  },
                  icon: widget.icon,
                ),
              ),
            ),
            Expanded(
              child: widget.builder(context, value),
            ),
          ],
        ),
      ),
    );
  }

  void changeValue(T? value) {
    setState(() {
      this.value = value;
    });
  }

  Future<void> open() {
    return _onToggleChanged(false);
  }

  Future<void> close() {
    return _onToggleChanged(true);
  }

  Future<void> _onToggleChanged(bool willClosed) async {
    if (_isClosed == willClosed) {
      return;
    }
    setState(() {
      _isClosed = willClosed;
    });

    if (widget.onToggleChange != null) {
      widget.onToggleChange!(willClosed);
    }

    _drawerAnimationFinished = Completer();
    return _drawerAnimationFinished?.future;
  }
}
