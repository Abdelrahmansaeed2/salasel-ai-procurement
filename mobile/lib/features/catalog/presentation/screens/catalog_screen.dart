import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../orders/presentation/theme/order_colors.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/screens/cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  final CartController _cartController = Get.put(CartController());
  
  List<dynamic> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    if (query.trim().length < 2) {
      setState(() => _products = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get('/products/search', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        setState(() => _products = response.data);
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'تصفح المنتجات',
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
          actions: [
            Obx(() => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: OrderColors.textDark),
                  onPressed: () => Get.to(() => const CartScreen()),
                ),
                if (_cartController.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: OrderColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_cartController.itemCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
              ],
            )),
            SizedBox(width: 8.w),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (val == _searchController.text) _searchProducts(val);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج (مثل: سكر، أرز)...',
                  hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: OrderColors.primary))
                : _products.isEmpty
                  ? Center(
                      child: Text(
                        'ابحث لإضافة منتجات للسلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: OrderColors.textMuted,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        return _buildProductCard(p);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
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
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: OrderColors.textDark,
                  ),
                ),
                Text(
                  p['categoryName'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: OrderColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _cartController.addItem(CartItem(
                productId: p['id'],
                name: p['name'] ?? '',
                sku: p['sku'] ?? '',
                unit: p['unit'] ?? 'وحدة',
                imageUrl: p['imageUrl'] ?? '',
                price: 100.0, // Mock price for manual adding
              ));
              Get.snackbar(
                'تمت الإضافة',
                'تم إضافة ${p['name']} إلى السلة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: OrderColors.primary,
                colorText: Colors.white,
                margin: EdgeInsets.all(16.w),
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OrderColors.primary.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Icon(Icons.add_shopping_cart, color: OrderColors.primary),
          )
        ],
      ),
    );
  }
}
