import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.titanium,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Syncing ',
                            style: GoogleFonts.inter(
                              color: AppColors.gunmetal,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '12',
                            style: GoogleFonts.inter(
                              color: AppColors.electric,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.spaceMono().fontFamily,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ' of ',
                            style: GoogleFonts.inter(
                              color: AppColors.gunmetal,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '142',
                            style: GoogleFonts.inter(
                              color: AppColors.titanium,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.spaceMono().fontFamily,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ' notes',
                            style: GoogleFonts.inter(
                              color: AppColors.gunmetal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.read<AuthProvider>().logout(),
                    icon: const Icon(LucideIcons.logOut, color: AppColors.gunmetal),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tags
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildTag('All', true),
                  _buildTag('Personal', false),
                  _buildTag('Work', false),
                  _buildTag('Ideas', false),
                  _buildTag('Journal', false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notes Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildNoteCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.electric,
        child: const Icon(LucideIcons.plus, color: AppColors.voidBg),
      ),
    );
  }

  Widget _buildTag(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.electric : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.electric : AppColors.borderSubtle,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isActive ? AppColors.voidBg : AppColors.titanium,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildNoteCard(int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Alpha',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.titanium,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Meeting notes regarding the new architecture deployment...',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.gunmetal,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Text(
            '2h ago',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.electric,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
