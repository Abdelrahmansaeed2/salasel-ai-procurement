import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../stores/presentation/screens/welcomepage_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const int _countdownSeconds = 59;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late int _secondsLeft;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _countdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsLeft = _countdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _onResend() {
    if (!_canResend) return;
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[_otpLength - 1].requestFocus();
    _startTimer();
  }

  /// Called when a digit is typed in box [index].
  void _onDigitChanged(String value, int index) {
    if (value.length == 1) {
      
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  String get _otpValue =>
      _controllers.reversed.map((c) => c.text).join();

  bool get _isComplete =>
      _controllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                const _ShieldIllustration(),

                const SizedBox(height: 36),

                
                Text(
                  'أدخل رمز التحقق',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'تم إرسال رمز مكون من 6 أرقام إلى هاتفك',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                _OtpBoxesRow(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  onDigitChanged: _onDigitChanged,
                  onKeyEvent: _onKeyEvent,
                ),

                const SizedBox(height: 24),

                
                _TimerResendRow(
                  secondsLeft: _secondsLeft,
                  canResend: _canResend,
                  onResend: _onResend,
                  onChangeNumber: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: 32),

               
                _VerifyButton(
                  enabled: _isComplete,
                  onPressed: _isComplete
                      ? () {
                          debugPrint('OTP: $_otpValue');
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder<void>(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const StoresScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 350),
                            ),
                            (route) => false,
                          );
                        }
                      : null,
                ),

                const SizedBox(height: 24),

                const _E2EFooter(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _ShieldIllustration extends StatelessWidget {
  const _ShieldIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/otp_shield.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


class _OtpBoxesRow extends StatelessWidget {
  const _OtpBoxesRow({
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
    required this.onKeyEvent,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(String value, int index) onDigitChanged;
  final void Function(KeyEvent event, int index) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controllers.length, (i) {
        
        final index = controllers.length - 1 - i;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _OtpBox(
            controller: controllers[index],
            focusNode: focusNodes[index],
            onChanged: (v) => onDigitChanged(v, index),
            onKeyEvent: (e) => onKeyEvent(e, index),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.controller.text.isNotEmpty;

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: widget.onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : filled
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
            width: _isFocused ? 2.0 : 1.0,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}


class _TimerResendRow extends StatelessWidget {
  const _TimerResendRow({
    required this.secondsLeft,
    required this.canResend,
    required this.onResend,
    required this.onChangeNumber,
  });

  final int secondsLeft;
  final bool canResend;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;

  String get _timerText =>
      '0:${secondsLeft.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timer row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              _timerText,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Resend | Change Number
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Resend link
            GestureDetector(
              onTap: canResend ? onResend : null,
              child: Text(
                'إعادة إرسال الرمز',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: canResend
                      ? AppColors.primary
                      : const Color(0xFFCBD5E1),
                  decoration: canResend ? TextDecoration.underline : null,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            // Vertical divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 1,
                height: 14,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            // Change number link
            GestureDetector(
              onTap: onChangeNumber,
              child: Text(
                'تغيير الرقم',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.enabled, this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.disabled,
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              'تحقق',
              style: enabled
                  ? AppTextStyles.primaryButton
                  : AppTextStyles.primaryButtonDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

class _E2EFooter extends StatelessWidget {
  const _E2EFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 14,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(width: 6),
        Text(
          'تشفير نهاية إلى نهاية (End-to-End)',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
