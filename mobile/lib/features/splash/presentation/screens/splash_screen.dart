import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onTimeout,
    this.displayDuration = const Duration(seconds: 3),
  });

  final VoidCallback? onTimeout;
  final Duration displayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  late final AnimationController _entranceController;
  late final AnimationController _breatheController;
  late final AnimationController _rippleController;
  late final AnimationController _swayController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _shimmerController;
  late final AnimationController _dotsController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoFloat;

  late final Animation<double> _networkFade;
  late final Animation<double> _networkScale;

  late final Animation<double> _micFade;
  late final Animation<double> _micScale;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  late final Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoRotation = Tween(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _logoFloat = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _networkFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
    _networkScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _micFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );
    _micScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.9, curve: Curves.elasticOut),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _dotsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
    );

    _entranceController.forward();

    _navigationTimer = Timer(widget.displayDuration, () {
      if (mounted) widget.onTimeout?.call();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _breatheController.dispose();
    _rippleController.dispose();
    _swayController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  final opacity = 0.10 + _glowController.value * 0.12;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.3),
                        radius: 0.9,
                        colors: [
                          Color(0xFF2563EB).withValues(alpha: opacity),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _logoFloat.value),
                          child: child,
                        );
                      },
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: RotationTransition(
                            turns: _logoRotation,
                            child: Image.asset(
                              'assets/images/salasel_logo.png',
                              width: 251.2,
                              height: 168.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 65),
                    FadeTransition(
                      opacity: _networkFade,
                      child: ScaleTransition(
                        scale: _networkScale,
                        child: AnimatedBuilder(
                          animation: _swayController,
                          builder: (context, child) {
                            final angle =
                                (_swayController.value - 0.5) * 2 * 0.035;
                            final pulse =
                                1.0 + (_swayController.value - 0.5) * 0.04;
                            return Transform.rotate(
                              angle: angle,
                              child:
                                  Transform.scale(scale: pulse, child: child),
                            );
                          },
                          child: SizedBox(
                            width: 320,
                            child: SvgPicture.asset(
                              'assets/icons/ai_network_illustration.svg',
                              width: 320,
                              height: 176,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    FadeTransition(
                      opacity: _micFade,
                      child: ScaleTransition(
                        scale: _micScale,
                        child: _MicrophoneButton(
                          breatheController: _breatheController,
                          rippleController: _rippleController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: _ShimmeringTitleText(
                          shimmerController: _shimmerController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleFade,
                        child: const _SplashSubtitleText(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _dotsFade,
                      child: _LoadingDots(controller: _dotsController),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicrophoneButton extends StatelessWidget {
  const _MicrophoneButton({
    required this.breatheController,
    required this.rippleController,
  });

  final AnimationController breatheController;
  final AnimationController rippleController;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size * 2.2,
      height: _size * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _RippleRing(controller: rippleController, phaseShift: 0),
          _RippleRing(controller: rippleController, phaseShift: 0.5),
          AnimatedBuilder(
            animation: breatheController,
            builder: (context, child) {
              final scale = 1.0 + breatheController.value * 0.08;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: _size,
              height: _size,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/mic_icon.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RippleRing extends StatelessWidget {
  const _RippleRing({required this.controller, required this.phaseShift});

  final AnimationController controller;
  final double phaseShift;

  static const double _baseSize = 56;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phaseShift) % 1.0;
        final size = _baseSize + t * _baseSize * 1.4;
        final opacity = (1.0 - t) * 0.35;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF2563EB).withValues(alpha: opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

class _ShimmeringTitleText extends StatelessWidget {
  const _ShimmeringTitleText({required this.shimmerController});

  final AnimationController shimmerController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        final sweep = shimmerController.value * 3.0 - 1.0;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(sweep - 0.3, 0),
              end: Alignment(sweep + 0.3, 0),
              colors: const [
                Color(0xFF0F172A),
                Color(0xFF60A5FA),
                Color(0xFF0F172A),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: const _SplashTitleText(),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  static const int _dotCount = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_dotCount, (index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final t = (controller.value + index * (1 / _dotCount)) % 1.0;
                final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
                return Transform.translate(
                  offset: Offset(0, -6 * bounce),
                  child: Opacity(
                    opacity: 0.4 + bounce * 0.6,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SplashTitleText extends StatelessWidget {
  const _SplashTitleText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'اطلب بضاعتك بصوتك',
      textAlign: TextAlign.center,
      style: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 30.25 / 22,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class _SplashSubtitleText extends StatelessWidget {
  const _SplashSubtitleText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'منصة المشتريات الذكية للتجار والموردين',
      textAlign: TextAlign.center,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 19.5 / 13,
        color: const Color(0xFF64748B),
      ),
    );
  }
}
