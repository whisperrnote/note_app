import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class focusModeScreen extends StatefulWidget {
  const focusModeScreen({super.key});

  @override
  State<focusModeScreen> createState() => _focusModeScreenState();
}

class _focusModeScreenState extends State<focusModeScreen> {
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Minimal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        'SYNTHESIS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electric,
                          letterSpacing: 4,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x, color: AppColors.gunmetal, size: 20),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      autofocus: true,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: AppColors.titanium,
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: AppColors.electric,
                      decoration: InputDecoration(
                        hintText: 'Speak to the void...',
                        hintStyle: GoogleFonts.inter(color: AppColors.gunmetal.withOpacity(0.3)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // AI Pulse
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.electric,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electric.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat()).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 2.seconds,
                      curve: Curves.easeInOutSine,
                    ).then().scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(0.8, 0.8),
                      duration: 2.seconds,
                      curve: Curves.easeInOutSine,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
