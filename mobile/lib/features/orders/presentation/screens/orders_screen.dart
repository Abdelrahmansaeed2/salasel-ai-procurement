import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/orders_list_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import 'checkout_screen.dart';
import 'delivery_tracking_screen.dart';
import 'voice_order_detail_screen.dart';
import 'return_request_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(OrdersController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.showAiInsights.value && mounted) {
        _showAiDialog(c);
      }
    });

    ever(c.showAiInsights, (bool show) {
      if (show && mounted) {
        _showAiDialog(c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(c),
            _buildSearchBar(c),
            _buildFilters(c),
            Expanded(child: _buildBody(c)),
            _buildSummaryBar(c),
          ],
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNavBar(
            currentIndex: c.bottomNavIndex.value,
            onTap: c.changeTab,
          ),
        ),
      ),
    );
  }

  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.search_rounded, color: Color(0xFF1E293B)),
        onPressed: () {},
      ),
      title: Text(
        'Salasel',
        style: TextStyle(
          color: const Color(0xFF1E293B),
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          fontFamily: 'Cairo',
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B)),
          onPressed: () {},
        ),
      ],
    );
  }

  
  Widget _buildTabBar(OrdersController c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Obx(() => Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'الطلبات النشطة',
                    count: c.activeOrders.length,
                    isSelected: c.tabIndex.value == 0,
                    onTap: () => c.setTab(0),
                  ),
                ),
                Expanded(
                  child: _TabChip(
                    label: 'السجل',
                    count: c.historyOrders.length,
                    isSelected: c.tabIndex.value == 1,
                    onTap: () => c.setTab(1),
                  ),
                ),
                Expanded(
                  child: _TabChip(
                    label: 'المرتجعات',
                    count: c.returnsOrders.length,
                    isSelected: c.tabIndex.value == 2,
                    onTap: () => c.setTab(2),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  
  Widget _buildSearchBar(OrdersController c) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.tune_rounded,
                color: const Color(0xFF64748B), size: 22.w),
            onPressed: () => _showFilterModalBottomSheet(context, c),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: c.setSearch,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث برقم الطلب أو المورد...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                  ),
                  suffixIcon: Icon(Icons.search_rounded,
                      color: const Color(0xFF94A3B8), size: 20.w),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Color _getFilterColor(String filter, bool isSelected) {
    if (isSelected) return const Color(0xFF1E293B);
    switch (filter) {
      case 'قيد الانتظار':
        return const Color(0xFFFEF3C7);
      case 'مقبول':
        return const Color(0xFFD1FAE5);
      case 'تم الشحن':
        return const Color(0xFFEDE9FE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getFilterTextColor(String filter, bool isSelected) {
    if (isSelected) return Colors.white;
    switch (filter) {
      case 'قيد الانتظار':
        return const Color(0xFFD97706);
      case 'مقبول':
        return const Color(0xFF059669);
      case 'تم الشحن':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Widget _buildFilters(OrdersController c) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 12.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: c.filters.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final f = c.filters[i];
            return Obx(() {
              final selected = c.selectedFilter.value == f;
              return GestureDetector(
                onTap: () => c.setFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getFilterColor(f, selected),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1E293B)
                          : _getFilterColor(f, selected),
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: _getFilterTextColor(f, selected),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  
  Widget _buildBody(OrdersController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
      }

      if (c.tabIndex.value == 2) {
        final returns = c.returnsOrders;
        if (returns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64.w, color: const Color(0xFFCBD5E1)),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد طلبات استرجاع',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchReturns,
          color: const Color(0xFF2563EB),
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: returns.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return _buildReturnCard(returns[index], c);
            },
          ),
        );
      }

      final orders = c.displayedOrders;
      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56.w, color: const Color(0xFFCBD5E1)),
              SizedBox(height: 12.h),
              Text(
                'لا توجد طلبات',
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
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) => _OrderCard(order: orders[i], controller: c),
      );
    });
  }

  
  Widget _buildSummaryBar(OrdersController c) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الطلبات النشطة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${c.activeTotalAmount.toStringAsFixed(0)} جنيه',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '12٪ زيادة عن الشهر الماضي',
                        style: TextStyle(
                          color: const Color(0xFF34D399),
                          fontSize: 11.sp,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.trending_up_rounded,
                          color: const Color(0xFF34D399), size: 16.w),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
  }

  
  void _showAiDialog(OrdersController c) {
    final insight = c.currentInsight.value;
    if (insight == null) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'رؤى سلاسل الذكية',
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: const Color(0xFF2563EB), size: 22.w),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 14.sp,
                      height: 1.7,
                      fontFamily: 'Cairo',
                    ),
                    children: [
                      TextSpan(text: 'بناءً على طلباتك الأخيرة، نوصي بإعادة طلب '),
                      TextSpan(
                        text: '"${insight.productName}"',
                        style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (insight.recommendedSupplierName != null)
                        TextSpan(text: ' من ${insight.recommendedSupplierName} '),
                      TextSpan(text: 'لأن ${insight.reason}'),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          c.dismissAi();
                          Get.back();
                          
                          final cartCtrl = Get.put(CartController());
                          cartCtrl.addItem(CartItem(
                            productId: insight.productId,
                            name: insight.productName,
                            sku: '',
                            unit: 'وحدة',
                            imageUrl: '',
                            price: insight.recommendedUnitPrice ?? 100.0,
                            quantity: insight.reorderThreshold > 0 ? insight.reorderThreshold : 1,
                          ));

                          Get.snackbar('تمت الإضافة',
                              'تمت إضافة الطلب للسلة بنجاح',
                              backgroundColor:
                                  const Color(0xFF10B981).withValues(alpha: 0.15),
                              colorText: const Color(0xFF065F46));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'موافقة وإضافة للسلة',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    TextButton(
                      onPressed: () {
                        c.dismissAi();
                        Get.back();
                      },
                      child: Text(
                        'تجاهل',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    ).then((_) => c.dismissAi());
  }
  void _showFilterModalBottomSheet(BuildContext context, OrdersController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'تصفية الطلبات',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'نطاق التاريخ',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() => Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildFilterChip('الكل', c),
                    _buildFilterChip('آخر 7 أيام', c),
                    _buildFilterChip('آخر 30 يوم', c),
                    _buildFilterChip('هذا الشهر', c),
                  ],
                )),
                SizedBox(height: 24.h),
                Text(
                  'نطاق السعر',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'الحد الأدنى',
                          style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp, fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text('-', style: TextStyle(color: const Color(0xFF94A3B8))),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'الحد الأعلى',
                          style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp, fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          c.resetAdvancedFilters();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Text(
                          'إعادة ضبط',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          // The controller automatically updates the displayedOrders
                          Navigator.pop(context);
                          Get.snackbar('تم تطبيق التصفية', 'تم تحديث قائمة الطلبات بنجاح');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'تطبيق التصفية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, OrdersController c) {
    final isSelected = c.dateFilter.value == label;
    return GestureDetector(
      onTap: () => c.setDateFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrdersController controller;

  const _OrderCard({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    const steps = ['فُرسل', 'مقبول', 'بالطريق', 'وصل'];
    final activeStep = controller.stepIndex(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14.w, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Text(
                      '${order.date.day} Oct ${order.date.year}',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.supplierName,
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8.r),
                    image: order.supplierLogo.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(order.supplierLogo),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: order.supplierLogo.isEmpty
                      ? Icon(Icons.store_outlined,
                          color: const Color(0xFF94A3B8), size: 24.w)
                      : null,
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _OrderStepper(steps: steps, activeStep: activeStep),
          ),
          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        item.name,
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontSize: 13.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.date.day}/${order.date.month}/${order.date.year}',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: order.total.toStringAsFixed(0),
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      TextSpan(
                        text: ' جنيه',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (activeStep == 0 || activeStep == 3 || (activeStep == 1 && order.status == OrderStatus.accepted)) {
                        Get.to(() => VoiceOrderDetailScreen(
                          orderId: int.parse(order.id),
                        ));
                      } else if (activeStep == 1 && order.status == OrderStatus.pendingPayment) {
                        Get.to(() => CheckoutScreen(
                          orderId: order.orderNumber,
                          totalAmount: '${order.total.toStringAsFixed(0)} جنيه',
                          supplierName: order.supplierName,
                          itemsSummary: order.items.isNotEmpty ? order.items[0].name : '',
                          merchantName: 'مخبز الأمل', // Placeholder for now
                          merchantAddress: 'شارع التحلية، بجوار المركز الرئيسي', // Placeholder
                          merchantCity: 'الرياض', // Placeholder
                        ));
                      } else if (activeStep >= 2) {
                        Get.to(() => DeliveryTrackingScreen(orderId: order.orderNumber));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ((activeStep == 1 && order.status == OrderStatus.pendingPayment) || activeStep == 2) ? const Color(0xFF2563EB) : Colors.white,
                      foregroundColor: ((activeStep == 1 && order.status == OrderStatus.pendingPayment) || activeStep == 2) ? Colors.white : const Color(0xFF1E293B),
                      elevation: 0,
                      side: BorderSide(color: ((activeStep == 1 && order.status == OrderStatus.pendingPayment) || activeStep == 2) ? Colors.transparent : const Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      (activeStep == 1 && order.status == OrderStatus.pendingPayment) ? 'الدفع الآن' : (activeStep == 2 ? 'تتبع التوصيل' : 'التفاصيل'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: ((activeStep == 1 && order.status == OrderStatus.pendingPayment) || activeStep == 2) ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                if (order.status == OrderStatus.delivered) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => ReturnRequestScreen(
                          orderId: order.orderNumber,
                          masterOrderId: order.id,
                          totalAmount: order.total,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEF4444), // Red for return
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'إرجاع الطلب',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.reorder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Green for reorder
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'إعادة الطلب',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStepper extends StatelessWidget {
  final List<String> steps;
  final int activeStep;

  const _OrderStepper({required this.steps, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final filled = stepIndex < activeStep;
          return Expanded(
            child: Container(
              height: 2.h,
              color: filled ? const Color(0xFF10B981) : const Color(0xFFEFF6FF),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex < activeStep;
        final active = stepIndex == activeStep;

        return Column(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF10B981)
                    : active
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: done
                      ? const Color(0xFF10B981)
                      : active
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFEFF6FF),
                  width: 2,
                ),
              ),
              child: done
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 16.w)
                  : active
                      ? Container(
                          margin: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            SizedBox(height: 6.h),
            Text(
              steps[stepIndex],
              style: TextStyle(
                color: done
                    ? const Color(0xFF10B981)
                    : active
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8),
                fontSize: 10.sp,
                fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        );
      }));
    }
  }

  Widget _buildReturnCard(ReturnOrderModel ret, OrdersController c) {
    String statusStr = 'قيد الانتظار';
    Color statusColor = const Color(0xFFF59E0B);

    if (ret.status == ReturnStatus.approved) {
      statusStr = 'تمت الموافقة (بانتظار الاستلام)';
      statusColor = const Color(0xFF2563EB);
    } else if (ret.status == ReturnStatus.rejected) {
      statusStr = 'مرفوض';
      statusColor = const Color(0xFFEF4444);
    } else if (ret.status == ReturnStatus.refunded) {
      statusStr = 'تم الاسترجاع';
      statusColor = const Color(0xFF10B981);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الطلب الأصلي: ${ret.masterOrderId}',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'المبلغ المطلوب: ${ret.requestedAmount} ر.س',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }


class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
