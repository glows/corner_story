import 'package:flutter/material.dart';

/// Keeps the shared header out of the way while reading vertical feeds.
class ScrollAwareHeader extends StatefulWidget {
  const ScrollAwareHeader({
    super.key,
    required this.section,
    required this.collapseEnabled,
    required this.header,
    required this.child,
    this.headerVisible = true,
  });

  final int section;
  final bool collapseEnabled;
  final Widget header;
  final Widget child;
  final bool headerVisible;

  @override
  State<ScrollAwareHeader> createState() => _ScrollAwareHeaderState();
}

class _ScrollAwareHeaderState extends State<ScrollAwareHeader> {
  bool _hidden = false;
  double _movement = 0;

  @override
  void didUpdateWidget(covariant ScrollAwareHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section || !widget.collapseEnabled) {
      _hidden = false;
      _movement = 0;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (!widget.collapseEnabled ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }
    bool hidden = _hidden;
    if (notification.metrics.extentBefore <= 0) {
      hidden = false;
      _movement = 0;
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta != 0) {
        if (_movement.sign != delta.sign) _movement = 0;
        _movement += delta;
        if (_movement.abs() >= 12) hidden = delta > 0;
      }
    } else if (notification is ScrollEndNotification) {
      _movement = 0;
    }
    if (hidden != _hidden) setState(() => _hidden = hidden);
    return false;
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      ),
      if (widget.headerVisible)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: _hidden,
            child: ExcludeSemantics(
              excluding: _hidden,
              child: AnimatedSlide(
                offset: _hidden ? const Offset(0, -1) : Offset.zero,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: widget.header,
              ),
            ),
          ),
        ),
    ],
  );
}
