import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/video_player_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class FilePreviewPage extends StatefulWidget {
  const FilePreviewPage({
    super.key,
    this.file,
    this.fileUrl,
    this.fileId,
    required this.fileName,
    required this.fileExtension,
    this.files, // List of files for carousel
    this.title, // Optional title override
  });

  final File? file;
  final String? fileUrl;
  final String? fileId;
  final String fileName;
  final String fileExtension;
  final List<dynamic>? files; // Expecting List<TicketAttachmentEntity>
  final String? title;

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  bool _isLoading = false;
  String? _resolvedUrl;
  String? _resolvedExtension;
  String? _errorMessage;
  int _currentCarouselIndex = 0;
  bool _isZoomed = false; // Add state to track if we are zoomed in

  @override
  void initState() {
    super.initState();
    // If fileId is provided and no direct URL/file, fetch the view URL
    if (widget.fileId != null &&
        widget.file == null &&
        widget.fileUrl == null) {
      _fetchViewUrl();
    }
  }

  Future<void> _fetchViewUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl<TicketRepository>().getFileViewUrl(widget.fileId!);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (fileViewUrlResult) {
        setState(() {
          _isLoading = false;
          _resolvedUrl = fileViewUrlResult.url;
          // Use extension from API response if widget doesn't have one
          if (widget.fileExtension.isEmpty) {
            _resolvedExtension = fileViewUrlResult.fileExtension;
          }
        });
      },
    );
  }

  String get _effectiveExtension => (_resolvedExtension ?? widget.fileExtension)
      .toLowerCase()
      .replaceAll('.', '');

  String? get _effectiveUrl => _resolvedUrl ?? widget.fileUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: widget.title ?? l10n.preview,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        widget.files != null && widget.files!.isNotEmpty
                            ? _buildCarouselContent(context)
                            : _buildContent(context),
                  ),
                ),
              ),
            ),
            if (widget.files != null && widget.files!.length > 1)
              _buildCarouselIndicator(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.kPrimaryColor, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 15.h,
                    ),
                  ),
                  child: Text(
                    l10n.close,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
                      color: AppColor.kPrimaryColor,
                      fontFamily: 'General Sans',
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

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(context, _errorMessage!);
    }

    // Single item
    return SmartFileViewer(
      fileId: widget.fileId,
      url: _effectiveUrl,
      file: widget.file,
      extension: _effectiveExtension,
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 12.h),
            Text(
              'Failed to load preview',
              style: TextStyle(
                color: Color(0xFF67697A),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'General Sans',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                color: Color(0xFF67697A),
                fontSize: 13.sp,
                fontFamily: 'General Sans',
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: _fetchViewUrl,
              icon: Icon(Icons.refresh, size: 18.sp),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselContent(BuildContext context) {
    if (widget.files == null || widget.files!.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CarouselSlider.builder(
          itemCount: widget.files!.length,
          itemBuilder: (context, index, realIndex) {
            final attachment = widget.files![index];
            final type = attachment.fileType.toString().toUpperCase();
            String ext = 'jpg';
            if (type == 'VIDEO') ext = 'mp4';
            if (type == 'PDF' || type == 'DOCUMENT') ext = 'pdf';

            final hasLocalPath = attachment.filePath.isNotEmpty;
            return SmartFileViewer(
              fileId: attachment.fileId,
              url: attachment.fileUrl.isNotEmpty ? attachment.fileUrl : null,
              file: hasLocalPath ? File(attachment.filePath) : null,
              extension: ext,
              onZoomStateChanged: (isZoomed) {
                if (_isZoomed != isZoomed) {
                  setState(() {
                    _isZoomed = isZoomed;
                  });
                }
              },
            );
          },
          options: CarouselOptions(
            height: constraints.maxHeight, // Match parent height dynamically
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            scrollPhysics:
                _isZoomed
                    ? const NeverScrollableScrollPhysics() // Lock swipe when zoomed
                    : const AlwaysScrollableScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCarouselIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            widget.files!.asMap().entries.map((entry) {
              return Container(
                width: 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.kPrimaryColor.withOpacity(
                    _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// A smart widget that handles loading a file either locally, via URL, or via fileId.
class SmartFileViewer extends StatefulWidget {
  final String? fileId;
  final String? url;
  final File? file;
  final String extension;
  final ValueChanged<bool>? onZoomStateChanged;

  const SmartFileViewer({
    super.key,
    this.fileId,
    this.url,
    this.file,
    required this.extension,
    this.onZoomStateChanged,
  });

  @override
  State<SmartFileViewer> createState() => _SmartFileViewerState();
}

class _SmartFileViewerState extends State<SmartFileViewer> {
  bool _isLoading = false;
  String? _resolvedUrl;
  String? _resolvedExtension;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.fileId != null && widget.file == null && widget.url == null) {
      _fetchViewUrl();
    }
  }

  Future<void> _fetchViewUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl<TicketRepository>().getFileViewUrl(widget.fileId!);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (fileViewUrlResult) {
        setState(() {
          _isLoading = false;
          _resolvedUrl = fileViewUrlResult.url;
          if (widget.extension.isEmpty) {
            _resolvedExtension = fileViewUrlResult.fileExtension;
          }
        });
      },
    );
  }

  String get _effectiveExtension => (_resolvedExtension ?? widget.extension)
      .toLowerCase()
      .replaceAll('.', '');

  String? get _effectiveUrl => _resolvedUrl ?? widget.url;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 12.h),
            Text(
              _errorMessage ?? 'Failed to load preview',
              style: TextStyle(
                color: Color(0xFF67697A),
                fontSize: 13.sp,
                fontFamily: 'General Sans',
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: _fetchViewUrl,
              icon: Icon(Icons.refresh, size: 18.sp),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.kPrimaryColor,
              ),
            ),
          ],
        ),
      );
    }

    final l10n = context.bssSubL10n;
    final extension = _effectiveExtension;
    final url = _effectiveUrl;

    if (extension == 'pdf') {
      if (widget.file != null) {
        return PDFView(
          filePath: widget.file!.path,
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
              Icon(Icons.picture_as_pdf, size: 64.sp, color: Color(0xFFD32F2F)),
              SizedBox(height: 16.h),
              Text(
                'Document Preview',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.open_in_new, size: 18.sp, color: Colors.white),
                label: const Text(
                  'View PDF Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'General Sans',
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
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      if (url != null) {
        return PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          scaleStateChangedCallback: (state) {
            final isZoomed = state != PhotoViewScaleState.initial;
            widget.onZoomStateChanged?.call(isZoomed);
          },
          loadingBuilder:
              (context, event) => Center(
                child: CircularProgressIndicator(
                  value:
                      event == null || event.expectedTotalBytes == null
                          ? null
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                ),
              ),
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.broken_image, size: 48.sp, color: Colors.grey),
            );
          },
        );
      } else if (widget.file != null) {
        return PhotoView(
          imageProvider: FileImage(widget.file!),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          scaleStateChangedCallback: (state) {
            final isZoomed = state != PhotoViewScaleState.initial;
            widget.onZoomStateChanged?.call(isZoomed);
          },
          errorBuilder: (errorContext, error, stackTrace) {
            return Center(
              child: Icon(Icons.broken_image, size: 48.sp, color: Colors.grey),
            );
          },
        );
      }
    } else if (extension == 'mp4') {
      if (url != null) {
        return VideoPlayerWidget(videoUrl: url);
      } else if (widget.file != null) {
        return VideoPlayerWidget(videoFile: widget.file);
      }
    }

    return Center(
      child: Text(
        l10n.previewNotAvailable,
        style: TextStyle(
          color: Color(0xFF67697A),
          fontSize: 14.sp,
          fontFamily: 'General Sans',
        ),
      ),
    );
  }
}
