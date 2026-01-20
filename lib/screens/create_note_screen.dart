import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';

import '../widgets/glass_card.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isPublic = false;
  String _format = 'text'; // 'text' | 'doodle'
  List<String> _tags = [];
  bool _isLoading = false;

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Simulate API delay "Synthesizing"
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electric.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Input
                        _buildLabel('DESIGNATION'),
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titanium,
                            letterSpacing: -0.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title your thought...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                              color: AppColors.gunmetal.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        
                        const SizedBox(height: 32),

                        // Privacy Toggle
                        GlassCard(
                          opacity: 0.4,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VAULT STATUS',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gunmetal,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isPublic ? 'Publicly shared' : 'End-to-End Encrypted',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.titanium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isPublic,
                                onChanged: (val) => setState(() => _isPublic = val),
                                activeColor: AppColors.electric,
                                activeTrackColor: AppColors.electricDim,
                                inactiveThumbColor: AppColors.gunmetal,
                                inactiveTrackColor: AppColors.surface2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Content Area
                        _buildLabel('MANIFESTATION'),
                        
                        TextField(
                          controller: _contentController,
                          maxLines: null,
                          minLines: 12,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.titanium,
                            height: 1.7,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Transcribe your consciousness...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.gunmetal.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: AppColors.electric, width: 1.5),
                            ),
                            filled: true,
                            fillColor: AppColors.surface.withOpacity(0.3),
                            contentPadding: const EdgeInsets.all(24),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tags
                        _buildLabel('METADATA'),
                        GlassCard(
                          opacity: 0.3,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  style: GoogleFonts.inter(color: AppColors.titanium),
                                  decoration: InputDecoration(
                                    hintText: 'Add a tag...',
                                    hintStyle: GoogleFonts.inter(color: AppColors.gunmetal, fontSize: 14),
                                    isDense: true,
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  onSubmitted: (_) => _addTag(),
                                ),
                              ),
                              IconButton(
                                onPressed: _addTag,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surface2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(LucideIcons.plus, color: AppColors.electric, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.electricDim,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.electric.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.electric,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: const Icon(LucideIcons.x, size: 12, color: AppColors.electric),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                        
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Actions
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GlassCard(
              borderRadius: BorderRadius.zero,
              opacity: 0.9,
              border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildBottomAction(LucideIcons.image, () {}),
                      const SizedBox(width: 12),
                      _buildBottomAction(LucideIcons.mic, () {}),
                      const SizedBox(width: 12),
                      _buildBottomAction(LucideIcons.sparkles, () {}),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electric,
                      foregroundColor: AppColors.voidBg,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading 
                    ? const SizedBox(
                        width: 20, height: 20, 
                        child: CircularProgressIndicator(color: AppColors.voidBg, strokeWidth: 2)
                      )
                    : Text(
                        'PUBLISH',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 20, color: AppColors.gunmetal),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      borderRadius: BorderRadius.zero,
      opacity: 0.8,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Icon(LucideIcons.filePlus, color: AppColors.electric, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MANIFEST',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.electric,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'New Thought',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titanium,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, color: AppColors.gunmetal, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.gunmetal,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFormatToggle(String value, IconData icon) {
    final isSelected = _format == value;
    return GestureDetector(
      onTap: () => setState(() => _format = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electric : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon, 
          size: 18, 
          color: isSelected ? AppColors.voidBg : AppColors.gunmetal
        ),
      ),
    );
  }
}
