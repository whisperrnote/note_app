import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:signature/signature.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class DoodleCanvasScreen extends StatefulWidget {
  final String? initialData;
  const DoodleCanvasScreen({super.key, this.initialData});

  @override
  State<DoodleCanvasScreen> createState() => _DoodleCanvasScreenState();
}

class _DoodleCanvasScreenState extends State<DoodleCanvasScreen> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.electric,
      exportBackgroundColor: Colors.transparent,
      points: widget.initialData != null
          ? _parsePoints(widget.initialData!)
          : null,
    );
  }

  List<Point> _parsePoints(String data) {
    try {
      final List<dynamic> json = jsonDecode(data);
      return json
          .map(
            (p) => Point(
              Offset(p['x'].toDouble(), p['y'].toDouble()),
              PointType.values[p['type']],
              p['pressure']?.toDouble() ?? 1.0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  String _exportPoints() {
    final points = _controller.points
        .map(
          (p) => {
            'x': p.offset.dx,
            'y': p.offset.dy,
            'type': p.type.index,
            'pressure': p.pressure,
          },
        )
        .toList();
    return jsonEncode(points);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            _buildToolbar(),
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
              LucideIcons.x,
              color: AppColors.gunmetal,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'DOODLE CANVAS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.electric,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _exportPoints());
            },
            child: Text(
              'DONE',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: AppColors.electric,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToolbarAction(LucideIcons.undo2, () => _controller.undo()),
          const SizedBox(width: 12),
          _ToolbarAction(LucideIcons.rotateCcw, () => _controller.clear()),
          const SizedBox(width: 12),
          _ToolbarAction(LucideIcons.eraser, () {
            // Eraser logic could be implemented by switching pen color to transparent
            // but signature package doesn't support true erasing easily.
            // For now, we'll just toggle a "clear" mindset.
          }),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolbarAction(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 20, color: AppColors.titanium),
      ),
    );
  }
}
