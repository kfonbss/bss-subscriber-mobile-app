import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
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
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/file_preview_page.dart';
import 'package:kfon_subscriber/service_locator.dart';

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

  @override
  Widget build(BuildContext context) {
    // Construct messages from TicketEntity
    // 1. Main ticket remarks (as the first message)
    // 2. Movements (as subsequent messages)

    final List<TicketMessage> messages = [];

    // Add initial ticket as a message if remarks exist
    if (widget.ticket.remarks != null && widget.ticket.remarks!.isNotEmpty) {
      messages.add(
        TicketMessage(
          number: '01',
          senderName: widget.ticket.partnerName ?? 'You',
          senderRole: widget.ticket.customerType ?? 'Partner',
          dateTime: _formatDateTime(widget.ticket.submitDate),
          message: widget.ticket.remarks!,
          attachments: widget.ticket.attachments,
          status: widget.ticket.status,
          isMe: true,
        ),
      );
    }

    // Add movements (skip first if it duplicates the initial remarks)
    final movements = _movements;
    final int startIndex =
        (movements.isNotEmpty &&
                widget.ticket.remarks != null &&
                movements.first.note == widget.ticket.remarks)
            ? 1
            : 0;
    for (int i = startIndex; i < movements.length; i++) {
      final movement = movements[i];
      final number = (messages.length + 1).toString().padLeft(2, '0');

      // If assignedToName matches the user who created the ticket, it's the partner
      final bool isMe = movement.assignedToName == widget.ticket.createdByUser;

      final List<TicketAttachmentEntity> movementAttachments = [];
      for (final url in movement.imageUrl) {
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: url,
            filePath: '',
            fileType: 'IMAGE',
          ),
        );
      }
      for (final url in movement.videoUrl) {
        movementAttachments.add(
          TicketAttachmentEntity(
            id: '',
            fileUrl: url,
            filePath: '',
            fileType: 'VIDEO',
          ),
        );
      }
      messages.add(
        TicketMessage(
          number: number,
          senderName:
              isMe
                  ? (widget.ticket.partnerName ?? 'You')
                  : (movement.assignedToName ?? 'Support'),
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
        listenWhen:
            (previous, current) =>
                current is NoteSubmitted || current is OnError,
        listener: (context, state) {
          if (state is NoteSubmitted) {
            setState(() {
              _movements.add(
                TicketMovementEntity(
                  id: state.respoEntity.movementId,
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
              backgroundColor: const Color(0xFF1C8E52),
            );
          } else if (state is OnError) {
            _dialogUtil.showMessage(state.errorMessage, context);
          }
        },
        child: CommonAppBar(
          onBackPressed: () => Navigator.pop(context, _hasNewNotes),
          title: 'Ticket ID #${widget.ticket.ticketId}',
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAppModalBottomSheet(
                context: context,
                builder:
                    (context) => TicketNoteBottomSheet(
                      ticketBloc: _ticketBloc,
                      onSave: (note, visibility) {
                        _lastAddedNote = note;
                        _ticketBloc.add(
                          OnAddNote(
                            params: AddNoteReq(
                              ticketUuid: widget.ticket.uuid,
                              remarks: note,
                              status:
                                  widget.ticket.status
                                      .toUpperCase(), // Use current ticket status
                              visibility: visibility,
                            ),
                          ),
                        );
                      },
                    ),
              );
            },
            backgroundColor: AppColor.kPrimaryColor,
            child: const Icon(Icons.note_add_outlined, color: Colors.white),
          ),
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
            width: 40,
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              message.number,
              style: const TextStyle(
                color: AppColor.kTextSecondaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
              ),
            ),
          ),

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
                const SizedBox(height: 12),

                // Message Text
                Text(
                  message.message,
                  style: const TextStyle(
                    color: Color(0xFF232F50),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'GeneralSans',
                    height: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Attachments and Status Row
                Row(
                  children: [
                    // Attachments
                    if (message.attachments.isNotEmpty)
                      Builder(
                        builder: (context) {
                          final images =
                              message.attachments
                                  .where(
                                    (a) => a.fileType.toUpperCase() == 'IMAGE',
                                  )
                                  .toList();
                          final videos =
                              message.attachments
                                  .where(
                                    (a) => a.fileType.toUpperCase() == 'VIDEO',
                                  )
                                  .toList();
                          final pdfs =
                              message.attachments
                                  .where(
                                    (a) => a.fileType.toUpperCase() == 'PDF',
                                  )
                                  .toList();

                          Widget buildAttachmentChip(
                            String label,
                            String iconAsset,
                            List<TicketAttachmentEntity> files,
                          ) {
                            if (files.isEmpty) return const SizedBox.shrink();

                            Widget chip = Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.kPrimaryColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    iconAsset,
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      AppColor.kPrimaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        color: AppColor.kPrimaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'GeneralSans',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (files.length > 1) {
                              chip = Badge(
                                label: Text('${files.length}'),
                                offset: const Offset(-8, -4),
                                child: chip,
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                if (files.length == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FilePreviewPage(
                                            fileUrl:
                                                files.first.fileUrl.isNotEmpty
                                                    ? files.first.fileUrl
                                                    : null,
                                            fileId: files.first.fileId,
                                            fileName: label,
                                            fileExtension:
                                                files.first.fileType
                                                            .toUpperCase() ==
                                                        'VIDEO'
                                                    ? '.mp4'
                                                    : files.first.fileType
                                                            .toUpperCase() ==
                                                        'PDF'
                                                    ? '.pdf'
                                                    : '.jpg',
                                          ),
                                    ),
                                  );
                                } else {
                                  // Pass multiple files to file preview page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FilePreviewPage(
                                            files: files, // Pass all files
                                            title: '$label Previews',
                                            // Still require single parameters for backward compatibility or single files
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

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildAttachmentChip(
                                'Router Image',
                                'assets/images/Paperclip.svg',
                                images,
                              ),
                              buildAttachmentChip(
                                'Document',
                                'assets/images/Paperclip.svg', // or use typical pdf icon
                                pdfs,
                              ),
                              buildAttachmentChip(
                                'Video',
                                'assets/images/Video.svg',
                                videos,
                              ),
                            ],
                          );
                        },
                      ),

                    const Spacer(),

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
