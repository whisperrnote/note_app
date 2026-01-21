import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';
import '../core/theme/doodle_painter.dart';
import 'glass_card.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final bool isPublic;
  final String? doodleData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.tags,
    this.isPinned = false,
    this.isPublic = false,
    this.doodleData,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: Hero(
        tag:
            'note_${title}_${content.hashCode}', // Unique tag based on content for hero
        child: RepaintBoundary(
          child: GlassCard(
            opacity: 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title.isEmpty ? 'Untitled' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titanium,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isPublic)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            LucideIcons.link,
                            size: 14,
                            color: AppColors.gunmetal,
                          ),
                        ),
                      if (isPinned)
                        Icon(
                          LucideIcons.pin,
                          size: 14,
                          color: AppColors.electric,
                        ),
                    ],
                  ),
                ),

                // Content Preview
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (doodleData != null) ...[
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: DoodlePainter(
                                doodleData: doodleData!,
                                strokeColor: AppColors.electric.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Expanded(
                          child: Text(
                            content,
                            maxLines: doodleData != null ? 3 : 6,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.titanium.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tags
                if (tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface2,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gunmetal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
