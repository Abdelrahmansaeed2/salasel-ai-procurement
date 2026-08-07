import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../theme/order_colors.dart';
import 'delivery_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final String totalAmount;

  const CheckoutScreen({
    super.key,
    this.orderId = '١٢٣٤٥',
    this.totalAmount = '٧,٩٢٠ ر.س',
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'credit_card';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildOrderSummary(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('تفاصيل الموردين'),
                      SizedBox(height: 12.h),
                      _buildSupplierDetails(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('طريقة الدفع'),
                      SizedBox(height: 12.h),
                      _buildPaymentMethodsRow(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('عنوان التوصيل', actionText: 'تغيير', onAction: () {}),
                      SizedBox(height: 12.h),
                      _buildAddressCard(),
                      SizedBox(height: 24.h),
                      _buildPaymentSummary(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color:  Color(0xFFF9FAFC),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedPressable(
                borderRadius: BorderRadius.circular(999.r),
                onTap: () => Get.back(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.arrow_forward_rounded, color: OrderColors.textDark, size: 22.w),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'إتمام الطلب',
                style: TextStyle(
                  color: OrderColors.textDark,
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            'طلب #${widget.orderId}',
            style: TextStyle(
              color: OrderColors.textMuted,
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? actionText, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: OrderColors.textTitle,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: TextStyle(
                color: OrderColors.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ملخص الطلب',
                style: TextStyle(
                  color: OrderColors.textTitle,
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: OrderColors.primary,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'معالج بالذكاء الاصطناعي',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('الموردين', '٢'),
              _buildSummaryItem('المنتجات', '١٤'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: OrderColors.textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(color: OrderColors.textTitle, fontSize: 18.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  Widget _buildSupplierDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Supplier info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  border: Border.all(color: OrderColors.cardBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/Nile_food.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.storefront_outlined, color: OrderColors.primary, size: 24.w),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أغذية النيل',
                      style: TextStyle(color: OrderColors.textTitle, fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                    ),
                    Text(
                      'وقت الوصول: غداً صباحاً',
                      style: TextStyle(color: OrderColors.textMuted, fontSize: 11.sp, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
              Text(
                '٤,٥٠٠ ر.س',
                style: TextStyle(color: OrderColors.primary, fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          // Product info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  border: Border.all(color: OrderColors.cardBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/payment_flour.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.shopping_bag_outlined, color: OrderColors.textFaint, size: 24.w),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دقيق فاخر ٥٠ كجم',
                      style: TextStyle(color: OrderColors.textTitle, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                    ),
                    Text(
                      'الكمية: ١٠',
                      style: TextStyle(color: OrderColors.textMuted, fontSize: 11.sp, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
              Text(
                '١,٢٠٠ ر.س',
                style: TextStyle(color: OrderColors.textTitle, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            value: 'credit_card',
            title: 'بطاقة ائتمان',
            icon: Icons.credit_card,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildPaymentMethodCard(
            value: 'wallet',
            title: 'المحفظة',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildPaymentMethodCard(
            value: 'cod',
            title: 'الدفع عند الاستلام',
            icon: Icons.money,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({required String value, required String title, required IconData icon}) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        height: 76.h,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? OrderColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? OrderColors.primary : OrderColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? OrderColors.primary : OrderColors.textMuted,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? OrderColors.primary : OrderColors.textMuted,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Row(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: OrderColors.chipBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              'assets/images/map_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.map_outlined, color: OrderColors.textFaint, size: 32.w),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مستودع الرياض الرئيسي',
                style: TextStyle(color: OrderColors.textTitle, fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
              SizedBox(height: 4.h),
              Text(
                'شارع الملك فهد، العليا، الرياض',
                style: TextStyle(color: OrderColors.textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
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
            'ملخص الدفع',
            style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          _buildSummaryRow('المجموع الفرعي', '٦,٨٠٠ ر.س'),
          SizedBox(height: 12.h),
          _buildSummaryRow('ضريبة القيمة المضافة (١٥٪)', '١,٠٢٠ ر.س'),
          SizedBox(height: 12.h),
          _buildSummaryRow('رسوم التوصيل', '١٠٠ ر.س'),
          SizedBox(height: 16.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: TextStyle(color: OrderColors.primary, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
              Text(
                '٧,٩٢٠ ر.س',
                style: TextStyle(color: OrderColors.primary, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: OrderColors.textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
        ),
        Text(
          value,
          style: TextStyle(color: OrderColors.textTitle, fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Get.snackbar(
            'تم الدفع بنجاح',
            'تم تأكيد طلبك بنجاح',
            backgroundColor: OrderColors.successBg,
            colorText: OrderColors.success,
            margin: EdgeInsets.all(16.w),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Get.off(() => DeliveryTrackingScreen(orderId: widget.orderId));
          });
        },
        child: Container(
          height: 52.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrderColors.primaryDark,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'تأكيد ودفع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}
