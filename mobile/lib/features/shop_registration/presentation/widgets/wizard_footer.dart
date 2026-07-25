import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';

class WizardFooter extends StatelessWidget {
  const WizardFooter({
    super.key,
    required this.continueLabel,
    required this.onContinue,
    this.showBack = false,
    this.onBack,
    this.continueEnabled = true,
    this.continueIcon = ShopRegIcons.forwardArrowButton,
  });

  final String continueLabel;
  final VoidCallback onContinue;
  final bool showBack;
  final VoidCallback? onBack;
  final bool continueEnabled;
  final String continueIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ShopRegColors.inputBorderLight)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _ContinueButton(
              label: continueLabel,
              icon: continueIcon,
              enabled: continueEnabled,
              onPressed: continueEnabled ? onContinue : null,
            ),
          ),
          if (showBack) ...[
            const SizedBox(width: 8),
            _BackButton(onPressed: onBack),
          ],
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.icon,
    required this.enabled,
    this.onPressed,
  });

  final String label;
  final String icon;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? ShopRegColors.primaryAction : ShopRegColors.primaryAction.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.primaryActionText,
                ),
              ),
              const SizedBox(width: 12),
              FigmaIcon(icon, size: 16, color: ShopRegColors.primaryActionText),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: ShopRegColors.backButtonBorder, width: 0.8),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'رجوع',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              const FigmaIcon(ShopRegIcons.backChevronSmall, size: 14, color: ShopRegColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
