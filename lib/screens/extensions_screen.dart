import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  int _activeTab = 0; // 0: Marketplace, 1: Installed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tabs
            _buildTabs(),

            // Extensions Grid
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildExtensionCard(
                    'AI Note Revisor',
                    'Automatically revise and improve notes using AI when they are created',
                    '🧠',
                    'v1.0.0',
                    'AI Enhancement',
                    true,
                  ),
                  _buildExtensionCard(
                    'Smart Auto-Tagger',
                    'Automatically extract and add relevant tags to notes based on content',
                    '⚡',
                    'v1.2.4',
                    'Organization',
                    false,
                  ),
                  _buildExtensionCard(
                    'Security Scanner',
                    'Scan notes for sensitive information and apply additional encryption',
                    '🛡️',
                    'v1.1.0',
                    'Security',
                    false,
                  ),
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
              'EXTENSIONS MARKET',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          Text(
            'Extend Whisperrnote with powerful plugins and automations',
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

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Marketplace',
            isActive: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          _TabItem(
            label: 'Installed',
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionCard(String name, String description, String icon, String version, String category, bool isInstalled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        opacity: 0.6,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.electric.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.electric.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
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
                        version,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.gunmetal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isInstalled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electric.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'INSTALLED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electric,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.titanium.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gunmetal,
                    letterSpacing: 1,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInstalled ? Colors.redAccent.withOpacity(0.1) : AppColors.electric,
                    foregroundColor: isInstalled ? Colors.redAccent : AppColors.voidBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isInstalled ? 'DISABLE' : 'INSTALL',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.electric : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.voidBg : AppColors.gunmetal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
