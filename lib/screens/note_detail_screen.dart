import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/models/note_model.dart';
import '../core/services/notes_service.dart';
import '../core/providers/auth_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final NotesService _notesService = NotesService();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await _notesService.updateNote(
        noteId: widget.note.id,
        title: _titleController.text,
        content: _contentController.text,
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_isEditing) ...[
                        _buildLabel('DESIGNATION'),
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titanium,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title...',
                          ),
                        ),
                      ] else
                        Text(
                          _titleController.text,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titanium,
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildMetaRow(),
                      const SizedBox(height: 32),
                      _buildContentSection(),
                      const SizedBox(height: 40),
                      if (!_isEditing) _buildCollaborationSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: _isLoading ? null : _handleSave,
                backgroundColor: AppColors.electric,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.voidBg,
                        ),
                      )
                    : const Icon(LucideIcons.save, color: AppColors.voidBg),
                label: Text(
                  'SAVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: AppColors.voidBg,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      borderRadius: BorderRadius.zero,
      opacity: 0.8,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.gunmetal,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isEditing ? LucideIcons.eye : LucideIcons.edit3,
              color: AppColors.electric,
              size: 20,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.share2,
              color: AppColors.gunmetal,
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppColors.gunmetal,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 8,
      children: [
        if (widget.note.isPinned)
          const Icon(LucideIcons.pin, size: 14, color: AppColors.electric),
        Text(
          'Last modified: Just now',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.gunmetal),
        ),
        const SizedBox(width: 8),
        ...widget.note.tags.map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              tag.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.gunmetal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    if (_isEditing) {
      return TextField(
        controller: _contentController,
        maxLines: null,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.titanium,
          height: 1.6,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start writing...',
        ),
      );
    }
    return Text(
      _contentController.text,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.titanium,
        height: 1.6,
      ),
    );
  }

  Widget _buildCollaborationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.borderSubtle),
        const SizedBox(height: 24),
        Text(
          'COLLABORATORS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.gunmetal,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAvatar('U'),
            const SizedBox(width: -8),
            _buildAvatar('A', color: Colors.purple),
            const SizedBox(width: 12),
            _buildAddCollaborator(),
          ],
        ),
        const SizedBox(height: 32),
        _buildCommentsSection(),
      ],
    );
  }

  Widget _buildAvatar(String label, {Color color = AppColors.electric}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.voidBg, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.voidBg,
          ),
        ),
      ),
    );
  }

  Widget _buildAddCollaborator() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Icon(LucideIcons.plus, size: 14, color: AppColors.gunmetal),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMENTS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.gunmetal,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No comments yet.',
            style: TextStyle(color: AppColors.gunmetal, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.gunmetal,
        letterSpacing: 2,
      ),
    );
  }
}
