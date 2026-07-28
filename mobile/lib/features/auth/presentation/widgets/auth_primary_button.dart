import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/auth_theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56.h,
      decoration: BoxDecoration(
        color: enabled ? AuthColors.primary : AuthColors.disabledButton,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AuthColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(label, style: AuthTextStyles.buttonText),
          ),
        ),
      ),
    );
  }
}
