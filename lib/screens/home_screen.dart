import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/note_card.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/notes_service.dart';
import '../core/models/note_model.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';
import '../widgets/glass_card.dart';
import 'focus_mode_screen.dart';
import 'settings_screen.dart';
import '../core/theme/glass_route.dart';
import '../widgets/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final notes = await _notesService.listNotes(authProvider.user!.$id);
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _MobileHome(
            notes: _notes,
            isLoading: _isLoading,
            onRefresh: _fetchNotes,
          ),
          desktop: _DesktopHome(
            notes: _notes,
            isLoading: _isLoading,
            onRefresh: _fetchNotes,
          ),
        ),
      ),
      floatingActionButton: ResponsiveLayout.isDesktop(context)
          ? null
          : _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
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
        onPressed: () async {
          await Navigator.push(
            context,
            GlassRoute(page: const CreateNoteScreen()),
          );
          _fetchNotes();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(LucideIcons.plus, color: AppColors.voidBg, size: 32),
      ),
    );
  }
}

class _MobileHome extends StatelessWidget {
  final List<Note> notes;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _MobileHome({
    required this.notes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.electric,
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _HomeHeader(),
          _TagsSection(),
          Expanded(
            child: _NotesGrid(
              crossAxisCount: 2,
              notes: notes,
              isLoading: isLoading,
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHome extends StatelessWidget {
  final List<Note> notes;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _DesktopHome({
    required this.notes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DesktopSidebar(),
        const VerticalDivider(width: 1, color: AppColors.borderSubtle),
        Expanded(
          child: Column(
            children: [
              _HomeHeader(isDesktop: true, onRefresh: onRefresh),
              _TagsSection(),
              Expanded(
                child: _NotesGrid(
                  crossAxisCount: 3,
                  notes: notes,
                  isLoading: isLoading,
                  onRefresh: onRefresh,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.voidBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Icon(
                    LucideIcons.feather,
                    color: AppColors.electric,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'WhisperrNote',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.titanium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SidebarItem(
            icon: LucideIcons.home,
            label: 'All Notes',
            isActive: true,
          ),
          _SidebarItem(icon: LucideIcons.clock, label: 'Recent'),
          _SidebarItem(icon: LucideIcons.star, label: 'Favorites'),
          _SidebarItem(icon: LucideIcons.archive, label: 'Archive'),
          const Spacer(),
          _SidebarItem(icon: LucideIcons.settings, label: 'Settings'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.electric : AppColors.gunmetal,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? AppColors.titanium : AppColors.gunmetal,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final bool isDesktop;
  final Future<void> Function()? onRefresh;
  const _HomeHeader({this.isDesktop = false, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.zero,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      opacity: 0.8,
      child: Row(
        children: [
          if (!isDesktop) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(
                LucideIcons.feather,
                color: AppColors.electric,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                style: GoogleFonts.inter(
                  color: AppColors.titanium,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search your second brain...',
                  hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: AppColors.gunmetal,
                  ),
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
          if (isDesktop)
            _HeaderAction(LucideIcons.plus, () {
              Navigator.push(
                context,
                GlassRoute(page: const CreateNoteScreen()),
              );
            }, isPrimary: true),
          const SizedBox(width: 8),
          _HeaderAction(LucideIcons.sparkles, () {
            Navigator.push(context, GlassRoute(page: const focusModeScreen()));
          }),
          const SizedBox(width: 8),
          _ProfileIcon(),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HeaderAction(this.icon, this.onTap, {this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.electric : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? AppColors.electric : AppColors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? AppColors.voidBg : AppColors.electric,
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, GlassRoute(page: const SettingsScreen()));
      },
      child: Container(
        width: 36,
        height: 36,
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
    );
  }
}

class _TagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _TagChip('All Notes', true),
          _TagChip('Recent', false),
          _TagChip('Ideas', false),
          _TagChip('Work', false),
          _TagChip('Life', false),
          _TagChip('Archive', false),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TagChip(this.label, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.electric : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.electric : AppColors.borderSubtle,
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
}

class _NotesGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Note> notes;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _NotesGrid({
    required this.crossAxisCount,
    required this.notes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.electric),
      );
    }

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.ghost, size: 64, color: AppColors.gunmetal),
            const SizedBox(height: 16),
            Text(
              'No notes found in the void',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.gunmetal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
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
              onTap: () async {
                await Navigator.push(
                  context,
                  GlassRoute(page: NoteDetailScreen(note: note)),
                );
                onRefresh();
              },
              onLongPress: () {
                _showContextMenu(context, note);
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 50).ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }

  void _showContextMenu(BuildContext context, Note note) {
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
            _ContextItem(LucideIcons.pin, 'Pin Note'),
            _ContextItem(LucideIcons.share2, 'Share'),
            _ContextItem(LucideIcons.copy, 'Duplicate'),
            const Divider(color: AppColors.borderSubtle, height: 32),
            _ContextItem(LucideIcons.trash2, 'Delete', isDestructive: true),
          ],
        ),
      ),
    );
  }
}

class _ContextItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _ContextItem(this.icon, this.label, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.titanium,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.red : AppColors.titanium,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {},
    );
  }
}
