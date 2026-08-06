import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../theme/order_colors.dart';

class ReceiptSuccessScreen extends StatefulWidget {
  final String orderId;

  const ReceiptSuccessScreen({
    super.key,
    this.orderId = 'SL-94821',
  });

  @override
  State<ReceiptSuccessScreen> createState() => _ReceiptSuccessScreenState();
}

class _ReceiptSuccessScreenState extends State<ReceiptSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  final Map<String, int> _ratings = {
    'nile': 0,
    'delta': 0,
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            children: [
              _buildSuccessHeader(),
              SizedBox(height: 24.h),
              _buildOrderSummaryCard(),
              SizedBox(height: 24.h),
              _buildRatingSection(),
              SizedBox(height: 24.h),
              _buildActionButtons(),
              SizedBox(height: 24.h),
              _buildReportIssue(),
              SizedBox(height: 32.h),
            ],
          ),
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

  Widget _buildOrderSummaryCard() {
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
          _buildSummaryRow('رقم الطلب', '#${widget.orderId}'),
          SizedBox(height: 10.h),
          _buildSummaryRow('التاريخ', 'اليوم، 14:30'),
          SizedBox(height: 10.h),
          _buildSummaryRow('الموردون', '2'),
          SizedBox(height: 10.h),
          _buildSummaryRow('الإجمالي', '7,920 ر.س', isBlue: true),
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

  Widget _buildRatingSection() {
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
          _buildSupplierRatingRow(key: 'nile', name: 'أغذية النيل', logoAsset: 'assets/images/Nile_food.jpeg'),
          SizedBox(height: 16.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 16.h),
          _buildSupplierRatingRow(key: 'delta', name: 'دلتا للتجارة', logoAsset: 'assets/images/delta.jpeg'),
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
            final filled = index < _ratings[key]!;
            return GestureDetector(
              onTap: () => setState(() => _ratings[key] = index + 1),
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