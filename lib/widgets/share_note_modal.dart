import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';
import 'glass_card.dart';
import '../core/models/user_model.dart';

class ShareNoteModal extends StatefulWidget {
  final String noteId;
  final String noteTitle;

  const ShareNoteModal({
    super.key,
    required this.noteId,
    required this.noteTitle,
  });

  @override
  State<ShareNoteModal> createState() => _ShareNoteModalState();
}

class _ShareNoteModalState extends State<ShareNoteModal> {
  final TextEditingController _searchController = TextEditingController();
  String _permission = 'read';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHARE NOTE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    widget.noteTitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gunmetal,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x, color: AppColors.gunmetal),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'INVITE COLLABORATORS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.gunmetal,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email address...',
                    hintStyle: GoogleFonts.inter(color: AppColors.carbon),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.electric),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildPermissionDropdown(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electric,
                foregroundColor: AppColors.voidBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'SEND INVITATION',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'CURRENT COLLABORATORS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.gunmetal,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildCollaboratorTile('Alex Rivers', 'alex@whisperr.io', 'admin'),
          _buildCollaboratorTile('Sarah Chen', 'sarah.c@nebula.net', 'write'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPermissionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButton<String>(
        value: _permission,
        underline: const SizedBox(),
        dropdownColor: AppColors.surface,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        items: const [
          DropdownMenuItem(value: 'read', child: Text('Read')),
          DropdownMenuItem(value: 'write', child: Text('Write')),
          DropdownMenuItem(value: 'admin', child: Text('Admin')),
        ],
        onChanged: (val) => setState(() => _permission = val!),
      ),
    );
  }

  Widget _buildCollaboratorTile(String name, String email, String permission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.electric.withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(color: AppColors.electric, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
                Text(
                  email,
                  style: GoogleFonts.inter(color: AppColors.gunmetal, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            permission.toUpperCase(),
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.electric.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.carbon),
        ],
      ),
    );
  }
}
