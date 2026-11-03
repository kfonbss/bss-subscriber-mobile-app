import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/rate_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/customer_type_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// RailWire tickets only have a flat subject list and one optional attachment.
/// The create page still needs a category and customer type, so one fixed value
/// of each is returned; neither is sent to the API.
class RailwireTicketRepositoryImp extends TicketRepository {
  static const _attachmentLimitMessage = 'Only one attachment is supported';
  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'};
  static const _videoExtensions = {'mp4', 'mov', 'avi', 'mkv', '3gp'};

  @override
  Future<Either<Failure, List<TicketCategoryEntity>>> getCategories() async =>
      const Right([
        TicketCategoryEntity(
          id: 'GENERAL',
          code: 'GENERAL',
          name: 'General',
          nameInLocal: 'General',
          isActive: true,
        ),
      ]);

  @override
  Future<Either<Failure, List<CustomerTypeEntity>>> getCustomerTypes() async =>
      const Right([
        CustomerTypeEntity(
          id: 'SUBSCRIBERS',
          code: 'SUBSCRIBERS',
          name: 'Subscribers',
          isActive: true,
        ),
      ]);

  /// Subjects come with the state's images in `imagelogo`.
  @override
  Future<Either<Failure, List<SubjectEntity>>> getSubjects({
    required String categoryId,
  }) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireImageLogoURL,
      (session) => {'stcode': session.stateCode},
    );
    return result.map(
      (data) =>
          (data['ticket_subject_list'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()
              .map(
                (json) => SubjectEntity(
                  id: json['slno']?.toString() ?? '',
                  code: json['slno']?.toString() ?? '',
                  name: json['msg']?.toString().trim() ?? '',
                  escalationTime: '',
                  isActive: true,
                ),
              )
              .toList(),
    );
  }

  @override
  Future<Either<Failure, List<PriorityEntity>>> getPriorities() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<VisibilityEntity>>>
  getVisibilityPermissions() async => const Right([]);

  /// Attachments come back as direct URLs, so there is no file id to resolve.
  @override
  Future<Either<Failure, FileViewUrlResult>> getFileViewUrl(
    String fileId,
  ) async => Left(RailwireApi.unavailable);

  @override
  Future<Either<Failure, SubmitTicketRespoEntity>> submitTicket(
    SubmitTicketReq params,
  ) async {
    final files = params.files ?? const <PlatformFile>[];
    if (files.length > 1) {
      return const Left(ValidationFailure(_attachmentLimitMessage));
    }
    final attachment = files.firstOrNull;
    if (attachment != null && attachment.path == null) {
      return Left(ServerFailure(appL10n.selectedFileNotAvailable));
    }

    final encoded =
        attachment == null
            ? ''
            : base64Encode(await File(attachment.path!).readAsBytes());
    final result = await RailwireApi.post(
      ApiUrls.railwireCreateTicketURL,
      (session) => {
        ...session.byUsername,
        'subject': params.subjectId,
        'description': params.remarks,
        'attachment': encoded,
        'attachment_name': attachment?.name ?? '',
      },
    );
    return result.map((data) {
      // The new id is only in the text: "Ticket Created Successfully! Ticketid=25".
      final id =
          RegExp(
            r'Ticketid=(\d+)',
          ).firstMatch(data['Message']?.toString() ?? '')?.group(1) ??
          '';
      return SubmitTicketRespoEntity(
        ticketId: id,
        ticketUuid: id,
        status: 'open',
      );
    });
  }

  /// `create_new_comment` doesn't take attachments yet.
  @override
  Future<Either<Failure, AddNoteRespoEntity>> addNote(AddNoteReq params) async {
    if (params.files?.isNotEmpty ?? false) {
      return Left(RailwireApi.unavailable);
    }

    final result = await RailwireApi.post(
      ApiUrls.railwireCreateCommentURL,
      (session) => {
        ...session.byUsername,
        'ticketid': params.ticketUuid,
        'description': params.remarks,
      },
    );
    return result.map(
      (_) => AddNoteRespoEntity(
        movementId: DateTime.now().millisecondsSinceEpoch.toString(),
        ticketId: params.ticketUuid,
        status: params.status,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> rateTicket(RateTicketReq params) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireTicketFeedbackURL,
      (session) => {
        ...session.byUsername,
        'rating': params.rating.toString(),
        'feedback_msg': params.comment,
        'ticketid': params.ticketUuid,
      },
    );
    return result.map((_) => unit);
  }

  /// RailWire keeps open and closed tickets in two unpaged lists, so they're
  /// merged, filtered and paged here. Comments are only fetched for the
  /// returned page.
  @override
  Future<Either<Failure, TicketsListResponseEntity>> getTickets(
    GetTicketsListParams params,
  ) async {
    final status = params.status?.trim().toLowerCase() ?? '';
    final urls = [
      if (status != 'closed' && status != 'resolved')
        ApiUrls.railwireOpenTicketsURL,
      if (status != 'open') ApiUrls.railwireClosedTicketsURL,
    ];
    final results = await Future.wait(urls.map(_ticketList));

    final all = <Map<String, dynamic>>[];
    for (final result in results) {
      final failure = result.fold<Failure?>((l) => l, (r) {
        all.addAll(r);
        return null;
      });
      if (failure != null) return Left(failure);
    }

    final matching =
        all.where((json) => _matches(json, params)).toList()..sort(
          (a, b) => '${b['submit_date']}'.compareTo('${a['submit_date']}'),
        );
    final pageItems =
        matching.skip(params.page * params.size).take(params.size).toList();
    final tickets = await Future.wait(pageItems.map(_toTicket));

    final totalPages = (matching.length / params.size).ceil();
    return Right(
      TicketsListResponseEntity(
        tickets: tickets,
        pageInfo: PageInfoEntity(
          totalPages: totalPages,
          totalElements: matching.length,
          pageNumber: params.page,
          pageSize: params.size,
          isFirst: params.page == 0,
          isLast: (params.page + 1) >= totalPages,
          isEmpty: matching.isEmpty,
        ),
      ),
    );
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> _ticketList(
    String url,
  ) async {
    final result = await RailwireApi.post(
      url,
      (session) => {...session.byUsername, 'ticketid': ''},
    );
    return result.map(
      (data) =>
          (data['tickets_data'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>(),
    );
  }

  bool _matches(Map<String, dynamic> json, GetTicketsListParams params) {
    bool isSame(String? filter, String key) {
      final wanted = filter?.trim().toLowerCase() ?? '';
      return wanted.isEmpty || wanted == '${json[key]}'.trim().toLowerCase();
    }

    if (!isSame(params.status, 'status') ||
        !isSame(params.priority, 'priority')) {
      return false;
    }

    final search = params.search?.trim().toLowerCase() ?? '';
    if (search.isNotEmpty &&
        !'${json['ticketid']} ${json['subject']}'.toLowerCase().contains(
          search,
        )) {
      return false;
    }

    // Both are yyyy-MM-dd, so they compare as text.
    final submitted = '${json['submit_date']}'.split(' ').first;
    final from = params.createdDateFrom ?? '';
    final to = params.createdDateTo ?? '';
    return (from.isEmpty || submitted.compareTo(from) >= 0) &&
        (to.isEmpty || submitted.compareTo(to) <= 0);
  }

  Future<TicketEntity> _toTicket(Map<String, dynamic> json) async {
    final id = json['ticketid']?.toString() ?? '';
    final movements = await _movements(id);
    return TicketEntity(
      uuid: id,
      ticketId: int.tryParse(id),
      submitDate: DateTime.tryParse('${json['submit_date']}'),
      dueDate: DateTime.tryParse('${json['due_date']}'),
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      subject: TicketSubjectEntity(
        id: '',
        code: '',
        name: json['subject']?.toString().trim() ?? '',
        isActive: true,
      ),
      createdByUser: json['created_by']?.toString(),
      partnerName: json['partnername']?.toString(),
      subscriber: json['subscriber']?.toString(),
      assignedToName: json['assignedto']?.toString(),
      movements: movements,
      rating: int.tryParse('${json['feedbackm']}'),
      ratingComment: json['feedbackcomment']?.toString(),
    );
  }

  /// A ticket stays usable in the list if only its comments can't be loaded.
  Future<List<TicketMovementEntity>> _movements(String ticketId) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireTicketCommentsURL,
      (session) => {...session.byUsername, 'ticketid': ticketId},
    );
    return result.fold(
      (_) => const [],
      (data) =>
          (data['comments_list'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()
              .map(_toMovement)
              .toList(),
    );
  }

  TicketMovementEntity _toMovement(Map<String, dynamic> json) {
    final attachment = json['attachment']?.toString() ?? '';
    final extension = attachment.split('.').last.toLowerCase();
    final isImage = _imageExtensions.contains(extension);
    final isVideo = _videoExtensions.contains(extension);
    return TicketMovementEntity(
      id: json['noteid']?.toString() ?? '',
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',
      assignedToName: json['assignedto']?.toString(),
      assignedFromName: json['created_by']?.toString(),
      createdDate: DateTime.tryParse('${json['create_date']}'),
      imageUrl: [if (attachment.isNotEmpty && isImage) attachment],
      videoUrl: [if (attachment.isNotEmpty && isVideo) attachment],
      documentUrl: [
        if (attachment.isNotEmpty && !isImage && !isVideo) attachment,
      ],
    );
  }
}
