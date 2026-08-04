import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../theme/order_colors.dart';
import 'delivery_tracking_screen.dart';

class _Icons {
  static const backArrow =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M12.175 9H0V7H12.175L6.575 1.4L8 0L16 8L8 16L6.575 14.6L12.175 9Z" fill="#333333"/></svg>';
}

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final String totalAmount;

  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      _buildOrderSummary(),
                      SizedBox(height: 24.h),
                      Text(
                        'طريقة الدفع',
                        style: TextStyle(
                          color: OrderColors.textTitle,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildPaymentOption(
                        value: 'credit_card',
                        title: 'البطاقة الائتمانية / مدى',
                        icon: Icons.credit_card,
                      ),
                      if (_selectedPaymentMethod == 'credit_card') _buildCreditCardForm(),
                      SizedBox(height: 12.h),
                      _buildPaymentOption(
                        value: 'bank_transfer',
                        title: 'تحويل بنكي',
                        icon: Icons.account_balance,
                      ),
                      SizedBox(height: 12.h),
                      _buildPaymentOption(
                        value: 'apple_pay',
                        title: 'Apple Pay',
                        icon: Icons.phone_iphone,
                      ),
                      SizedBox(height: 24.h),
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
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xCCFAF8FF),
        boxShadow: [
          const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            const Spacer(),
            Text(
              'الدفع وإنهاء الطلب',
              style: TextStyle(
                color: OrderColors.textDark,
                fontFamily: 'Cairo',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                height: 1.25.h,
              ),
            ),
            SizedBox(width: 12.w),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999.r),
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: const Icon(Icons.arrow_forward_ios, size: 20, color: OrderColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: OrderColors.cardBorder),
        boxShadow: [
          const BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم الطلب',
                style: TextStyle(color: OrderColors.textFaint, fontSize: 14.sp, fontFamily: 'Cairo'),
              ),
              Text(
                widget.orderId,
                style: TextStyle(color: OrderColors.textTitle, fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: TextStyle(color: OrderColors.textFaint, fontSize: 16.sp, fontFamily: 'Cairo'),
              ),
              Text(
                widget.totalAmount,
                style: TextStyle(color: OrderColors.primary, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String value, required String title, required IconData icon}) {
    final isSelected = _selectedPaymentMethod == value;
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? OrderColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? OrderColors.primary : OrderColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            const BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? OrderColors.primary : OrderColors.textMuted, size: 24.w),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                color: OrderColors.textTitle,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: OrderColors.primary, size: 24.w)
            else
              Icon(Icons.radio_button_unchecked, color: OrderColors.textFaint, size: 24.w),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: OrderColors.cardBorder),
        boxShadow: [
          const BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          _buildTextField('رقم البطاقة'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildTextField('تاريخ الانتهاء (MM/YY)')),
              SizedBox(width: 12.w),
              Expanded(child: _buildTextField('CVV', obscureText: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      textDirection: TextDirection.ltr,
      obscureText: obscureText,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14.sp,
        color: OrderColors.textBody,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: OrderColors.textMuted,
          fontFamily: 'Cairo',
          fontSize: 13.sp,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: OrderColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: OrderColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Get.snackbar(
            'تم الدفع بنجاح',
            'تم تأكيد طلبك وتحويل المبلغ للمورد.',
            backgroundColor: OrderColors.successBg,
            colorText: OrderColors.success,
            margin: EdgeInsets.all(16.w),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Get.off(() => DeliveryTrackingScreen(orderId: widget.orderId));
          });
        },
        child: Container(
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrderColors.primary,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'تأكيد الدفع (${widget.totalAmount})',
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
