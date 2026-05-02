import 'dart:io';

import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/attachment_list_widget.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/attachment_upload_field.dart';
import 'package:kfon_subscriber/shared/widgets/file_preview_page.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kTicketNoteMaxLength = 500;

class TicketNoteBottomSheet extends StatefulWidget {
  final void Function(
    String note,
    String visibility,
    List<PlatformFile>? files,
  ) onSave;
  final TicketBloc ticketBloc;

  const TicketNoteBottomSheet({
    super.key,
    required this.onSave,
    required this.ticketBloc,
  });

  @override
  State<TicketNoteBottomSheet> createState() => _TicketNoteBottomSheetState();
}

class _TicketNoteBottomSheetState extends State<TicketNoteBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  final DialogUtil _dialogUtil = DialogUtil();
  final List<PlatformFile> _selectedFiles = [];

  // Visibility is always 'EXTERNAL' — no user selection needed
  static const String _visibility = 'EXTERNAL';

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'jpg', 'jpeg', 'png', 'pdf', 'mp4'],
        allowMultiple: true,
      );

      if (result == null || !mounted) return;

      final l10n = context.bssSubL10n;
      var hasTooLargeFile = false;

      for (final file in result.files) {
        if (file.path != null) {
          if (file.size > 5 * 1024 * 1024) {
            hasTooLargeFile = true;
            continue;
          }

          if (!_selectedFiles.any((f) => f.path == file.path)) {
            _selectedFiles.add(file);
          }
        }
      }

      if (hasTooLargeFile) {
        _dialogUtil.showMessage(l10n.fileSizeMustBeLess, context);
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        final l10n = context.bssSubL10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorPickingFile(e.toString()))),
        );
      }
    }
  }

  void _viewFile(PlatformFile file) {
    if (file.path == null) return;

    final extension = file.extension ?? file.path!.split('.').last;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilePreviewPage(
          file: File(file.path!),
          fileName: file.name,
          fileExtension: extension,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final noteLen = _noteController.text.length;
    final trimmedLen = _noteController.text.trim().length;
    final isNoteValid =
        trimmedLen >= 10 && noteLen <= _kTicketNoteMaxLength;

    return BlocBuilder<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      buildWhen: (previous, current) =>
          current is NoteSubmitting || current is NoteSubmitted || current is OnError,
      builder: (context, state) {
        final isSubmitting = state is NoteSubmitting;
        if (state is NoteSubmitted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        final hasNoteError =
            _noteController.text.isNotEmpty && !isNoteValid;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add Note',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColor.kTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextPrimary,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasNoteError
                              ? const Color(0xFFBA1A1A)
                              : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        maxLength: _kTicketNoteMaxLength,
                        readOnly: isSubmitting,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Enter your note here...',
                          hintStyle: const TextStyle(
                            color: AppColor.kTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'GeneralSans',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '',
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.kTextPrimary,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ),
                    if (hasNoteError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Remarks must be at least 10 characters',
                          style: const TextStyle(
                            color: Color(0xFFBA1A1A),
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                AttachmentUploadField(
                  label: l10n.attachments,
                  onTap: isSubmitting ? () {} : _pickFile,
                ),
                const SizedBox(height: 12),
                AttachmentListWidget(
                  selectedFiles: _selectedFiles,
                  onViewFile: isSubmitting ? (_) {} : _viewFile,
                  onDeleteFile: isSubmitting
                      ? (_) {}
                      : (file) {
                          setState(() {
                            _selectedFiles.remove(file);
                          });
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ticketFileInstructions,
                  style: const TextStyle(
                    color: Color(0xFF67697A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: 'Save Note',
                  isLoading: isSubmitting,
                  borderRadius: 12,
                  onClicked: isSubmitting || !isNoteValid
                      ? null
                      : () {
                          widget.onSave(
                            _noteController.text.trim(),
                            _visibility,
                            _selectedFiles.isEmpty ? null : List.from(_selectedFiles),
                          );
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
