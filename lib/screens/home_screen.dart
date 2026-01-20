import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/note_card.dart';
import '../core/providers/auth_provider.dart';
import 'create_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Header (Replicating AppHeader.tsx)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
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
                  _buildHeaderAction(LucideIcons.sparkles, () {}),
                  const SizedBox(width: 8),
                  _buildHeaderAction(LucideIcons.layoutGrid, () {}),
                  const SizedBox(width: 8),
                  // Profile/Account
                  GestureDetector(
                    onTap: () => _showAccountMenu(context),
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
              height: 50,
              decoration: const BoxDecoration(
                 border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  _buildTagChip('All', true),
                  _buildTagChip('Ideas', false),
                  _buildTagChip('Work', false),
                  _buildTagChip('Life', false),
                  _buildTagChip('Projects', false),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return NoteCard(
                    title: index == 0 ? 'Project Alpha Specs' : (index == 1 ? 'Startup Ideas 2024' : ''),
                    content: 'This is a snippet of the note content. Ideally this would be rich text or a checklist preview...',
                    tags: index < 3 ? ['work', 'urgent'] : [],
                    isPinned: index < 2,
                    isPublic: index == 2,
                    onTap: () {
                       // Open detail/edit screen
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
                      );
                    },
                    onLongPress: () {
                      // Show context menu
                      _showContextMenu(context);
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        backgroundColor: AppColors.electric,
        child: const Icon(LucideIcons.plus, color: AppColors.voidBg),
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
