import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../data/models/inventory_models.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/ai_insights_card.dart';
import 'add_inventory_item_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

    // Show dialog when showAiInsights becomes true
    ever(controller.showAiInsights, (bool show) {
      if (show) {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AiInsightsCard(
                productName: controller.aiRecommendations.isNotEmpty ? controller.aiRecommendations.first.productName : 'منتج',
                days: controller.aiRecommendations.isNotEmpty ? controller.aiRecommendations.first.recommendedLeadTimeDays.toString() : '2',
                onAdd: () {
                  final productName = controller.aiRecommendations.isNotEmpty ? controller.aiRecommendations.first.productName : 'المنتج';
                  controller.dismissAiInsights();
                  Get.back();
                  Get.snackbar(
                    'تمت الإضافة', 
                    'تمت إضافة $productName لقائمة الطلبات',
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    colorText: Colors.green,
                  );
                },
                onDismiss: () {
                  controller.dismissAiInsights();
                  Get.back();
                },
              ),
            ),
          ),
          barrierDismissible: true,
        ).then((_) => controller.dismissAiInsights());
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(controller),
        body: SafeArea(
          child: Column(
            children: [
              _buildStatsRow(controller),
              SizedBox(height: 16.h),
              _buildSearchBar(controller),
              SizedBox(height: 16.h),
              _buildFilters(controller),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = controller.filteredProducts;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48.w, color: const Color(0xFFCBD5E1)),
                          SizedBox(height: 12.h),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 16.sp,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.fetchInventory(),
                    color: const Color(0xFF2563EB),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) =>
                          _buildProductCard(list[index]),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to Add Inventory Item Screen
            Get.to(() => const AddInventoryItemScreen());
          },
          backgroundColor: const Color(0xFF2563EB),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNavBar(
            currentIndex: controller.bottomNavIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(InventoryController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () {},
      ),
      title: Column(
        children: [
          Text(
            'إدارة المخزون',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
          Obx(() => Text(
            '${controller.products.length} منتج • آخر تحديث: الآن',
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF2563EB)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsRow(InventoryController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => _StatBox(label: 'مرتفع', count: controller.highStockCount.toString(), color: const Color(0xFF3B82F6), bgColor: const Color(0xFFEFF6FF))),
          Obx(() => _StatBox(label: 'متوفر', count: controller.goodStockCount.toString(), color: const Color(0xFF10B981), bgColor: const Color(0xFFECFDF5))),
          Obx(() => _StatBox(label: 'منخفض', count: controller.lowStockCount.toString(), color: const Color(0xFFF59E0B), bgColor: const Color(0xFFFFFBEB))),
          Obx(() => _StatBox(label: 'حرج', count: controller.criticalStockCount.toString(), color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEF2F2))),
        ],
      ),
    );
  }

  Widget _buildSearchBar(InventoryController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          textDirection: TextDirection.rtl,
          onChanged: controller.setSearchText,
          decoration: InputDecoration(
            hintText: 'البحث عن منتج، رمز SKU، أو علامة تجارية...',
            hintStyle: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 14.sp,
              fontFamily: 'Cairo',
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(InventoryController controller) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.setFilter(filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductCard(InventoryItemModel product) {
    Color getStatusColor(String status) {
      if (status == 'منخفض جداً') return const Color(0xFFEF4444);
      if (status == 'منخفض') return const Color(0xFFF59E0B);
      if (status == 'متوفر') return const Color(0xFF10B981);
      return const Color(0xFF3B82F6);
    }
    
    Color getStatusBgColor(String status) {
      if (status == 'منخفض جداً') return const Color(0xFFFEF2F2);
      if (status == 'منخفض') return const Color(0xFFFFFBEB);
      if (status == 'متوفر') return const Color(0xFFECFDF5);
      return const Color(0xFFEFF6FF);
    }

    final color = getStatusColor(product.status);
    final bgColor = getStatusBgColor(product.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.inventory_2_outlined, color: const Color(0xFFCBD5E1), size: 32.w),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.productName,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      product.status,
                      style: TextStyle(
                        color: color,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${product.category} • ${product.sku}',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.unitOfMeasure,
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12.sp,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${product.currentQty.toStringAsFixed(product.currentQty.truncateToDouble() == product.currentQty ? 0 : 2)} / ${product.maxQty.toStringAsFixed(product.maxQty.truncateToDouble() == product.maxQty ? 0 : 2)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: 100.w,
                        child: LinearProgressIndicator(
                          value: product.stockPercentage,
                          backgroundColor: color.withValues(alpha: 0.15),
                          color: color,
                          minHeight: 4.h,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (product.status == 'منخفض جداً')
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(100.w, 36.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 16.w),
                          SizedBox(width: 6.w),
                          Text(
                            'إعادة طلب',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.find<InventoryController>().updateQuantity(product.inventoryId, product.currentQty, 1),
                          icon: Icon(Icons.add_circle_outline, color: const Color(0xFF475569)),
                        ),
                        Text(
                          product.currentQty.toStringAsFixed(product.currentQty.truncateToDouble() == product.currentQty ? 0 : 2),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.find<InventoryController>().updateQuantity(product.inventoryId, product.currentQty, -1),
                          icon: Icon(Icons.remove_circle_outline, color: const Color(0xFF475569)),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Divider(color: const Color(0xFFF1F5F9), height: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final Color bgColor;

  const _StatBox({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
