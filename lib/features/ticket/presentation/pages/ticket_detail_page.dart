import 'dart:io';

import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart'; // Import TicketEntity
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/ticket_models.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_note_bottom_sheet.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/file_preview_page.dart'; // Import FilePreviewPage
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TicketDetailPage extends StatefulWidget {
  final TicketEntity ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TicketBloc _ticketBloc = TicketBloc(
    ticketRepository: sl<TicketRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  late List<TicketMovementEntity> _movements;
  String? _lastAddedNote;
  bool _hasNewNotes = false;

  /// Files picked for the in-flight add-note request; tied to the new movement id on success.
  List<PlatformFile>? _pendingNoteFiles;

  /// URLs for a just-created movement are only present after a full ticket refetch; keep local paths for immediate UI.
  final Map<String, List<TicketAttachmentEntity>>
  _localAttachmentsByMovementId = {};

  @override
  void initState() {
    super.initState();
    _movements = List.from(widget.ticket.movements);
  }

  // Helper to map String status to TicketStatus enum for UI colors
  TicketStatus _mapStatusToEnum(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'open') {
      return TicketStatus.open;
    } else if (lowerStatus == 'progress' || lowerStatus == 'in progress') {
      return TicketStatus.progress;
    } else if (lowerStatus == 'closed') {
      return TicketStatus.closed;
    } else if (lowerStatus == 'resolved') {
      return TicketStatus.resolved;
    } else {
      return TicketStatus.open; // Default
    }
  }

  Color _getStatusColor(String status) {
    final statusEnum = _mapStatusToEnum(status);
    switch (statusEnum) {
      case TicketStatus.open:
        return const Color(0xFF01889F);
      case TicketStatus.progress:
        return const Color(0xFFFA872D);
      case TicketStatus.closed:
        return const Color(0xFF1C8E52);
      case TicketStatus.resolved:
        return const Color(0xFF8D0247);
    }
  }

  String _getStatusText(String status) {
    // Capitalize first letter
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('EEE, dd-MM-yyyy  hh:mm a').format(dateTime);
  }

  /// API may send `""` for names; `name ?? fallback` keeps empty string, so avatars show "?".
  String _senderDisplayName(String? name, String fallback) {
    final t = name?.trim();
    if (t == null || t.isEmpty) return fallback;
    return t;
  }

  /// The API often returns movements newest-first. The opening note exists both as
  /// [TicketEntity.remarks] and as a movement with the same text/time as [submitDate].
  /// Skip that movement when we already render the remarks card — do not rely on
  /// `movements.first` matching remarks (newest-first breaks that check).
  bool _isDuplicateOfInitialRemarks({
    required TicketMovementEntity movement,
    required bool showingRemarksCard,
  }) {
    if (!showingRemarksCard) return false;
    final remarks = widget.ticket.remarks?.trim();
    final note = movement.note?.trim();
    if (remarks == null || remarks.isEmpty || note != remarks) return false;
    final submit = widget.ticket.submitDate;
    final created = movement.createdDate;
    if (submit == null || created == null) return note == remarks;
    return created.difference(submit).inSeconds.abs() <= 120;
  }

  List<TicketAttachmentEntity> _attachmentsFromPlatformFiles(
    List<PlatformFile> files,
  ) {
    final out = <TicketAttachmentEntity>[];
    for (final pf in files) {
      final path = pf.path;
      if (path == null || path.isEmpty) continue;
      final ext = (pf.extension ?? path.split('.').last).toLowerCase();
      late final String fileType;
      if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
        fileType = 'IMAGE';
      } else if (ext == 'mp4') {
        fileType = 'VIDEO';
      } else {
        fileType = 'PDF';
      }
      out.add(
        TicketAttachmentEntity(
          id: '',
          fileUrl: '',
          filePath: path,
          fileType: fileType,
        ),
      );
    }
    return out;
  }

  /// Root `attachments` lists every file on the ticket; movements scope files per note.
  /// Exclude fileIds that belong to other (non–initial-remarks) movements from the top card.
  Set<String> _fileIdsClaimedByNonInitialMovements({
    required bool showingRemarksCard,
  }) {
    final ids = <String>{};
    if (!showingRemarksCard) return ids;
    for (final movement in _movements) {
      if (_isDuplicateOfInitialRemarks(
        movement: movement,
        showingRemarksCard: showingRemarksCard,
      )) {
        continue;
      }
      ids.addAll(movement.imageFileIds);
      ids.addAll(movement.videoFileIds);
      ids.addAll(movement.documentFileIds);
    }
    return ids;
  }

  List<TicketAttachmentEntity> _attachmentsForRemarksCard({
    required bool showingRemarksCard,
  }) {
    if (!showingRemarksCard) return [];
    final claimed = _fileIdsClaimedByNonInitialMovements(
      showingRemarksCard: showingRemarksCard,
    );
    if (claimed.isEmpty) {
      return widget.ticket.attachments;
    }
    return widget.ticket.attachments.where((a) {
      final fid = a.fileId;
      if (fid == null || fid.isEmpty) return true;
      return !claimed.contains(fid);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Construct messages from TicketEntity
    // 1. Main ticket remarks (as the first message)
    // 2. Movements (as subsequent messages)

    final List<TicketMessage> messages = [];

    // Add initial ticket as a message if remarks exist
    final bool showingRemarksCard =
        widget.ticket.remarks != null && widget.ticket.remarks!.isNotEmpty;
    if (showingRemarksCard) {
      messages.add(
        TicketMessage(
          number: '01',
          senderName: _senderDisplayName(widget.ticket.partnerName, 'You'),
          senderRole: widget.ticket.customerType ?? 'Partner',
          dateTime: _formatDateTime(widget.ticket.submitDate),
          message: widget.ticket.remarks!,
          attachments: _attachmentsForRemarksCard(
            showingRemarksCard: showingRemarksCard,
          ),
          status: widget.ticket.status,
          isMe: true,
        ),
      );
    }

    // Add movements; skip any row that duplicates the remarks card (see [_isDuplicateOfInitialRemarks])
    final movements = _movements;
    for (int i = 0; i < movements.length; i++) {
      final movement = movements[i];
      if (_isDuplicateOfInitialRemarks(
        movement: movement,
        showingRemarksCard: showingRemarksCard,
      )) {
        continue;
      }
      final number = (messages.length + 1).toString().padLeft(2, '0');

      // If assignedToName matches the user who created the ticket, it's the partner
      final bool isMe = movement.assignedToName == widget.ticket.createdByUser;

      final List<TicketAttachmentEntity> movementAttachments = [];
      for (final fid in movement.imageFileIds) {
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: '',
            filePath: '',
            fileId: fid,
            movementId: movement.id,
            fileType: 'IMAGE',
          ),
        );
      }
      for (final url in movement.imageUrl) {
        if (url.isEmpty) continue;
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: url,
            filePath: '',
            movementId: movement.id,
            fileType: 'IMAGE',
          ),
        );
      }
      for (final fid in movement.videoFileIds) {
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: '',
            filePath: '',
            fileId: fid,
            movementId: movement.id,
            fileType: 'VIDEO',
          ),
        );
      }
      for (final url in movement.videoUrl) {
        if (url.isEmpty) continue;
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: url,
            filePath: '',
            movementId: movement.id,
            fileType: 'VIDEO',
          ),
        );
      }
      for (final fid in movement.documentFileIds) {
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: '',
            filePath: '',
            fileId: fid,
            movementId: movement.id,
            fileType: 'PDF',
          ),
        );
      }
      for (final url in movement.documentUrl) {
        if (url.isEmpty) continue;
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: url,
            filePath: '',
            movementId: movement.id,
            fileType: 'PDF',
          ),
        );
      }
      final locals = _localAttachmentsByMovementId[movement.id];
      if (locals != null && locals.isNotEmpty) {
        movementAttachments.addAll(locals);
      }
      messages.add(
        TicketMessage(
          number: number,
          senderName: isMe
              ? _senderDisplayName(widget.ticket.partnerName, 'You')
              : _senderDisplayName(movement.assignedToName, 'Support'),
          senderRole: isMe ? (widget.ticket.customerType ?? 'Partner') : 'KFON',
          dateTime: _formatDateTime(movement.createdDate),
          message: movement.note ?? '',
          attachments: movementAttachments,
          status: movement.status,
          isMe: isMe,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _hasNewNotes);
        }
      },
      child: BlocListener<TicketBloc, TicketState>(
        bloc: _ticketBloc,
        listenWhen: (previous, current) =>
            current is NoteSubmitted || current is OnError,
        listener: (context, state) {
          if (state is NoteSubmitted) {
            setState(() {
              final mid = state.respoEntity.movementId;
              final pending = _pendingNoteFiles;
              _pendingNoteFiles = null;
              if (pending != null && pending.isNotEmpty) {
                _localAttachmentsByMovementId[mid] =
                    _attachmentsFromPlatformFiles(pending);
              }
              _movements.add(
                TicketMovementEntity(
                  id: mid,
                  note: _lastAddedNote,
                  status: state.respoEntity.status,
                  assignedToName: state.respoEntity.assignedToName,
                  createdDate: DateTime.now(),
                ),
              );
              _lastAddedNote = null;
              _hasNewNotes = true;
            });
            _dialogUtil.showCustomSnackbar(
              context: context,
              content: 'Note saved successfully',
            );
          } else if (state is OnError) {
            _dialogUtil.showMessage(state.errorMessage, context);
          }
        },
        child: CommonAppBar(
          onBackPressed: () => Navigator.pop(context, _hasNewNotes),
          title: 'Ticket ID #${widget.ticket.ticketId}',
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ticket Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFF0F6),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ticket.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColor.kPrimaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          widget.ticket.subject?.name ?? 'No Subject',
                          style: const TextStyle(
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status Badge
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ShapeDecoration(
                          color: _getStatusColor(
                            widget.ticket.status,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _getStatusColor(widget.ticket.status),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0x0C000000),
                              blurRadius: 3.80,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _getStatusText(widget.ticket.status),
                              style: TextStyle(
                                color: _getStatusColor(widget.ticket.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Message Cards
                ...messages.map((message) => _buildMessageCard(message)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(TicketMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Number Badge
          Container(
            width: 17,
            height: 17,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message.number,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 10), // Gap configuration
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF3E2C8),
                        shape: OvalBorder(),
                      ),
                      child: Center(
                        child: Text(
                          (message.senderName.isNotEmpty
                                  ? message.senderName[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFC2A060),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name and Role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(
                              color: AppColor.kPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.senderRole,
                            style: const TextStyle(
                              color: Color(0xFF232F50),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date Time
                    Expanded(
                      flex: 0,
                      child: Text(
                        message.dateTime,
                        style: const TextStyle(
                          color: Color(0xFF232F4F),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Message Text
                Text(
                  message.message,
                  style: GoogleFonts.figtree(
                    color: const Color(0xFF232F50),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 2.0, // 12 * 2.0 = 24px line height
                  ),
                ),
                const SizedBox(height: 16),

                // Attachments + status: one line when it fits; Wrap only reflows on overflow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.attachments.isNotEmpty)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final images = message.attachments
                                .where(
                                  (a) => a.fileType.toUpperCase() == 'IMAGE',
                                )
                                .toList();
                            final videos = message.attachments
                                .where(
                                  (a) => a.fileType.toUpperCase() == 'VIDEO',
                                )
                                .toList();
                            final pdfs = message.attachments
                                .where(
                                  (a) =>
                                      a.fileType.toUpperCase() == 'PDF' ||
                                      a.fileType.toUpperCase() == 'DOCUMENT',
                                )
                                .toList();

                            Widget buildAttachmentChip(
                              String label,
                              String iconAsset,
                              List<TicketAttachmentEntity> files,
                            ) {
                              if (files.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              Widget chip = Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.kPrimaryColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    iconAsset,
                                    width: 16,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(
                                      AppColor.kPrimaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              );

                              if (files.length > 1) {
                                chip = Badge(
                                  label: Text('${files.length}'),
                                  offset: const Offset(1, -8),
                                  child: chip,
                                );
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (files.length == 1) {
                                    final a = files.first;
                                    final hasLocal = a.filePath.isNotEmpty;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FilePreviewPage(
                                          file: hasLocal
                                              ? File(a.filePath)
                                              : null,
                                          fileUrl: a.fileUrl.isNotEmpty
                                              ? a.fileUrl
                                              : null,
                                          fileId: a.fileId,
                                          fileName: label,
                                          fileExtension:
                                              a.fileType.toUpperCase() ==
                                                  'VIDEO'
                                              ? '.mp4'
                                              : (a.fileType.toUpperCase() ==
                                                        'PDF' ||
                                                    a.fileType.toUpperCase() ==
                                                        'DOCUMENT')
                                              ? '.pdf'
                                              : '.jpg',
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FilePreviewPage(
                                          files: files,
                                          title: '$label Previews',
                                          fileName: label,
                                          fileExtension: '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: chip,
                              );
                            }

                            return Wrap(
                              spacing: 0,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                buildAttachmentChip(
                                  'Router Image',
                                  'assets/icons/paperclip.svg',
                                  images,
                                ),
                                buildAttachmentChip(
                                  'Document',
                                  'assets/icons/paperclip.svg',
                                  pdfs,
                                ),
                                buildAttachmentChip(
                                  'Video',
                                  'assets/icons/video.svg',
                                  videos,
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    if (message.attachments.isEmpty) const Spacer(),

                    // Status Badge
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: ShapeDecoration(
                        color: _getStatusColor(message.status).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _getStatusText(message.status),
                            style: TextStyle(
                              color: _getStatusColor(message.status),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model for ticket messages
class TicketMessage {
  final String number;
  final String senderName;
  final String senderRole;
  final String dateTime;
  final String message;
  final List<TicketAttachmentEntity> attachments;
  final String status;
  final bool isMe;

  TicketMessage({
    required this.number,
    required this.senderName,
    required this.senderRole,
    required this.dateTime,
    required this.message,
    required this.attachments,
    required this.status,
    required this.isMe, // useful for styling if needed
  });
}
