import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../controller/notes_controller.dart';

class AttachmentPicker extends StatelessWidget {
  final String noteId;

  const AttachmentPicker({super.key, required this.noteId});

  static const List<String> allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'txt', 'docx',
  ];

  static const Map<String, Map<String, dynamic>> fileTypeInfo = {
    'pdf': {'icon': Icons.picture_as_pdf_rounded, 'label': 'PDF', 'color': 0xFFE53935},
    'jpg': {'icon': Icons.image_rounded, 'label': 'JPG', 'color': 0xFF43A047},
    'jpeg': {'icon': Icons.image_rounded, 'label': 'JPEG', 'color': 0xFF43A047},
    'png': {'icon': Icons.image_rounded, 'label': 'PNG', 'color': 0xFF1E88E5},
    'txt': {'icon': Icons.description_rounded, 'label': 'TXT', 'color': 0xFFFB8C00},
    'docx': {'icon': Icons.article_rounded, 'label': 'DOCX', 'color': 0xFF5C6BC0},
  };

  static Future<void> show(BuildContext context, String noteId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AttachmentPicker(noteId: noteId),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final controller = Provider.of<NotesController>(context, listen: false);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.path != null) {
          final file = File(pickedFile.path!);
          await controller.addAttachment(noteId, file);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Attach File',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a file from your device',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),

              // Allowed types chips
              Text(
                'Supported formats',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fileTypeInfo.entries
                    .where((e) => e.key != 'jpeg') // Don't show duplicate
                    .map((entry) {
                  final info = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(info['color'] as int).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(info['color'] as int).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          info['icon'] as IconData,
                          size: 16,
                          color: Color(info['color'] as int),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          info['label'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(info['color'] as int),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Pick file button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => _pickFile(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'Browse Files',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
