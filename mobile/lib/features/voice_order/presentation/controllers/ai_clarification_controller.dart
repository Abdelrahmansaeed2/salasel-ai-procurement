import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/presentation/screens/order_review_screen.dart';

/// A single confirmed/missing line inside the AI analysis card.
class OrderLineItem {
  final String quantity;
  final String name;
  final bool isMissing;

  const OrderLineItem({
    required this.quantity,
    required this.name,
    this.isMissing = false,
  });
}

sealed class ChatEntry {
  const ChatEntry();
}

/// The customer's original voice note bubble.
class VoiceMessageEntry extends ChatEntry {
  final String duration;
  final String transcript;

  const VoiceMessageEntry({required this.duration, required this.transcript});
}

/// The AI's structured breakdown of what it understood from the order.
class AiAnalysisEntry extends ChatEntry {
  final String title;
  final List<OrderLineItem> items;

  const AiAnalysisEntry({required this.title, required this.items});
}

/// The AI's follow-up clarification question, styled like an outgoing bubble.
class ClarificationEntry extends ChatEntry {
  final String question;

  const ClarificationEntry(this.question);
}

/// A short confirmation bubble shown once the clarification is resolved.
class ConfirmationEntry extends ChatEntry {
  final String message;

  const ConfirmationEntry(this.message);
}

class OrderSummaryLine {
  final String label;
  final String value;
  final bool missing;

  const OrderSummaryLine({
    required this.label,
    required this.value,
    this.missing = false,
  });
}

class AiClarificationController extends GetxController {
  final textController = TextEditingController();

  final messages = <ChatEntry>[
    const VoiceMessageEntry(
      duration: '0:04',
      transcript: '"محتاج لبن، وسكر، وشاي"',
    ),
    const AiAnalysisEntry(
      title: 'لقد حددت معظم طلبك.',
      items: [
        OrderLineItem(quantity: '20 كرتون', name: 'حليب المراعي'),
        OrderLineItem(quantity: '5 علب', name: 'شاي ليبتون'),
        OrderLineItem(quantity: 'الكمية مطلوبة', name: 'سكر الأسرة', isMissing: true),
      ],
    ),
    const ClarificationEntry(
      'لقد طلبت السكر، لكن لم أتمكن من تحديد الكمية. كم كيس سكر تود أن تطلب؟',
    ),
  ].obs;

  final quickReplies = <String>['5 أكياس', '20 كيس', '10 أكياس'].obs;
  final awaitingClarification = true.obs;

  final summary = <OrderSummaryLine>[
    const OrderSummaryLine(label: 'سكر:', value: '؟؟؟', missing: true),
    const OrderSummaryLine(label: 'شاي:', value: '5'),
    const OrderSummaryLine(label: 'حليب:', value: '20'),
  ].obs;

  void selectSugarQuantity(String option) {
    if (!awaitingClarification.value) return;
    _resolveSugar(
      summaryValue: option,
      confirmationMessage: 'تم تحديد كمية السكر: $option.',
    );
  }

  void skipSugarQuantity() {
    if (!awaitingClarification.value) return;
    _resolveSugar(
      summaryValue: 'لم تُحدد',
      confirmationMessage: 'تم تخطي تحديد كمية السكر، سنتواصل معك لاحقاً لتأكيدها.',
      stillMissing: true,
    );
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();

    if (awaitingClarification.value) {
      selectSugarQuantity(text);
    }
  }

  void _resolveSugar({
    required String summaryValue,
    required String confirmationMessage,
    bool stillMissing = false,
  }) {
    awaitingClarification.value = false;
    quickReplies.clear();

    summary[0] = OrderSummaryLine(
      label: 'سكر:',
      value: summaryValue,
      missing: stillMissing,
    );

    messages.add(ConfirmationEntry(confirmationMessage));

    Future.delayed(const Duration(milliseconds: 900), () {
      Get.off(
        () => const OrderReviewScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
    });
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
