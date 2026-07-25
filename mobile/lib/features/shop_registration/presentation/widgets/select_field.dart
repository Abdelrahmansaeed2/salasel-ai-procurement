import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: ShopRegColors.trackInactive,
                  borderRadius: BorderRadius.circular(4),
                )),
                const SizedBox(height: 8),
                for (final option in options)
                  ListTile(
                    title: Text(
                      option,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(fontSize: 16, color: ShopRegColors.textDark),
                    ),
                    trailing: option == value
                        ? const Icon(Icons.check_rounded, color: ShopRegColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                const SizedBox(height: 8),
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
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ShopRegColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ShopRegColors.inputBorderLight),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            if (icon != null) ...[
              FigmaIcon(icon!, color: ShopRegColors.iconMuted, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value ?? placeholder,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: ShopRegColors.textDark,
                ),
              ),
            ),
            const FigmaIcon(ShopRegIcons.chevronDown, color: ShopRegColors.iconMuted, size: 12),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ShopRegColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
