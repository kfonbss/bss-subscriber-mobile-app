import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/ticket_models.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_note_bottom_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
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
  bool _hasNewNotes = false;

  static const _cardShadowColor = Color(0x08000000); // black @ 3% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: _cardShadowColor, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  late List<TicketMessage> _messages;
  // Pre-computed once — widget.ticket.status is immutable so these never change.
  late Color _headerStatusColor;
  late ShapeDecoration _headerStatusDecoration;
  late TextStyle _headerStatusTextStyle;

  @override
  void initState() {
    super.initState();
    _movements = List.from(widget.ticket.movements);
    _messages = _buildMessages();
    _headerStatusColor = _getStatusColor(widget.ticket.status);
    _headerStatusTextStyle = TextStyle(
      color: _headerStatusColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'GeneralSans',
    );
    _headerStatusDecoration = ShapeDecoration(
      color: _headerStatusColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: _headerStatusColor),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      shadows: const [
        BoxShadow(
          color: AppColor.kCardShadowDark,
          blurRadius: 3.80,
          offset: Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ticketBloc.close();
    super.dispose();
  }

  List<TicketMessage> _buildMessages() {
    final l10n = context.bssSubL10n;
    final List<TicketMessage> messages = [];

    if (widget.ticket.remarks != null && widget.ticket.remarks!.isNotEmpty) {
      messages.add(
        TicketMessage(
          number: '01',
          senderName: widget.ticket.partnerName ?? l10n.youSender,
          senderRole: widget.ticket.customerType ?? 'Partner',
          dateTime: _formatDateTime(widget.ticket.submitDate),
          message: widget.ticket.remarks!,
          attachments: widget.ticket.attachments,
          status: widget.ticket.status,
          isMe: true,
        ),
      );
    }

    final movements = _movements.toList()
      ..sort((a, b) {
        if (a.createdDate == null || b.createdDate == null) return 0;
        return a.createdDate!.compareTo(b.createdDate!);
      });

    final int startIndex =
        (movements.isNotEmpty &&
            widget.ticket.remarks != null &&
            movements.first.note == widget.ticket.remarks)
        ? 1
        : 0;

    for (int i = startIndex; i < movements.length; i++) {
      final movement = movements[i];
      final number = (messages.length + 1).toString().padLeft(2, '0');
      final isMe = movement.assignedToName == widget.ticket.createdByUser;

      final List<TicketAttachmentEntity> movementAttachments = [];
      for (final url in movement.imageUrl) {
        movementAttachments.add(TicketAttachmentEntity(
          id: '', fileUrl: url, filePath: '', fileType: 'IMAGE',
        ));
      }
      for (final url in movement.videoUrl) {
        movementAttachments.add(TicketAttachmentEntity(
          id: '', fileUrl: url, filePath: '', fileType: 'VIDEO',
        ));
      }

      messages.add(
        TicketMessage(
          number: number,
          senderName: isMe
              ? (widget.ticket.partnerName ?? l10n.youSender)
              : (movement.assignedToName ?? l10n.supportSender),
          senderRole: isMe ? (widget.ticket.customerType ?? 'Partner') : 'KFON',
          dateTime: _formatDateTime(movement.createdDate),
          message: movement.note ?? '',
          attachments: movementAttachments,
          status: movement.status,
          isMe: isMe,
        ),
      );
    }

    return messages;
  }

  Color _getStatusColor(String status) {
    final statusEnum = TicketStatus.fromString(status);
    switch (statusEnum) {
      case TicketStatus.open: return AppColor.kTicketOpenBlue;
      case TicketStatus.progress: return AppColor.kTicketProgressOrange;
      case TicketStatus.closed: return AppColor.kTicketClosedGreen;
      case TicketStatus.resolved: return AppColor.kPrimaryColor;
    }
  }

  String _getStatusText(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('EEE, dd-MM-yyyy  hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _hasNewNotes);
      },
      child: BlocListener<TicketBloc, TicketState>(
        bloc: _ticketBloc,
        listenWhen: (previous, current) =>
        current is NoteSubmitted || current is OnError,
        listener: (context, state) {
          if (state is NoteSubmitted) {
            setState(() {
              _movements.add(TicketMovementEntity(
                id: state.respoEntity.movementId,
                note: state.note,
                status: state.respoEntity.status,
                assignedToName: state.respoEntity.assignedToName,
                createdDate: DateTime.now(),
              ));
              _hasNewNotes = true;
              _messages = _buildMessages();
            });
            _dialogUtil.showCustomSnackbar(
              context: context,
              content: l10n.noteSavedSuccessfully,
              backgroundColor: AppColor.kTicketClosedGreen,
            );
          } else if (state is OnError) {
            _dialogUtil.showMessage(state.errorMessage, context);
          }
        },
        child: CommonAppBar(
          onBackPressed: () => Navigator.pop(context, _hasNewNotes),
          title: l10n.ticketIdTitle(widget.ticket.ticketId.toString()),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAppModalBottomSheet(
                context: context,
                builder: (context) => TicketNoteBottomSheet(
                  ticketBloc: _ticketBloc,
                  onSave: (note, visibility) {
                    _ticketBloc.add(
                      OnAddNote(
                        params: AddNoteReq(
                          ticketUuid: widget.ticket.uuid,
                          remarks: note,
                          status: widget.ticket.status.toUpperCase(),
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
                  decoration: _cardDecoration,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.kTicketDetailIconBg,
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
                      Expanded(
                        child: Text(
                          widget.ticket.subject?.name ?? l10n.noSubject,
                          style: const TextStyle(
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: _headerStatusDecoration,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _getStatusText(widget.ticket.status),
                              style: _headerStatusTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Message Cards — _MessageCard is a StatelessWidget so Flutter
                // can track identity and skip rebuilds for unchanged messages.
                for (final message in _messages)
                  _MessageCard(
                    key: ValueKey(message.number),
                    message: message,
                    getStatusColor: _getStatusColor,
                    getStatusText: _getStatusText,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

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
    required this.isMe,
  });
}

/// Extracted from the old `_buildMessageCard` helper method.
/// As a StatelessWidget, Flutter can track identity across setState calls
/// (e.g. when a new note is added) and skip rebuilding unchanged cards.
class _MessageCard extends StatelessWidget {
  final TicketMessage message;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusText;

  const _MessageCard({
    super.key,
    required this.message,
    required this.getStatusColor,
    required this.getStatusText,
  });

  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x08000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const _statusBadgeShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    // Computed once per build — not per attachment chip.
    final statusColor = getStatusColor(message.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const ShapeDecoration(
                        color: AppColor.kAvatarSandBg,
                        shape: OvalBorder(),
                      ),
                      child: Center(
                        child: Text(
                          (message.senderName.isNotEmpty
                                  ? message.senderName[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColor.kAvatarGoldText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: AppColor.kNavyBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      message.dateTime,
                      style: const TextStyle(
                        color: AppColor.kNavyBlue,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  message.message,
                  style: const TextStyle(
                    color: AppColor.kNavyBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'GeneralSans',
                    height: 2,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    if (message.attachments.isNotEmpty) ...() {
                        final images = message.attachments
                            .where((a) => a.fileType.toUpperCase() == 'IMAGE')
                            .toList();
                        final videos = message.attachments
                            .where((a) => a.fileType.toUpperCase() == 'VIDEO')
                            .toList();
                        final pdfs = message.attachments
                            .where((a) => a.fileType.toUpperCase() == 'PDF')
                            .toList();
                        return [
                          _AttachmentChip(
                            label: l10n.routerImage,
                            iconAsset: 'assets/images/Paperclip.svg',
                            files: images,
                          ),
                          _AttachmentChip(
                            label: l10n.document,
                            iconAsset: 'assets/images/Paperclip.svg',
                            files: pdfs,
                          ),
                          _AttachmentChip(
                            label: l10n.video,
                            iconAsset: 'assets/images/Video.svg',
                            files: videos,
                          ),
                        ];
                      }(),

                    const Spacer(),

                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: ShapeDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: _statusBadgeShape,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getStatusText(message.status),
                            style: TextStyle(
                              color: statusColor,
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

/// Extracted from the old `buildAttachmentChip` local function.
/// Local functions are re-defined on every builder invocation and cannot be
/// reconciled by the framework. A StatelessWidget with [super.key] lets Flutter
/// reuse the element when [label] and [files] are unchanged.
class _AttachmentChip extends StatelessWidget {
  final String label;
  final String iconAsset;
  final List<TicketAttachmentEntity> files;

  const _AttachmentChip({
    required this.label,
    required this.iconAsset,
    required this.files,
  });

  static const _chipDecoration = BoxDecoration(
    border: Border(
      top: BorderSide(color: AppColor.kPrimaryColor),
      bottom: BorderSide(color: AppColor.kPrimaryColor),
      left: BorderSide(color: AppColor.kPrimaryColor),
      right: BorderSide(color: AppColor.kPrimaryColor),
    ),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const _iconColorFilter =
      ColorFilter.mode(AppColor.kPrimaryColor, BlendMode.srcIn);

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    Widget chip = Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: _chipDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 14,
            height: 14,
            colorFilter: _iconColorFilter,
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
              builder: (context) => FilePreviewPage(
                fileUrl: files.first.fileUrl.isNotEmpty
                    ? files.first.fileUrl
                    : null,
                fileId: files.first.fileId,
                fileName: label,
                fileExtension:
                    files.first.fileType.toUpperCase() == 'VIDEO'
                        ? '.mp4'
                        : files.first.fileType.toUpperCase() == 'PDF'
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
}
