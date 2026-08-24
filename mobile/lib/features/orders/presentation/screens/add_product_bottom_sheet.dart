import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/order_review_controller.dart';
import '../../domain/order_review_models.dart';

class AddProductBottomSheet extends StatefulWidget {
  final OrderReviewController controller;

  const AddProductBottomSheet({super.key, required this.controller});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await widget.controller.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  void _showAddQuantityDialog(Map<String, dynamic> productData) {
    int quantity = 1;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إضافة ${productData['name']}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFF004AC6),
                        iconSize: 32.w,
                      ),
                      SizedBox(width: 24.w),
                      Text(
                        '$quantity',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF004AC6),
                        iconSize: 32.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        // Assuming the API returns unit price. Mock it if missing.
                        double price = 10.0;
                        if (productData.containsKey('price') && productData['price'] != null) {
                          price = double.tryParse(productData['price'].toString()) ?? 10.0;
                        }
                        
                        final product = ExtractedProduct(
                          productId: productData['id'],
                          name: productData['name'],
                          quantity: quantity,
                          unitLabel: productData['unit'] ?? 'وحدة',
                          unitPrice: price,
                        );
                        
                        widget.controller.addProduct(product);
                        Get.back(); // close dialog
                        Get.back(); // close bottom sheet
                        Get.snackbar(
                          'تمت الإضافة', 
                          'تمت إضافة ${productData['name']} بنجاح.',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        'إضافة للطلب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج (مثال: طماطم)...',
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF004AC6)),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AC6)))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.length < 2
                                ? 'اكتب اسم المنتج للبحث'
                                : 'لم يتم العثور على منتجات.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item['name'] ?? 'منتج غير معروف',
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                item['categoryName'] ?? '',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _showAddQuantityDialog(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE6F0FF),
                                  foregroundColor: const Color(0xFF004AC6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                child: Text('إضافة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
