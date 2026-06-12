import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
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
    await _service.saveToDownloads(file);
    DialogUtil().showCustomSnackbar(
      // ignore: use_build_context_synchronously
      context: context,
      content: 'PDF saved successfully',
    );
  }

  Future<void> downloadPdfFromUrl(BuildContext context, String url) async {
    await _service.downloadToDownloads(url);
    DialogUtil().showCustomSnackbar(
      // ignore: use_build_context_synchronously
      context: context,
      content: 'PDF saved successfully',
    );
  }
}