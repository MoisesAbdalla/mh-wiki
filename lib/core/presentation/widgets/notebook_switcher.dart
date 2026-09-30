import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// The app's single content transition (005 FR-015, research R9): the new
/// child fades in over [Motion.switchDuration] and, when [slide] is set, rises
/// 2 % into place; no bounce. With the platform's reduce-motion setting on,
/// the child changes in one frame. Give each child a distinct key.
class NotebookSwitcher extends StatelessWidget {
  const NotebookSwitcher({required this.child, this.slide = true, super.key});

  final Widget child;

  /// Slide as well as fade (detail); lists only fade.
  final bool slide;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Motion.duration(context),
    switchInCurve: Motion.curve,
    switchOutCurve: Motion.curve,
    transitionBuilder: (child, animation) {
      final faded = FadeTransition(opacity: animation, child: child);
      if (!slide) return faded;
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation),
        child: faded,
      );
    },
    child: child,
  );
}
