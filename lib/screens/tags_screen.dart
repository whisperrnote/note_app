import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Action Bar
            _buildActionBar(),

            // Tags Grid
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildTagCard('Ideas', 'Experimental concepts and future visions', AppColors.electric, 12),
                  _buildTagCard('Work', 'Professional duties and project synchronization', Colors.purpleAccent, 45),
                  _buildTagCard('Life', 'Personal existence and daily manifestations', Colors.emeraldAccent, 28),
                  _buildTagCard('Web3', 'Blockchain integration and decentralized nodes', Colors.blueAccent, 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, AppColors.electric],
            ).createShader(bounds),
            child: Text(
              'TAGS MANAGEMENT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          Text(
            'Organize your notes with custom tags and colors',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.gunmetal,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '4 TAGS TOTAL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.carbon,
              letterSpacing: 1,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('NEW TAG'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electric,
              foregroundColor: AppColors.voidBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagCard(String name, String description, Color color, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        opacity: 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.tag, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$count notes',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.gunmetal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.gunmetal),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.titanium.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
