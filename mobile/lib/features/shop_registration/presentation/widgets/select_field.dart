import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
    this.icon,
    this.label,
  });

  final String? value;
  final String placeholder;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? icon;
  final String? label;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Container(width: 40.w, height: 4.h, decoration: BoxDecoration(
                  color: ShopRegColors.trackInactive,
                  borderRadius: BorderRadius.circular(4.r),
                )),
                SizedBox(height: 8.h),
                for (final option in options)
                  ListTile(
                    title: Text(
                      option,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(fontSize: 16.sp, color: ShopRegColors.textDark),
                    ),
                    trailing: option == value
                        ? Icon(Icons.check_rounded, color: ShopRegColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final field = InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => _openPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: ShopRegColors.inputFill,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: ShopRegColors.inputBorderLight),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            if (icon != null) ...[
              FigmaIcon(icon!, color: ShopRegColors.iconMuted, size: 18.w),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                value ?? placeholder,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: ShopRegColors.textDark,
                ),
              ),
            ),
            FigmaIcon(ShopRegIcons.chevronDown, color: ShopRegColors.iconMuted, size: 12.w),
          ],
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: ShopRegColors.textBody,
          ),
        ),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }
}
