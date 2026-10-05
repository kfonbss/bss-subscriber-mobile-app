import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';
import 'package:kfon_subscriber/core/data/model/file_view_url_result_model.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_respo.dart';
import 'package:kfon_subscriber/features/ticket/data/model/rate_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/customer_type_model.dart';
import 'package:kfon_subscriber/features/ticket/data/model/priority_model.dart';
import 'package:kfon_subscriber/features/ticket/data/model/subject.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_respo.dart';
import 'package:kfon_subscriber/features/ticket/data/model/ticket_category_model.dart';
import 'package:kfon_subscriber/features/ticket/data/model/tickets_list_response_model.dart';
import 'package:kfon_subscriber/features/ticket/data/model/visibility_model.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/customer_type_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class TicketRepositoryImp extends TicketRepository {
  List<String> _extractFileIds(dynamic raw) {
    final ids = <String>{};

    void collectFromMap(Map<String, dynamic> map) {
      final direct = map['fileId'] ?? map['id'];
      if (direct is String && direct.isNotEmpty) ids.add(direct);

      final dynamic listLike = map['fileIds'] ?? map['ids'];
      if (listLike is List) {
        for (final item in listLike) {
          if (item is String && item.isNotEmpty) {
            ids.add(item);
          } else if (item is Map<String, dynamic>) {
            final nested = item['fileId'] ?? item['id'];
            if (nested is String && nested.isNotEmpty) ids.add(nested);
          }
        }
      }

      final nestedData = map['data'];
      if (nestedData is Map<String, dynamic>) collectFromMap(nestedData);
      if (nestedData is List) {
        for (final item in nestedData) {
          if (item is Map<String, dynamic>) collectFromMap(item);
        }
      }
    }

    if (raw is Map<String, dynamic>) collectFromMap(raw);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) collectFromMap(item);
      }
    }

    return ids.toList();
  }

  /// Uploads one file to file storage and returns its file ID.
  Future<Either<Failure, String>> _uploadFile(PlatformFile file) async {
    if (file.path == null) {
      return const Left(ServerFailure('Selected file is not available'));
    }
    final multipartFile = await MultipartFile.fromFile(
      file.path!,
      filename: file.name,
    );
    final APIResponse response = await sl<DioClient>().post(
      ApiUrls.fileUploadURL,
      data: FormData.fromMap({'file': multipartFile}),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (!response.isSuccess) return Left(response.failure);

    final ids = _extractFileIds(response.data);
    if (ids.isEmpty) {
      return const Left(
        ServerFailure('File upload succeeded but no fileId returned'),
      );
    }
    return Right(ids.first);
  }

  @override
  Future<Either<Failure, List<TicketCategoryEntity>>> getCategories() async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.ticketCategoriesURL,
    );
    if (response.isSuccess) {
      final dataList = response.data as List<dynamic>? ?? [];
      final categories =
          dataList
              .map(
                (e) =>
                    TicketCategoryModel.fromJson(
                      e as Map<String, dynamic>,
                    ).toEntity(),
              )
              .where((c) => c.isActive)
              .toList();
      return Right(categories);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, List<CustomerTypeEntity>>> getCustomerTypes() async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.customerTypesURL);
    if (response.isSuccess) {
      final dataList = response.data as List<dynamic>? ?? [];
      final customerTypes =
          dataList
              .map(
                (e) =>
                    CustomerTypeModel.fromJson(
                      e as Map<String, dynamic>,
                    ).toEntity(),
              )
              .where((c) => c.isActive)
              .toList();
      return Right(customerTypes);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, List<SubjectEntity>>> getSubjects({
    required String categoryId,
  }) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.subjectURL,
      queryParameters: {'categoryId': categoryId},
    );
    if (response.isSuccess) {
      final dataList = response.data as List<dynamic>? ?? [];
      final subjects =
          dataList
              .map(
                (e) => Subject.fromJson(e as Map<String, dynamic>).toEntity(),
              )
              .where((s) => s.isActive) // Filter only active subjects
              .toList();
      return Right(subjects);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, List<PriorityEntity>>> getPriorities() async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.prioritiesURL);
    if (response.isSuccess) {
      final dataList = response.data as List<dynamic>? ?? [];
      final priorities =
          dataList
              .map(
                (e) =>
                    PriorityModel.fromJson(
                      e as Map<String, dynamic>,
                    ).toEntity(),
              )
              .where((p) => p.isActive) // Filter only active priorities
              .toList();
      return Right(priorities);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, List<VisibilityEntity>>>
  getVisibilityPermissions() async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.visibilityPermissionURL,
    );
    if (response.isSuccess) {
      final dataList = response.data as List<dynamic>? ?? [];
      final visibilities =
          dataList
              .map(
                (e) =>
                    VisibilityModel.fromJson(
                      e as Map<String, dynamic>,
                    ).toEntity(),
              )
              .where((v) => v.isActive)
              .toList();
      return Right(visibilities);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, SubmitTicketRespoEntity>> submitTicket(
    SubmitTicketReq params,
  ) async {
    // Step 0 (GST and PAN Updation only): upload the two documents first —
    // the create request must carry their file IDs.
    String? gstDocFileId;
    String? panCopyFileId;
    final gstin = params.gstinDetails;
    if (gstin != null) {
      Failure? uploadFailure;
      (await _uploadFile(
        gstin.gstDocFile,
      )).fold((failure) => uploadFailure = failure, (id) => gstDocFileId = id);
      if (uploadFailure != null) return Left(uploadFailure!);

      (await _uploadFile(
        gstin.panCopyFile,
      )).fold((failure) => uploadFailure = failure, (id) => panCopyFileId = id);
      if (uploadFailure != null) return Left(uploadFailure!);
    }

    // Step 1: Create ticket
    APIResponse createResponse = await sl<DioClient>().post(
      ApiUrls.submitTicketURL,
      data: params.toJson(
        gstDocFileId: gstDocFileId,
        panCopyFileId: panCopyFileId,
      ),
    );

    if (!createResponse.isSuccess) {
      return Left(createResponse.failure);
    }

    final model = SubmitTicketRespo.fromJson(
      createResponse.data as Map<String, dynamic>,
    );
    final ticketUuid = model.ticketUuid;

    // Step 2: Upload files if present
    if (params.files != null && params.files!.isNotEmpty) {
      final fileUploadUrl = '${ApiUrls.submitTicketURL}/$ticketUuid/upload';

      for (final file in params.files!) {
        if (file.path != null) {
          final multipartFile = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );

          final uploadResponse = await sl<DioClient>().post(
            fileUploadUrl,
            data: FormData.fromMap({'file': multipartFile}),
            options: Options(contentType: 'multipart/form-data'),
          );

          if (!uploadResponse.isSuccess) {
            return Left(uploadResponse.failure);
          }
        }
      }
    }

    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> rateTicket(RateTicketReq params) async {
    final APIResponse response = await sl<DioClient>().post(
      ApiUrls.rateTicketURL(params.ticketUuid),
      data: params.toJson(),
    );
    return response.isSuccess ? const Right(unit) : Left(response.failure);
  }

  @override
  Future<Either<Failure, TicketsListResponseEntity>> getTickets(
    GetTicketsListParams params,
  ) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.submitTicketURL,
      queryParameters: params.toQueryParams(),
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final model = TicketsListResponseModel.fromJson(data);
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, AddNoteRespoEntity>> addNote(AddNoteReq params) async {
    var fileIds = List<String>.from(params.fileIds);

    if (params.files != null && params.files!.isNotEmpty) {
      final fileUploadUrl =
          '${ApiUrls.submitTicketURL}/${params.ticketUuid}/upload';

      for (final file in params.files!) {
        if (file.path == null) {
          continue;
        }

        final multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );

        final APIResponse uploadResponse = await sl<DioClient>().post(
          fileUploadUrl,
          data: FormData.fromMap({'file': multipartFile}),
          options: Options(contentType: 'multipart/form-data'),
        );

        if (!uploadResponse.isSuccess) {
          return Left(uploadResponse.failure);
        }

        final extracted = _extractFileIds(uploadResponse.data);
        if (extracted.isEmpty) {
          return const Left(
            ServerFailure('File upload succeeded but no fileId returned'),
          );
        }
        fileIds.addAll(extracted);
      }
    }

    APIResponse response = await sl<DioClient>().post(
      '${ApiUrls.addNoteURL}/${params.ticketUuid}',
      data: params.copyWith(fileIds: fileIds).toJson(),
    );
    if (!response.isSuccess) {
      return Left(response.failure);
    }

    final data = response.data as Map<String, dynamic>;
    final model = AddNoteRespo.fromJson(data);

    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, FileViewUrlResult>> getFileViewUrl(
    String fileId,
  ) async {
    try {
      final APIResponse response = await sl<DioClient>().get(
        ApiUrls.fileViewUrlByFileId(fileId),
      );

      if (response.isSuccess) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          return Left(ServerFailure('Invalid response'));
        }
        final inner = data['data'] as Map<String, dynamic>? ?? data;
        final model = FileViewUrlResultModel.fromJson(inner);
        if (model.url.isEmpty) {
          return Left(ServerFailure('File URL not found'));
        }
        return Right(model.toEntity());
      } else {
        return Left(response.failure);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
