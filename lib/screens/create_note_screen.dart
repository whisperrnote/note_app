import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';

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
                    AppColors.electric.withOpacity(0.15),
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titanium,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title your odyssey...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                              color: AppColors.gunmetal.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        
                        const SizedBox(height: 32),

                        // Privacy Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRIVACY MODE',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.titanium,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isPublic ? 'Publicly visible' : 'Vaulted session (Encrypted)',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.gunmetal,
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
                                inactiveTrackColor: AppColors.surface,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Content Area
                        _buildLabel('MANIFESTATION'),
                        
                        // Format Switcher
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFormatToggle('text', LucideIcons.fileText),
                              _buildFormatToggle('doodle', LucideIcons.pencil),
                            ],
                          ),
                        ),

                        if (_format == 'text')
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            minLines: 8,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.titanium,
                              height: 1.6,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Transcribe your consciousness...',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.gunmetal,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.borderSubtle),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.borderSubtle),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.electric),
                              ),
                              filled: true,
                              fillColor: AppColors.surface2,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          )
                        else
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.borderSubtle, 
                                style: BorderStyle.solid
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.electricDim,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.pencil, color: AppColors.electric, size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Canvas Mode',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: AppColors.titanium,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to open infinite canvas',
                                    style: GoogleFonts.inter(
                                      color: AppColors.gunmetal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Tags
                        _buildLabel('METADATA'),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                style: GoogleFonts.inter(color: AppColors.titanium),
                                decoration: InputDecoration(
                                  hintText: 'Add a tag...',
                                  hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                                  isDense: true,
                                  filled: true,
                                  fillColor: AppColors.surface2,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _addTag,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.electric,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(LucideIcons.plus, color: AppColors.voidBg),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) => Chip(
                            label: Text(tag),
                            labelStyle: GoogleFonts.spaceGrotesk(
                              color: AppColors.electric,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.electricDim,
                            side: const BorderSide(color: AppColors.electricDim),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onDeleted: () => _removeTag(tag),
                            deleteIcon: const Icon(LucideIcons.x, size: 14, color: AppColors.electric),
                          )).toList(),
                        ),
                        
                        const SizedBox(height: 100), // Spacing for safe area
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: AppColors.voidBg.withOpacity(0.9),
                border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
                backdropFilter: null, // Note: BackdropFilter is expensive in Flutter, using opacity for now
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'DISCARD',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.gunmetal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electric,
                      foregroundColor: AppColors.voidBg,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: AppColors.electric.withOpacity(0.5),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.electric, Color(0xFF00D1FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electric.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.filePlus, color: AppColors.voidBg, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Thought',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.titanium,
                  height: 1.1,
                ),
              ),
              Text(
                'Capture your brilliance',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.gunmetal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, color: AppColors.gunmetal),
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
