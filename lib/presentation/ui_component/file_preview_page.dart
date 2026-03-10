import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/video_player_widget.dart';

/// Reusable page for previewing a file (PDF, image, or video).
/// Used in ticket submission and CAF supporting documents.
class FilePreviewPage extends StatelessWidget {
  const FilePreviewPage({
    super.key,
    this.file,
    this.fileUrl,
    required this.fileName,
    required this.fileExtension,
  });

  final File? file;
  final String? fileUrl;
  final String fileName;
  final String fileExtension;

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Preview',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 343),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildFileContent(context),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.kPrimaryColor, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    'Close',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColor.kPrimaryColor,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    final extension = fileExtension.toLowerCase().replaceAll('.', '');

    // Handle PDF (requires local file)
    if (extension == 'pdf') {
      if (file != null) {
        return PDFView(
          filePath: file!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
        );
      } else {
        // TODO: Handle PDF from URL (need to download first or use a webview)
        return Center(
          child: Text(
            'PDF preview from URL not supported yet. Please download to view.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF67697A),
              fontSize: 14,
              fontFamily: 'GeneralSans',
            ),
          ),
        );
      }
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      if (fileUrl != null) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            fileUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Error loading image',
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              );
            },
          ),
        );
      } else if (file != null) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            file!,
            fit: BoxFit.contain,
            errorBuilder: (errorContext, error, stackTrace) {
              return Center(
                child: Text(
                  'Error loading image',
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              );
            },
          ),
        );
      }
    } else if (extension == 'mp4') {
      if (fileUrl != null) {
        return VideoPlayerWidget(videoUrl: fileUrl);
      } else if (file != null) {
        return VideoPlayerWidget(videoFile: file);
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Preview not available for this file type',
          style: const TextStyle(
            color: Color(0xFF67697A),
            fontSize: 14,
            fontFamily: 'GeneralSans',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
