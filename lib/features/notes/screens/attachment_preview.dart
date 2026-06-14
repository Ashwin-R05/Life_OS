import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../models/attachment_model.dart';

class AttachmentPreview extends StatelessWidget {
  final AttachmentModel attachment;

  const AttachmentPreview({super.key, required this.attachment});

  IconData _getFileIcon() {
    switch (attachment.fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'docx':
        return Icons.article_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor() {
    switch (attachment.fileType.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'jpg':
      case 'jpeg':
        return const Color(0xFF43A047);
      case 'png':
        return const Color(0xFF1E88E5);
      case 'txt':
        return const Color(0xFFFB8C00);
      case 'docx':
        return const Color(0xFF5C6BC0);
      default:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileColor = _getFileColor();

    return Scaffold(
      body: Stack(
        children: [
          // Background blob
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fileColor.withValues(alpha: isDark ? 0.06 : 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // File info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: fileColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    attachment.fileType.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: fileColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  attachment.formattedSize,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.black.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Open externally button (for pdf/docx)
                      if (attachment.isExternalOpen)
                        GestureDetector(
                          onTap: () async {
                            await OpenFile.open(attachment.filePath);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Preview content
                Expanded(
                  child: _buildPreviewContent(context, theme, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(
      BuildContext context, ThemeData theme, bool isDark) {
    if (attachment.isImage) {
      return _buildImagePreview(theme, isDark);
    } else if (attachment.isText) {
      return _buildTextPreview(theme, isDark);
    } else {
      return _buildExternalPreview(context, theme, isDark);
    }
  }

  /// Image preview with interactive zoom
  Widget _buildImagePreview(ThemeData theme, bool isDark) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(attachment.filePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildErrorState(theme, isDark),
            ),
          ),
        ),
      ),
    );
  }

  /// Text file preview
  Widget _buildTextPreview(ThemeData theme, bool isDark) {
    return FutureBuilder<String>(
      future: File(attachment.filePath).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(theme, isDark);
        }

        final content = snapshot.data ?? '';
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: SelectableText(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.6,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      },
    );
  }

  /// External open preview (for PDF/DOCX)
  Widget _buildExternalPreview(
      BuildContext context, ThemeData theme, bool isDark) {
    final fileColor = _getFileColor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large file icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fileColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                _getFileIcon(),
                size: 48,
                color: fileColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              attachment.fileName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '${attachment.fileType.toUpperCase()} • ${attachment.formattedSize}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),

            // Open button
            GestureDetector(
              onTap: () async {
                await OpenFile.open(attachment.filePath);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fileColor,
                      fileColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: fileColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Open in External App',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'This file type requires an external viewer',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to preview file',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The file may be corrupted or missing',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
