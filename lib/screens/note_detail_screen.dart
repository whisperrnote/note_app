import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/models/note_model.dart';
import '../core/services/notes_service.dart';
import '../core/providers/auth_provider.dart';
import 'doodle_canvas_screen.dart';
import '../core/theme/glass_route.dart';
import '../core/theme/doodle_painter.dart';
import '../core/models/user_model.dart';
import '../widgets/share_note_modal.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _doodleData;
  List<String> _attachmentIds = [];
  List<String> _collaboratorIds = [];
  List<UserModel> _collaborators = [];
  final NotesService _notesService = NotesService();
  bool _isEditing = false;
  bool _isLoading = false;
  StreamSubscription? _commentsSubscription;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _doodleData = widget.note.doodleData;
    _attachmentIds = List.from(widget.note.attachmentIds);
    _collaboratorIds = List.from(widget.note.collaboratorIds);
    _fetchCollaboratorProfiles();
    _initRealtimeComments();
  }

  void _initRealtimeComments() {
    _commentsSubscription = _notesService
        .subscribeToComments(widget.note.id)
        .stream
        .listen((event) {
          if (mounted) setState(() {});
        });
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchCollaboratorProfiles() async {
    final profiles = <UserModel>[];
    for (var id in _collaboratorIds) {
      final user = await _notesService.getUserById(id);
      if (user != null) profiles.add(user);
    }
    if (mounted) setState(() => _collaborators = profiles);
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await _notesService.updateNote(
        noteId: widget.note.id,
        title: _titleController.text,
        content: _contentController.text,
        doodleData: _doodleData,
        attachmentIds: _attachmentIds,
        collaboratorIds: _collaboratorIds,
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
    return Hero(
      tag: 'note_${widget.note.title}_${widget.note.content.hashCode}',
      child: Scaffold(
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
                        RepaintBoundary(child: _buildDoodleSection()),
                        const SizedBox(height: 12),
                        _buildAttachmentSection(),
                        const SizedBox(height: 12),
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ShareNoteModal(
                  noteId: widget.note.id,
                  noteTitle: widget.note.title,
                ),
              );
            },
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
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.note.isPinned)
          const Icon(LucideIcons.pin, size: 14, color: AppColors.electric),
        Text(
          'Last modified: Just now',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.gunmetal),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              GlassRoute(page: DoodleCanvasScreen(initialData: _doodleData)),
            );
            if (result != null) {
              setState(() => _doodleData = result as String);
              if (!_isEditing) _handleSave();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _doodleData != null
                  ? AppColors.electricDim
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _doodleData != null
                    ? AppColors.electric
                    : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.pencil,
                  size: 10,
                  color: _doodleData != null
                      ? AppColors.electric
                      : AppColors.gunmetal,
                ),
                const SizedBox(width: 4),
                Text(
                  _doodleData != null ? 'DOODLE ATTACHED' : 'ADD DOODLE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _doodleData != null
                        ? AppColors.electric
                        : AppColors.gunmetal,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildDoodleSection() {
    if (_doodleData == null) return const SizedBox.shrink();

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: DoodlePainter(doodleData: _doodleData!),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
              onPressed: () {
                setState(() => _doodleData = null);
                if (!_isEditing) _handleSave();
              },
            ),
          ),
          Positioned(
            bottom: 8,
            left: 12,
            child: Text(
              'DOODLE ATTACHMENT',
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                color: AppColors.gunmetal,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_attachmentIds.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _attachmentIds
                .map((id) => _buildAttachmentTile(id))
                .toList(),
          ),
        if (_attachmentIds.isNotEmpty) const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _pickAndUploadFile,
          icon: const Icon(
            LucideIcons.paperclip,
            size: 16,
            color: AppColors.electric,
          ),
          label: Text(
            'ATTACH FILE',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.electric,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentTile(String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.file, size: 14, color: AppColors.gunmetal),
          const SizedBox(width: 8),
          Text(
            'FILE ID: ${id.substring(0, 6)}',
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.titanium),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _attachmentIds.remove(id));
              if (!_isEditing) _handleSave();
            },
            child: const Icon(LucideIcons.x, size: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      try {
        final id = await _notesService.uploadAttachment(
          result.files.single.path!,
          result.files.single.name,
        );
        setState(() => _attachmentIds.add(id));
        if (!_isEditing) _handleSave();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
            ..._collaborators.map(
              (u) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _buildAvatar(u.name.substring(0, 1).toUpperCase()),
              ),
            ),
            const SizedBox(width: 8),
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
    return GestureDetector(
      onTap: _showCollaboratorSearch,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Icon(
          LucideIcons.plus,
          size: 14,
          color: AppColors.gunmetal,
        ),
      ),
    );
  }

  void _showCollaboratorSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CollaboratorSearchSheet(
        onUserSelected: (user) async {
          if (!_collaboratorIds.contains(user.id)) {
            setState(() {
              _collaboratorIds.add(user.id);
              _collaborators.add(user);
            });
            if (!_isEditing) await _handleSave();
          }
        },
      ),
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
        StreamBuilder(
          stream: Stream.fromFuture(_notesService.listComments(widget.note.id)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final comments = snapshot.data ?? [];
            if (comments.isEmpty) {
              return const Center(
                child: Text(
                  'No comments yet.',
                  style: TextStyle(color: AppColors.gunmetal, fontSize: 12),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(comment.userId.substring(0, 1).toUpperCase()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.content,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.titanium,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Just now',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.gunmetal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentInput() {
    final controller = TextEditingController();
    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.titanium),
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.send,
              size: 16,
              color: AppColors.electric,
            ),
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await _notesService.addComment(
                widget.note.id,
                auth.user!.$id,
                controller.text,
              );
              controller.clear();
              setState(() {}); // Refresh stream
            },
          ),
        ],
      ),
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

class _CollaboratorSearchSheet extends StatefulWidget {
  final Function(UserModel) onUserSelected;
  const _CollaboratorSearchSheet({required this.onUserSelected});

  @override
  State<_CollaboratorSearchSheet> createState() =>
      _CollaboratorSearchSheetState();
}

class _CollaboratorSearchSheetState extends State<_CollaboratorSearchSheet> {
  final NotesService _notesService = NotesService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _results = [];
  bool _isSearching = false;

  void _performSearch(String query) async {
    if (query.length < 2) return;
    setState(() => _isSearching = true);
    try {
      final users = await _notesService.searchUsers(query);
      setState(() => _results = users);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADD COLLABORATOR',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.electric,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            autofocus: true,
            style: GoogleFonts.inter(color: AppColors.titanium),
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search name or email...',
              hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
              filled: true,
              fillColor: AppColors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                LucideIcons.search,
                size: 16,
                color: AppColors.gunmetal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_results.isEmpty && _searchController.text.length >= 2)
            const Center(
              child: Text(
                'No users found.',
                style: TextStyle(color: AppColors.gunmetal),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final user = _results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.electric,
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppColors.voidBg),
                  ),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(color: AppColors.titanium),
                ),
                subtitle: Text(
                  user.email,
                  style: const TextStyle(color: AppColors.gunmetal),
                ),
                onTap: () {
                  widget.onUserSelected(user);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
