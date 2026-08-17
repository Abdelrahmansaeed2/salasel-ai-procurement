import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../orders/presentation/theme/order_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'سلة المشتريات',
            style: TextStyle(
              color: OrderColors.textDark,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: OrderColors.textDark),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80.w, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(
                    'السلة فارغة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20.sp,
                      color: OrderColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrderColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('تصفح المنتجات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return _buildCartItemCard(item, controller);
                  },
                ),
              ),
              _buildBottomCheckoutBar(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, CartController controller) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              image: item.imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: item.imageUrl.isEmpty ? Icon(Icons.image_not_supported, color: Colors.grey) : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: OrderColors.textDark,
                  ),
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} ر.س / ${item.unit}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: OrderColors.textMuted,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () => controller.updateQuantity(item.productId, item.quantity - 1)),
                    SizedBox(width: 12.w),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _buildQtyBtn(Icons.add, () => controller.updateQuantity(item.productId, item.quantity + 1)),
                    const Spacer(),
                    Text(
                      '${(item.price * item.quantity).toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: OrderColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 20.w, color: OrderColors.textDark),
      ),
    );
  }

  Widget _buildBottomCheckoutBar(CartController controller) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    color: OrderColors.textMuted,
                  ),
                ),
                Text(
                  '${controller.subtotal.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: OrderColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value ? null : () => controller.checkout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrderColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: controller.isProcessing.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'إتمام الطلب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
