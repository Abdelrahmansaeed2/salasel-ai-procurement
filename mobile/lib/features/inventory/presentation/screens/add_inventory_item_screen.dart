import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import 'barcode_scanner_screen.dart';
import 'voice_inventory_screen.dart';
import '../../../../../core/network/api_client.dart';

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({super.key});

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _qtyController = TextEditingController();
  final _costController = TextEditingController();

  int? _matchedProductId;
  bool _isLoading = false;

  final controller = Get.find<InventoryController>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      controller.addItem(
        productId: _matchedProductId,
        customProductName: _nameController.text,
        customCategory: _categoryController.text,
        customBarcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
        currentQty: double.tryParse(_qtyController.text) ?? 0.0,
        reorderThreshold: 10.0, // Default threshold for now
        costPrice: double.tryParse(_costController.text) ?? 0.0,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'إضافة للمخزون',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Option 1: Barcode Scan
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    final result = await Get.to(() => const BarcodeScannerScreen());
                    if (result != null && result is String) {
                      _lookupBarcode(result);
                    }
                  },
                  icon: _isLoading 
                    ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.qr_code_scanner),
                  label: Text(
                    'مسح الباركود',
                    style: TextStyle(fontSize: 16.sp, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 12.h),

                // Option 2: Voice Input
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => const VoiceInventoryScreen());
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        if (result['productName'] != null) {
                          _nameController.text = result['productName'];
                        }
                        if (result['quantity'] != null) {
                          _qtyController.text = result['quantity'].toString();
                        }
                      });
                      Get.snackbar('نجاح', 'تم استخراج البيانات من الصوت', backgroundColor: Colors.green.withValues(alpha: 0.1), colorText: Colors.green);
                    }
                  },
                  icon: const Icon(Icons.mic),
                  label: Text(
                    'إضافة سريعة بالصوت',
                    style: TextStyle(fontSize: 16.sp, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 24.h),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'أو إدخال يدوي',
                        style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp, fontFamily: 'Cairo'),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24.h),

                // Manual Entry Form
                _buildTextField(
                  controller: _nameController,
                  label: 'اسم المنتج',
                  icon: Icons.inventory_2_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _categoryController,
                  label: 'الفئة (مثل: خضروات، منظفات)',
                  icon: Icons.category_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _barcodeController,
                  label: 'الباركود (اختياري)',
                  icon: Icons.qr_code,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _qtyController,
                        label: 'الكمية',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _costController,
                        label: 'سعر التكلفة',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    'حفظ المنتج',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: const Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  Future<void> _lookupBarcode(String barcode) async {
    setState(() {
      _isLoading = true;
      _barcodeController.text = barcode;
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('/inventory/lookup', queryParameters: {'barcode': barcode});

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _matchedProductId = data['productId'];
          _nameController.text = data['productName'] ?? '';
          _categoryController.text = data['categoryName'] ?? '';
          // Leave Qty and Cost empty for user to fill
        });
        Get.snackbar('نجاح', 'تم العثور على المنتج بنجاح', backgroundColor: Colors.green.withValues(alpha: 0.1), colorText: Colors.green);
      }
    } catch (e) {
      Get.snackbar('مسح الباركود', 'لم يتم العثور على المنتج في النظام. يرجى إكمال البيانات يدوياً.', duration: const Duration(seconds: 4));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
