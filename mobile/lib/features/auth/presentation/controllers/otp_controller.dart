import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../stores/presentation/screens/welcomepage_screen.dart';

class OtpController extends GetxController {
  final String phoneNumber;
  
  static const int otpLength = 6;
  static const int countdownSeconds = 59;

  final List<TextEditingController> controllers = List.generate(otpLength, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(otpLength, (_) => FocusNode());
  
  
  final List<RxBool> focusStates = List.generate(otpLength, (_) => false.obs);

  RxInt secondsLeft = countdownSeconds.obs;
  RxBool canResend = false.obs;
  RxBool isComplete = false.obs;

  Timer? _timer;

  OtpController({required this.phoneNumber});

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    
    
    for (int i = 0; i < otpLength; i++) {
      focusNodes[i].addListener(() {
        focusStates[i].value = focusNodes[i].hasFocus;
      });
      controllers[i].addListener(_checkCompletion);
    }
  }

  void _startTimer() {
    canResend.value = false;
    secondsLeft.value = countdownSeconds;
    _timer?.cancel();
    
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (secondsLeft.value > 0) {
        secondsLeft.value--;
      } else {
        canResend.value = true;
        t.cancel();
      }
    });
  }

  void _checkCompletion() {
    isComplete.value = controllers.every((c) => c.text.isNotEmpty);
  }

  void onResend() {
    if (!canResend.value) return;
    for (final c in controllers) {
      c.clear();
    }
    focusNodes[otpLength - 1].requestFocus();
    _startTimer();
  }

  void onDigitChanged(String value, int index) {
    if (value.length == 1) {
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    }
  }

  void onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        controllers[index].text.isEmpty &&
        index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  String get otpValue => controllers.reversed.map((c) => c.text).join();

  void submitOtp() {
    if (isComplete.value) {
      debugPrint('OTP: $otpValue');
      Get.offAll(
        () => StoresScreen(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 350),
      );
    }
  }

  void changeNumber() {
    Get.back();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
