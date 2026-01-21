import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final double size;

  const HeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.electric : AppColors.surface,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(
            color: isPrimary ? AppColors.electric : AppColors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: isPrimary ? AppColors.voidBg : AppColors.electric,
        ),
      ),
    );
  }
}
