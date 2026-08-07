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

  final messages = <ChatEntry>[].obs;
  final quickReplies = <String>[].obs;
  final awaitingClarification = true.obs;
  final summary = <OrderSummaryLine>[].obs;
  
  final AiRepository _aiRepository = AiRepository();
  AiOrderResponse? currentResponse;
  bool isProcessing = false;

  void setInitialData(AiOrderResponse response) {
    currentResponse = response;
    _buildUiFromResponse(response, initial: true);
  }

  void _buildUiFromResponse(AiOrderResponse response, {bool initial = false}) {
    // 1. Build summary
    summary.clear();
    for (final split in response.splits) {
      for (final item in split.items) {
        summary.add(OrderSummaryLine(
          label: '${item.name}:', 
          value: item.quantity.toString()
        ));
      }
    }
    for (final missing in response.unresolved) {
      summary.add(OrderSummaryLine(
        label: '$missing:', 
        value: '؟؟؟', 
        missing: true
      ));
    }

    // 2. Build analysis items for the message
    List<OrderLineItem> lineItems = [];
    for (final split in response.splits) {
      for (final item in split.items) {
        lineItems.add(OrderLineItem(
          quantity: '${item.quantity} ${item.unit}', 
          name: item.name
        ));
      }
    }
    for (final missing in response.unresolved) {
      lineItems.add(OrderLineItem(
        quantity: 'مطلوب توضيح', 
        name: missing, 
        isMissing: true
      ));
    }

    if (initial) {
      messages.add(const VoiceMessageEntry(
        duration: '...',
        transcript: 'مقطع صوتي',
      ));
    }

    if (lineItems.isNotEmpty) {
      messages.add(AiAnalysisEntry(
        title: 'لقد حددت معظم طلبك.',
        items: lineItems,
      ));
    }

    if (response.unresolved.isNotEmpty) {
      messages.add(ClarificationEntry(
        'لم أتمكن من تحديد تفاصيل بعض العناصر (${response.unresolved.join(", ")}). هل يمكنك توضيح الكميات المطلوبة؟',
      ));
      awaitingClarification.value = true;
    } else {
      awaitingClarification.value = false;
      messages.add(const ConfirmationEntry('تم تأكيد جميع الطلبات بنجاح.'));
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.off(
          () => OrderReviewScreen(initialResponse: currentResponse),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 350),
        );
      });
    }
  }

  void skipSugarQuantity() {
    // Currently dummy skip, real implementation depends on AI handling "skip"
    sendMessage(textOverride: "تخطي");
  }
  
  void selectSugarQuantity(String option) {
    sendMessage(textOverride: option);
  }

  Future<void> sendMessage({String? textOverride}) async {
    final text = textOverride ?? textController.text.trim();
    if (text.isEmpty || isProcessing) return;
    textController.clear();
    
    if (currentResponse?.sessionId == null) return;

    isProcessing = true;
    messages.add(ConfirmationEntry(text)); // show user message
    
    try {
      final newResponse = await _aiRepository.sendChatMessage(
        currentResponse!.sessionId!,
        text,
        1, // fallback merchant ID, assuming AI service handles the session
      );
      currentResponse = newResponse;
      _buildUiFromResponse(newResponse);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إرسال الرسالة.');
    } finally {
      isProcessing = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
