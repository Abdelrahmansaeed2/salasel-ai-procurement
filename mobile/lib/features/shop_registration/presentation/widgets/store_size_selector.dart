import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoreSizeSelector extends StatelessWidget {
  const StoreSizeSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ShopRegColors.segmentedBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: options.map((option) {
          final isSelected = option == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: isSelected ? ShopRegColors.primary : Color(0xFF505F76),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
