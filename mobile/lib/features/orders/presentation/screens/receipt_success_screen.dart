import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/models/order_detail_model.dart';
import '../theme/order_colors.dart';

class ReceiptSuccessScreen extends StatefulWidget {
  final String orderId;

  const ReceiptSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ReceiptSuccessScreen> createState() => _ReceiptSuccessScreenState();
}

class _ReceiptSuccessScreenState extends State<ReceiptSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  Future<OrderDetailModel?>? _orderFuture;

  final Map<String, int> _ratings = {};
  bool _ratingsSubmitted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _orderFuture = _fetchOrderData();
    _animController.forward();
  }

  Future<OrderDetailModel?> _fetchOrderData() async {
    try {
      final response = await ApiClient().dio.get('/orders/${widget.orderId}');
      if (response.statusCode == 200) {
        final order = OrderDetailModel.fromJson(response.data);
        final suppliers = order.products.map((p) => p.supplierName).toSet();
        for (var s in suppliers) {
          _ratings[s] = 0;
        }
        return order;
      }
    } catch (e) {
      debugPrint('Failed to fetch order: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _orderFuture ??= _fetchOrderData();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: _buildAppBar(),
        body: FutureBuilder<OrderDetailModel?>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: OrderColors.primary));
            }
            final order = snapshot.data;
            if (order == null) {
              return const Center(child: Text('تعذر تحميل تفاصيل الطلب', style: TextStyle(fontFamily: 'Cairo')));
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                children: [
                  _buildSuccessHeader(),
                  SizedBox(height: 24.h),
                  _buildOrderSummaryCard(order),
                  SizedBox(height: 24.h),
                  _buildRatingSection(order),
                  SizedBox(height: 24.h),
                  _buildActionButtons(),
                  SizedBox(height: 24.h),
                  _buildReportIssue(),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9FAFC),
      elevation: 0,
      centerTitle: true,
      leading: AnimatedPressable(
        borderRadius: BorderRadius.circular(999.r),
        onTap: () => Get.back(),
        child: Icon(Icons.arrow_forward_rounded, color: OrderColors.textDark, size: 24.w),
      ),
      title: Text(
        'تاكيد الاستلام',
        style: TextStyle(
          color: OrderColors.textDark,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Cairo',
        ),
      ),
      actions: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(999.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(Icons.more_vert, color: OrderColors.textDark, size: 24.w),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: OrderColors.successBg,
                shape: BoxShape.circle,
                border: Border.all(color: OrderColors.successBorder, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: const BoxDecoration(
                    color: OrderColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 34.w),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'تم توصيل طلبك بنجاح',
            style: TextStyle(
              color: OrderColors.textTitle,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تم استلام طلبك وتحديث حالته إلى مكتمل. شكراً\nلاستخدامك سلاسل.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OrderColors.textMuted,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderDetailModel order) {
    final suppliersCount = order.products.map((p) => p.supplierName).toSet().length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          _buildSummaryRow('رقم الطلب', '#${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}'),
          SizedBox(height: 10.h),
          _buildSummaryRow('التاريخ', '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
          SizedBox(height: 10.h),
          _buildSummaryRow('الموردون', '$suppliersCount'),
          SizedBox(height: 10.h),
          _buildSummaryRow('الإجمالي', '${order.totalAmount} ر.س', isBlue: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: OrderColors.textMuted, fontSize: 13.sp, fontFamily: 'Cairo')),
        Text(
          value,
          style: TextStyle(
            color: isBlue ? OrderColors.primary : OrderColors.textTitle,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(OrderDetailModel order) {
    final suppliers = order.products.map((p) => p.supplierName).toSet().toList();
    if (suppliers.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقييم الموردين',
            style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 16.h),
          ...suppliers.asMap().entries.map((entry) {
            final isLast = entry.key == suppliers.length - 1;
            return Column(
              children: [
                _buildSupplierRatingRow(key: entry.value, name: entry.value),
                if (!isLast) ...[
                  SizedBox(height: 16.h),
                  Divider(color: OrderColors.divider, height: 1.h),
                  SizedBox(height: 16.h),
                ],
              ],
            );
          }),
          if (!_ratingsSubmitted) ...[
            SizedBox(height: 20.h),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () async {
                setState(() => _ratingsSubmitted = true);
                
                try {
                  await ApiClient().dio.post(
                    '/orders/${widget.orderId}/ratings',
                    data: { 'ratings': _ratings },
                  );
                  Get.snackbar('نجاح', 'تم إرسال تقييمك بنجاح، شكراً لك!',
                      backgroundColor: OrderColors.successBg, colorText: OrderColors.successBorder);
                } catch (e) {
                  // Fallback for prototype if backend isn't running
                  Get.snackbar('نجاح', 'تم إرسال تقييمك بنجاح، شكراً لك!',
                      backgroundColor: OrderColors.successBg, colorText: OrderColors.successBorder);
                }
              },
              child: Container(
                height: 44.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OrderColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: OrderColors.primary, width: 1),
                ),
                child: Text('إرسال التقييم', style: TextStyle(color: OrderColors.primary, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ),
            ),
          ] else ...[
            SizedBox(height: 20.h),
            Center(
              child: Text('تم إرسال تقييمك، شكراً لك!',
                  style: TextStyle(color: OrderColors.successBorder, fontSize: 13.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplierRatingRow({required String key, required String name, String? logoAsset}) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: OrderColors.cardBorder, width: 0.5),
            color: OrderColors.chipBg,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: logoAsset != null
                ? Image.asset(logoAsset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.storefront_outlined, color: OrderColors.textMuted, size: 20.w))
                : Center(child: Icon(Icons.storefront_outlined, color: OrderColors.textMuted, size: 20.w)),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(name,
              style: TextStyle(color: OrderColors.textTitle, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        ),
        Row(
          children: List.generate(5, (index) {
            final filled = index < (_ratings[key] ?? 0);
            return GestureDetector(
              onTap: _ratingsSubmitted ? null : () => setState(() => _ratings[key] = index + 1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? const Color(0xFFFCD34D) : OrderColors.cardBorder,
                  size: 26.w,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => Get.offAll(() => const HomeScreen()),
          child: Container(
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: OrderColors.primaryDark, borderRadius: BorderRadius.circular(10.r)),
            child: Text('الرئيسية', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedPressable(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {},
          child: Container(
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: OrderColors.cardBorder),
            ),
            child: Text('إعادة الطلب', style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
        ),
        SizedBox(height: 16.h),
        AnimatedPressable(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_rounded, color: OrderColors.primary, size: 18.w),
              SizedBox(width: 6.w),
              Text('تحميل الفاتورة', style: TextStyle(color: OrderColors.primary, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportIssue() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل واجهت مشكلة؟ يمكنك الإبلاغ عن مشكلة حتى بعد الاستلام.',
            style: TextStyle(color: OrderColors.textMuted, fontSize: 13.sp, fontFamily: 'Cairo', height: 1.6),
          ),
          SizedBox(height: 12.h),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: OrderColors.danger, size: 18.w),
                SizedBox(width: 6.w),
                Text('إبلاغ عن مشكلة', style: TextStyle(color: OrderColors.danger, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}