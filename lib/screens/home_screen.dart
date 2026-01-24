import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/ui_kit/glass_card.dart';
import '../core/ui_kit/header_action.dart';
import '../core/ui_kit/profile_icon.dart';
import '../widgets/note_card.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/notes_service.dart';
import '../core/models/note_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/ecosystem_portal.dart';
import '../widgets/share_note_modal.dart';
import 'create_note_screen.dart';
import 'shared_notes_screen.dart';
import 'tags_screen.dart';
import 'extensions_screen.dart';
import 'note_detail_screen.dart';
import 'focus_mode_screen.dart';
import 'settings_screen.dart';
import '../core/theme/glass_route.dart';
import '../widgets/responsive_layout.dart';
import '../core/constants/app_constants.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;
  Note? _selectedNote;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    if (!AppConstants.useMockMode) {
      _initRealtime();
    }
  }

  void _initRealtime() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _realtimeSubscription = _notesService
          .subscribeToNotes(authProvider.user!.$id)
          .stream
          .listen((event) {
            _fetchNotes();
          });
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final notes = await _notesService.listNotes(authProvider.user!.$id);
        if (mounted) {
          setState(() {
            _notes = notes;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _NotesGrid(
          crossAxisCount: ResponsiveLayout.isDesktop(context) ? 3 : 2,
          notes: _notes,
          isLoading: _isLoading,
          onRefresh: _fetchNotes,
          onNoteSelected: (note) {
            if (ResponsiveLayout.isDesktop(context)) {
              setState(() => _selectedNote = note);
            } else {
              Navigator.push(
                context,
                GlassRoute(page: NoteDetailScreen(note: note)),
              ).then((_) => _fetchNotes());
            }
          },
        );
      case 1:
        return const SharedNotesScreen();
      case 2:
        return const TagsScreen();
      case 3:
        return const ExtensionsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Stack(
            children: [
              Column(
                children: [
                  if (_selectedIndex == 0) ...[
                    _HomeHeader(onRefresh: _fetchNotes),
                    _TagsSection(),
                  ],
                  Expanded(child: _buildBody()),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: WhisperrBottomNav(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
              ),
            ],
          ),
          desktop: Row(
            children: [
              _DesktopSidebar(
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _selectedNote = null;
                  });
                },
              ),
              const VerticalDivider(width: 1, color: AppColors.borderSubtle),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _HomeHeader(isDesktop: true, onRefresh: _fetchNotes),
                    if (_selectedIndex == 0) _TagsSection(),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
              if (_selectedNote != null) ...[
                const VerticalDivider(width: 1, color: AppColors.borderSubtle),
                Expanded(
                  flex: 4,
                  child: NoteDetailScreen(
                    key: ValueKey(_selectedNote!.id),
                    note: _selectedNote!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: ResponsiveLayout.isDesktop(context) || _selectedIndex != 0
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: _buildFAB(context),
            ),
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

class _ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ComingSoon({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.gunmetal),
          const SizedBox(height: 16),
          Text(
            '$title Coming Soon',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.gunmetal,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are porting this from the web platform...',
            style: GoogleFonts.inter(
              color: AppColors.carbon,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _DesktopSidebar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.voidBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Center(
                    child: Image.network(
                      'https://raw.githubusercontent.com/NathFavour/whisperr-assets/main/whisperrnote.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        LucideIcons.feather,
                        color: AppColors.electric,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: 'WHISPERR'),
                      TextSpan(
                        text: 'NOTE',
                        style: TextStyle(color: AppColors.electric),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'NAVIGATION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _SidebarItem(
            icon: LucideIcons.fileText,
            label: 'Notes',
            isActive: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _SidebarItem(
            icon: LucideIcons.link2,
            label: 'Shared Links',
            isActive: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _SidebarItem(
            icon: LucideIcons.tag,
            label: 'Tags',
            isActive: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _SidebarItem(
            icon: LucideIcons.puzzle,
            label: 'Extensions',
            isActive: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ECOSYSTEM PULSE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          'AR',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connect',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Alex sent a message',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.gunmetal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            onTap: () {
              // Handle settings
            },
          ),
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
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.electric.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive 
            ? Border.all(color: AppColors.electric.withOpacity(0.2))
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.electric : AppColors.gunmetal,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : AppColors.gunmetal,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.electric,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electric.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      opacity: 0.8,
      child: Row(
        children: [
          if (!isDesktop) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Center(
                child: Image.network(
                  'https://raw.githubusercontent.com/NathFavour/whisperr-assets/main/whisperrnote.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (_, __, ___) => const Icon(
                    LucideIcons.feather,
                    color: AppColors.electric,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                style: GoogleFonts.inter(
                  color: AppColors.titanium,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search your second brain...',
                  hintStyle: GoogleFonts.inter(color: AppColors.gunmetal, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 18,
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
          HeaderAction(
            icon: LucideIcons.sparkles,
            onTap: () {
              Navigator.push(
                context,
                GlassRoute(page: const focusModeScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          HeaderAction(
            icon: LucideIcons.layoutGrid,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const EcosystemPortal(),
              );
            },
          ),
          const SizedBox(width: 8),
          ProfileIcon(
            label: 'U',
            onTap: () {
              Navigator.push(context, GlassRoute(page: const SettingsScreen()));
            },
          ),
        ],
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.electric : AppColors.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? AppColors.voidBg : AppColors.gunmetal,
          fontWeight: FontWeight.w700,
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
  final Function(Note)? onNoteSelected;
  final NotesService _notesService = NotesService();

  _NotesGrid({
    required this.crossAxisCount,
    required this.notes,
    required this.isLoading,
    required this.onRefresh,
    this.onNoteSelected,
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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
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
              doodleData: note.doodleData,
              updatedAt: note.updatedAt,
              onShare: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ShareNoteModal(
                    noteId: note.id,
                    noteTitle: note.title,
                  ),
                );
              },
              onTap: () async {
                if (onNoteSelected != null) {
                  onNoteSelected!(note);
                } else {
                  await Navigator.push(
                    context,
                    GlassRoute(page: NoteDetailScreen(note: note)),
                  );
                  onRefresh();
                }
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
            _ContextItem(
              note.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
              note.isPinned ? 'Unpin Note' : 'Pin Note',
              onTap: () async {
                Navigator.pop(context);
                await _notesService.updateNote(
                  noteId: note.id,
                  isPinned: !note.isPinned,
                );
                onRefresh();
              },
            ),
            _ContextItem(LucideIcons.share2, 'Share'),
            _ContextItem(LucideIcons.copy, 'Duplicate'),
            const Divider(color: AppColors.borderSubtle, height: 32),
            _ContextItem(
              LucideIcons.trash2,
              'Delete',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                await _notesService.deleteNote(note.id);
                onRefresh();
              },
            ),
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
  final VoidCallback? onTap;

  const _ContextItem(
    this.icon,
    this.label, {
    this.isDestructive = false,
    this.onTap,
  });

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
      onTap: onTap,
    );
  }
}
