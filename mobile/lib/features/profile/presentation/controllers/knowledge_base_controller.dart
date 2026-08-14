import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class KnowledgeBaseArticle {
  final int id;
  final String title;
  final String content;

  KnowledgeBaseArticle({
    required this.id,
    required this.title,
    required this.content,
  });

  factory KnowledgeBaseArticle.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseArticle(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class KnowledgeBaseController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxBool isLoadingTerms = false.obs;
  final RxBool isLoadingFaqs = false.obs;
  
  final RxString termsContent = ''.obs;
  final RxList<KnowledgeBaseArticle> faqs = <KnowledgeBaseArticle>[].obs;

  Future<void> fetchTerms() async {
    try {
      isLoadingTerms.value = true;
      final response = await _apiClient.dio.get('/public/knowledge-base/terms');
      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        termsContent.value = response.data[0]['content'] ?? 'محتوى الشروط والأحكام غير متوفر.';
      } else {
        termsContent.value = 'لم يتم العثور على شروط وأحكام.';
      }
    } catch (e) {
      debugPrint('Error fetching terms: $e');
      termsContent.value = 'حدث خطأ أثناء تحميل الشروط والأحكام.';
    } finally {
      isLoadingTerms.value = false;
    }
  }

  Future<void> fetchFaqs() async {
    try {
      isLoadingFaqs.value = true;
      final response = await _apiClient.dio.get('/public/knowledge-base/faq');
      if (response.statusCode == 200) {
        final List data = response.data;
        faqs.value = data.map((json) => KnowledgeBaseArticle.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
    } finally {
      isLoadingFaqs.value = false;
    }
  }
}
