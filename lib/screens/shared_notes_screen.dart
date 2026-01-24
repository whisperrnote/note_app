import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/note_card.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/notes_service.dart';
import '../core/models/note_model.dart';
import '../core/theme/glass_route.dart';
import 'note_detail_screen.dart';

class SharedNotesScreen extends StatefulWidget {
  const SharedNotesScreen({super.key});

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  final NotesService _notesService = NotesService();
  List<Note> _sharedNotes = [];
  List<Note> _publicNotes = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0: Shared with me, 1: My Public Notes

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final userId = authProvider.user!.$id;
        final results = await Future.wait([
          _notesService.getSharedNotes(userId),
          _notesService.listPublicNotesByUser(userId),
        ]);
        if (mounted) {
          setState(() {
            _sharedNotes = results[0];
            _publicNotes = results[1];
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNotes = _activeTab == 0 ? _sharedNotes : _publicNotes;

    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tabs
            _buildTabs(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.electric))
                  : currentNotes.isEmpty
                      ? _buildEmptyState()
                      : _buildNotesGrid(currentNotes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SHARED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Icon(LucideIcons.search, color: AppColors.gunmetal, size: 20),
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
            label: 'Private (${_sharedNotes.length})',
            icon: LucideIcons.user,
            isActive: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          _TabItem(
            label: 'Public (${_publicNotes.length})',
            icon: LucideIcons.globe,
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
              _activeTab == 0 ? LucideIcons.user : LucideIcons.globe,
              size: 40,
              color: AppColors.gunmetal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _activeTab == 0 ? 'No private shared notes yet' : 'No public notes yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _activeTab == 0
                  ? "When others share notes with you, they'll appear here."
                  : "When you make your notes public, they'll appear here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.gunmetal,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNotesGrid(List<Note> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          title: note.title,
          content: note.content,
          tags: note.tags,
          isPinned: note.isPinned,
          isPublic: note.isPublic,
          doodleData: note.doodleData,
          updatedAt: note.updatedAt,
          onTap: () => Navigator.push(
            context,
            GlassRoute(page: NoteDetailScreen(note: note)),
          ),
          onLongPress: () {},
        ).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.voidBg : AppColors.gunmetal,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.voidBg : AppColors.gunmetal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
