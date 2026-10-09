import 'dart:io';

import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart'; // Import TicketEntity
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/ticket_models.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/file_preview_page.dart'; // Import FilePreviewPage
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/tax_payer_types.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_rating_card.dart';

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

  /// Rating is offered only once the ticket is Closed or Resolved.
  bool get _canRateTicket {
    final status = widget.ticket.status.trim().toLowerCase();
    return status == 'closed' || status == 'resolved';
  }

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
  List<TicketMovementEntity> _sortedMovements() {
    final indexed = _movements.asMap().entries.toList()
      ..sort((a, b) {
        final left = a.value.createdDate;
        final right = b.value.createdDate;
        if (left != null && right != null) {
          final byDate = left.compareTo(right);
          if (byDate != 0) return byDate;
        } else if (left == null && right != null) {
          return 1;
        } else if (left != null && right == null) {
          return -1;
        }
        return a.key.compareTo(b.key);
      });
    return indexed.map((entry) => entry.value).toList();
  }
  @override
  Widget build(BuildContext context) {
    final List<TicketMessage> messages = [];
    final movements = _sortedMovements();
    for (int i = 0; i < movements.length; i++) {
      final movement = movements[i];
      final number = (messages.length + 1).toString().padLeft(2, '0');

      // If assignedToName matches the user who created the ticket, it's the partner
      final bool isMe =
          movement.assignedFromName == widget.ticket.createdByUser;
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
          senderName: movement.assignedFromName ?? 'Support',
          senderRole:
              movement.assignedFromDesignation ??
              movement.assignedFromSeatName ??
              AppBrand.appName,
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
        listenWhen:
            (previous, current) =>
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
            _dialogUtil.showCustomSnackbar(
              content: state.errorMessage,
              context: context,
            );
          }
        },
        child: CommonAppBar(
          onBackPressed: () => Navigator.pop(context, _hasNewNotes),
          title: 'Ticket ID #${widget.ticket.ticketId}',
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              children: [
                // Header Card
                // Design: 64 tall, radius 12, 16 blur black @ 6%, 12 padding.
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(color: AppColor.kCardShadow, blurRadius: 16),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ticket Icon — Design: 38 #F5F5F5 circle, 20 icon.
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.kIconBackground,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ticket.svg',
                            width: 20.w,
                            height: 20.w,
                            colorFilter: ColorFilter.mode(
                              AppColor.kPrimaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Title
                      Expanded(
                        child: Text(
                          widget.ticket.subject?.name ?? 'No Subject',
                          style: TextStyle(
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'GeneralSans',
                            height: 1.30,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Status Badge
                      Container(
                        height: 28.h,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ShapeDecoration(
                          color: _getStatusColor(
                            widget.ticket.status,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.w,
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
                        child: Center(
                          child: Text(
                            _getStatusText(widget.ticket.status),
                            style: TextStyle(
                              color: _getStatusColor(widget.ticket.status),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // GST and PAN Updation details (only when the API sends them)
                if (widget.ticket.gstinDetails != null) ...[
                  SizedBox(height: 16.h),
                  _GstinDetailsCard(
                    details: widget.ticket.gstinDetails!,
                    fallbackTypeName: widget.ticket.subject?.name ?? '',
                  ),
                ],
                SizedBox(height: 20.h),

                // Message Cards
                ...messages.map((message) => _buildMessageCard(message)),

                // Rate this ticket
                if (_canRateTicket) ...[
                  SizedBox(height: 8.h),
                  TicketRatingCard(
                    ticketUuid: widget.ticket.uuid,
                    ticketBloc: _ticketBloc,
                    initialRating: widget.ticket.rating,
                    initialComment: widget.ticket.ratingComment,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(TicketMessage message) {
    // Design: radius 8, 4 blur black @ 5%, no offset; 12 between cards.
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [BoxShadow(color: AppColor.kCardShadowDark, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Number Badge
          Container(
            width: 17.w,
            height: 17.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message.number,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(width: 10.w), // Gap configuration
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 40.w,
                      height: 40.w,
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
                          style: TextStyle(
                            color: Color(0xFFC2A060),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                    // Design: 16 between avatar and name.
                    SizedBox(width: 16.w),

                    // Name and Role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: TextStyle(
                              color: AppColor.kPrimaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            message.senderRole,
                            style: TextStyle(
                              color: Color(0xFF232F50),
                              fontSize: 10.sp,
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
                        style: TextStyle(
                          color: Color(0xFF232F4F),
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Message Text
                Text(
                  message.message,
                  style: GoogleFonts.figtree(
                    color: const Color(0xFF232F50),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 2.0, // 12 * 2.0 = 24px line height
                  ),
                ),
                SizedBox(height: 20.h),

                // Attachments + status: one line when it fits; Wrap only reflows on overflow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.attachments.isNotEmpty)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final images =
                                message.attachments
                                    .where(
                                      (a) =>
                                          a.fileType.toUpperCase() == 'IMAGE',
                                    )
                                    .toList();
                            final videos =
                                message.attachments
                                    .where(
                                      (a) =>
                                          a.fileType.toUpperCase() == 'VIDEO',
                                    )
                                    .toList();
                            final pdfs =
                                message.attachments
                                    .where(
                                      (a) =>
                                          a.fileType.toUpperCase() == 'PDF' ||
                                          a.fileType.toUpperCase() ==
                                              'DOCUMENT',
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
                                width: 24.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.kPrimaryColor,
                                    width: 1.w,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    iconAsset,
                                    // Design: 14 icon in a 24 chip.
                                    width: 14.w,
                                    height: 14.w,
                                    colorFilter: ColorFilter.mode(
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
                                        builder:
                                            (context) => FilePreviewPage(
                                              file:
                                                  hasLocal
                                                      ? File(a.filePath)
                                                      : null,
                                              fileUrl:
                                                  a.fileUrl.isNotEmpty
                                                      ? a.fileUrl
                                                      : null,
                                              fileId: a.fileId,
                                              fileName: label,
                                              fileExtension:
                                                  a.fileType.toUpperCase() ==
                                                          'VIDEO'
                                                      ? '.mp4'
                                                      : (a.fileType
                                                                  .toUpperCase() ==
                                                              'PDF' ||
                                                          a.fileType
                                                                  .toUpperCase() ==
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
                                        builder:
                                            (context) => FilePreviewPage(
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
                                  AppAssets.paperclip,
                                  images,
                                ),
                                buildAttachmentChip(
                                  'Document',
                                  AppAssets.paperclip,
                                  pdfs,
                                ),
                                buildAttachmentChip(
                                  'Video',
                                  AppAssets.video,
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
                      height: 24.h,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: ShapeDecoration(
                        color: _getStatusColor(message.status).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getStatusText(message.status),
                          style: TextStyle(
                            color: _getStatusColor(message.status),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
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

/// GST and PAN Updation values in a two-column grid, styled like the header
/// card. Empty values (e.g. optional legal / trade name) are skipped.
class _GstinDetailsCard extends StatelessWidget {
  final TicketGstinDetailsEntity details;
  final String fallbackTypeName;

  const _GstinDetailsCard({
    required this.details,
    required this.fallbackTypeName,
  });

  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final typeName =
        details.typeName.isNotEmpty ? details.typeName : fallbackTypeName;

    final items =
        <(String, String)>[
          (l10n.panNumberLabel, details.pan),
          (l10n.sacCodeLabel, details.sac),
          (l10n.ticketTypeLabel, typeName),
          (l10n.gstinLabel, details.gstin),
          (
            l10n.taxPayerTypeLabel,
            details.taxPayerType.isEmpty
                ? ''
                : taxPayerTypeLabel(l10n, details.taxPayerType),
          ),
          (l10n.serviceDescriptionLabel, details.serviceDescription),
          (l10n.legalBusinessName, details.legalName),
          (l10n.tradeName, details.tradeName),
        ].where((item) => item.$2.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _decoration,
      child: Column(
        spacing: 16.h,
        children: [
          for (var i = 0; i < items.length; i += 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.w,
              children: [
                Expanded(child: _GstinDetailItem(item: items[i])),
                Expanded(
                  child:
                      i + 1 < items.length
                          ? _GstinDetailItem(item: items[i + 1])
                          : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GstinDetailItem extends StatelessWidget {
  final (String, String) item;

  const _GstinDetailItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.h,
      children: [
        Text(
          item.$1.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            height: 1.3,
            color: AppColor.kLabelGrey,
            fontFamily: 'GeneralSans',
          ),
        ),
        Text(
          item.$2,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColor.kTextSecondaryDark,
            fontFamily: 'GeneralSans',
          ),
        ),
      ],
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
