import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/note_card.dart';
import '../core/providers/auth_provider.dart';
import 'create_note_screen.dart';

import '../widgets/glass_card.dart';

import 'focus_mode_screen.dart';
import '../core/theme/glass_route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Header (Replicating AppHeader.tsx with Glassmorphism)
            GlassCard(
              borderRadius: BorderRadius.zero,
              border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              opacity: 0.8,
              child: Row(
                children: [
                  // Logo Area
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(LucideIcons.feather, color: AppColors.electric, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Search Area
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        style: GoogleFonts.inter(color: AppColors.titanium, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search your second brain...',
                          hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                          filled: true,
                          fillColor: AppColors.surface.withOpacity(0.5),
                          prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.gunmetal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action Icons
                  _buildHeaderAction(LucideIcons.sparkles, () {
                    Navigator.push(
                      context,
                      GlassRoute(page: const focusModeScreen()),
                    );
                  }),
                  const SizedBox(width: 8),
                  // Profile/Account
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        GlassRoute(page: const SettingsScreen()),
                      );
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.electric,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.voidBg, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'U',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            color: AppColors.voidBg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tags / Filters
            Container(
              height: 60,
              decoration: const BoxDecoration(
                 border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                children: [
                  _buildTagChip('All Notes', true),
                  _buildTagChip('Recent', false),
                  _buildTagChip('Ideas', false),
                  _buildTagChip('Work', false),
                  _buildTagChip('Life', false),
                  _buildTagChip('Archive', false),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return NoteCard(
                    title: index == 0 ? 'Glass Monolith Design' : (index == 1 ? 'AI System Architecture' : ''),
                    content: index == 0 
                      ? 'The aesthetic is "Quiet Power." We do not shout. We operate in the void...'
                      : 'Modular integration of Google Gemini AI across the ecosystem apps...',
                    tags: index == 0 ? ['design', 'brand'] : (index == 1 ? ['ai', 'tech'] : []),
                    isPinned: index < 2,
                    isPublic: index == 2,
                    onTap: () {
                       Navigator.push(
                        context,
                        GlassRoute(page: const CreateNoteScreen()),
                      );
                    },
                    onLongPress: () {
                      _showContextMenu(context);
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 64, width: 64,
        decoration: BoxDecoration(
          color: AppColors.electric,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.electric.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              GlassRoute(page: const CreateNoteScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(LucideIcons.plus, color: AppColors.voidBg, size: 32),
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 16, color: AppColors.electric),
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.electric : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.electric : AppColors.borderSubtle
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? AppColors.voidBg : AppColors.gunmetal,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.voidBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACCOUNT', style: GoogleFonts.spaceMono(color: AppColors.gunmetal, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.logOut, color: Colors.red),
              title: Text('Sign Out', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () {
                 Navigator.pop(context);
                 context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          children: [
            _buildContextItem(LucideIcons.pin, 'Pin Note'),
            _buildContextItem(LucideIcons.share2, 'Share'),
            _buildContextItem(LucideIcons.copy, 'Duplicate'),
            const Divider(color: AppColors.borderSubtle, height: 32),
            _buildContextItem(LucideIcons.trash2, 'Delete', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildContextItem(IconData icon, String label, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.titanium),
      title: Text(
        label, 
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.red : AppColors.titanium,
          fontWeight: FontWeight.w600
        )
      ),
      onTap: () {},
    );
  }
}
