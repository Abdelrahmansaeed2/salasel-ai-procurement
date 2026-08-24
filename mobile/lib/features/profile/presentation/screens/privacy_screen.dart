import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ApiClient _apiClient = ApiClient();
  
  bool _isLoading = true;
  String _privacyPolicy = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    try {
      final response = await _apiClient.dio.get('/public/knowledge-base/privacy');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          // Assume the first article in the 'privacy' category is the policy
          setState(() {
            _privacyPolicy = data[0]['content'] ?? 'لا يوجد محتوى لسياسة الخصوصية حالياً.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _privacyPolicy = 'لم يتم العثور على سياسة الخصوصية.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'حدث خطأ أثناء جلب سياسة الخصوصية.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'تعذر الاتصال بالخادم لجلب سياسة الخصوصية.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'سياسة الخصوصية',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF004AC6),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              _error,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = '';
                });
                _fetchPrivacyPolicy();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          _privacyPolicy,
          style: TextStyle(
            color: const Color(0xFF191C1E),
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
