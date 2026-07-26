import 'package:flutter/material.dart';

/// Animates a numeric value from 0 (or [begin]) up to [end], formatting the
/// interpolated value on every frame via [format].
class AnimatedCountText extends StatelessWidget {
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;
  final String Function(double value) format;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCountText({
    super.key,
    this.begin = 0,
    required this.end,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    required this.format,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, _) {
        return Text(format(value), style: style, textAlign: textAlign);
      },
    );
  }
}
