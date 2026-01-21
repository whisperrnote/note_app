import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ProfileIcon extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double size;

  const ProfileIcon({
    super.key,
    required this.label,
    required this.onTap,
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
          color: AppColors.electric,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(color: AppColors.voidBg, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              color: AppColors.voidBg,
              fontSize: size * 0.38,
            ),
          ),
        ),
      ),
    );
  }
}
