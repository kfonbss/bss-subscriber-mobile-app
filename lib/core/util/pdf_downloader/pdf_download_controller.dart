import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_download_service.dart';
import 'package:share_plus/share_plus.dart';

class PdfDownloadController {
  final PdfDownloadService _service = PdfDownloadService();

  Future<File> loadPdf(String url) {
    return _service.downloadToCache(url);
  }

  void sharePdf(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Invoice PDF');
  }

  Future<void> downloadPdf(BuildContext context, File file) async {
    final savedPath = await _service.saveToDownloads(file);

    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to $savedPath')));
  }
}
