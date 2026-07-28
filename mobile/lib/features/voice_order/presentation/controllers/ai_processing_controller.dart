import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum ProcessingStepState { completed, active, pending }

class ProcessingStep {
  final String title;
  final String subtitle;
  ProcessingStep({required this.title, required this.subtitle});
}

class AiProcessingController extends GetxController {
  final List<ProcessingStep> steps = [
    ProcessingStep(title: 'تم استلام الصوت', subtitle: 'تم تسجيل الطلب بنجاح'),
    ProcessingStep(title: 'فهم الطلب...', subtitle: 'تحليل المكونات والكميات'),
    ProcessingStep(title: 'مطابقة المنتجات', subtitle: 'البحث في الكتالوج المتاح'),
    ProcessingStep(title: 'البحث عن أفضل مورد', subtitle: 'تحسين التكلفة والوقت'),
  ];

  final RxInt activeStep = 1.obs;
  Timer? _timer;
  VoidCallback? onFinished;

  void start(VoidCallback onFinishedCallback) {
    onFinished = onFinishedCallback;
    _timer = Timer.periodic(Duration(milliseconds: 900), (timer) {
      if (activeStep.value < steps.length - 1) {
        activeStep.value++;
      } else {
        timer.cancel();
        Future.delayed(Duration(milliseconds: 500), () {
          onFinished?.call();
        });
      }
    });
  }

  ProcessingStepState stateOf(int index) {
    if (index < activeStep.value) return ProcessingStepState.completed;
    if (index == activeStep.value) return ProcessingStepState.active;
    return ProcessingStepState.pending;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
