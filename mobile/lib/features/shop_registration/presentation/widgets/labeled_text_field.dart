import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixText,
    this.showInfoIcon = false,
  });

  final String label;
  final String hint;
  final String? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final String? prefixText;
  final bool showInfoIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ShopRegColors.textBody,
              ),
            ),
            if (showInfoIcon) ...[
              const SizedBox(width: 6),
              FigmaIcon(ShopRegIcons.help, size: 16, color: ShopRegColors.textBody.withValues(alpha: 0.4)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          keyboardType: keyboardType,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: enabled ? ShopRegColors.textDark : ShopRegColors.iconMuted.withValues(alpha: 0.5),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(
              fontSize: 16,
              color: enabled ? ShopRegColors.textHint : ShopRegColors.iconMuted.withValues(alpha: 0.5),
            ),
            prefixIcon: (icon != null || prefixText != null)
                ? Padding(
                    padding: const EdgeInsets.only(right: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) FigmaIcon(icon!, size: 20, color: ShopRegColors.iconMuted),
                        if (prefixText != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            prefixText!,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ShopRegColors.textBody,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
            filled: true,
            fillColor: ShopRegColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ShopRegColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ShopRegColors.inputBorder),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ShopRegColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ShopRegColors.primaryAction, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
