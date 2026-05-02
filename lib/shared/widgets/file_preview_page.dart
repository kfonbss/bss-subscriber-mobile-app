import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/video_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable page for previewing a file (PDF, image, or video).
/// Supports local files, direct URLs, and carousels of attachments.
/// Used in ticket submission and CAF supporting documents.
class FilePreviewPage extends StatefulWidget {
  const FilePreviewPage({
    super.key,
    this.file,
    this.fileUrl,
    this.fileId,
    required this.fileName,
    required this.fileExtension,
    this.files, // List of TicketAttachmentEntity for carousel
    this.title, // Optional title override
  });

  final File? file;
  final String? fileUrl;
  final String? fileId;
  final String fileName;
  final String fileExtension;
  final List<TicketAttachmentEntity>? files;
  final String? title;

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  int _currentCarouselIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: widget.title ?? 'Preview',
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
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          widget.files != null && widget.files!.isNotEmpty
                              ? _buildCarouselContent()
                              : _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.files != null && widget.files!.length > 1)
              _buildCarouselIndicator(),
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
                  child: const Text(
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

  Widget _buildContent() {
    return SmartFileViewer(
      url: widget.fileUrl,
      file: widget.file,
      fileId: widget.fileId,
      extension: widget.fileExtension,
    );
  }

  Widget _buildCarouselContent() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.files!.length,
      onPageChanged: (index) {
        setState(() {
          _currentCarouselIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final attachment = widget.files![index];
        final type = attachment.fileType.toUpperCase();
        String ext = 'jpg';
        if (type == 'VIDEO') ext = 'mp4';
        if (type == 'PDF') ext = 'pdf';

        return SmartFileViewer(
          fileId: attachment.fileId,
          url: attachment.fileUrl.isNotEmpty ? attachment.fileUrl : null,
          extension: ext,
        );
      },
    );
  }

  Widget _buildCarouselIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            widget.files!.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.kPrimaryColor.withValues(
                    alpha: _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// A smart widget that handles loading a file either locally or via URL.
class SmartFileViewer extends StatelessWidget {
  final String? url;
  final File? file;
  final String? fileId;
  final String extension;

  const SmartFileViewer({
    super.key,
    this.url,
    this.file,
    this.fileId,
    required this.extension,
  });

  String get _effectiveExtension => extension.toLowerCase().replaceAll('.', '');

  @override
  Widget build(BuildContext context) {
    final ext = _effectiveExtension;

    if (ext == 'pdf') {
      if (file != null) {
        return PDFView(
          filePath: file!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
        );
      } else if (url != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: AppColor.kStatusFailRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Document Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'View PDF Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      if (url != null) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image, size: 48, color: AppColor.kMediumGrey),
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
              return const Center(
                child: Icon(Icons.broken_image, size: 48, color: AppColor.kMediumGrey),
              );
            },
          ),
        );
      }
    } else if (ext == 'mp4') {
      if (url != null) {
        return VideoPlayerWidget(videoUrl: url);
      } else if (file != null) {
        return VideoPlayerWidget(videoFile: file);
      }
    }

    return const Center(
      child: Text(
        'Preview not available',
        style: TextStyle(
          color: AppColor.kSlateGrey,
          fontSize: 14,
          fontFamily: 'GeneralSans',
        ),
      ),
    );
  }
}
