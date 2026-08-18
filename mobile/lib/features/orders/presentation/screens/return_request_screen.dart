import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';

class ReturnRequestScreen extends StatefulWidget {
  final String orderId;
  final String masterOrderId;
  final double totalAmount;

  const ReturnRequestScreen({
    Key? key,
    required this.orderId,
    required this.masterOrderId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? selectedReason;
  final reasons = [
    'منتج تالف أو به عيب',
    'منتج غير مطابق للمواصفات',
    'الكمية غير صحيحة',
    'تأخير في التوصيل',
    'أسباب أخرى'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'طلب إرجاع',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم الطلب الأصلي',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        widget.orderId,
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'قيمة الطلب',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${widget.totalAmount} ر.س',
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'سبب الإرجاع',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedReason,
                  isExpanded: true,
                  hint: Text(
                    'اختر سبب الإرجاع...',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: reasons.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(
                      r,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedReason = val),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'صور المنتجات المرتجعة',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                // Mock upload
                Get.snackbar('تحميل', 'تم إضافة الصورة بنجاح');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 40.w, color: const Color(0xFF94A3B8)),
                    SizedBox(height: 8.h),
                    Text(
                      'اضغط لإضافة صور',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedReason == null || _isLoading) ? null : () async {
                  setState(() => _isLoading = true);
                  try {
                    final response = await _apiClient.dio.post(
                      '${ApiClient.baseUrl}/returns',
                      data: {
                        'masterOrderId': int.parse(widget.masterOrderId.replaceAll(RegExp(r'[^0-9]'), '')),
                        'reason': selectedReason,
                        'photos': [], // Placeholder for future photo upload support
                        'items': [], // Placeholder for specific items
                        'requestedAmount': widget.totalAmount,
                      },
                    );
                    
                    if (response.statusCode == 200 || response.statusCode == 201) {
                      Get.back();
                      Get.snackbar('نجاح', 'تم إرسال طلب الاسترجاع بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
                    } else {
                      Get.snackbar('خطأ', 'فشل إرسال طلب الاسترجاع', backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  } catch (e) {
                    Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم', backgroundColor: Colors.red, colorText: Colors.white);
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(
                  'إرسال الطلب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
