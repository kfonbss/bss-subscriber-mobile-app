import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/customer_type_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';

abstract class TicketRepository {
  Future<Either<Failure, List<TicketCategoryEntity>>> getCategories();
  Future<Either<Failure, List<CustomerTypeEntity>>> getCustomerTypes();
  Future<Either<Failure, List<SubjectEntity>>> getSubjects({
    required String categoryId,
  });
  Future<Either<Failure, List<PriorityEntity>>> getPriorities();
  Future<Either<Failure, List<VisibilityEntity>>> getVisibilityPermissions();
  Future<Either<Failure, SubmitTicketRespoEntity>> submitTicket(
      SubmitTicketReq params,
      );
  Future<Either<Failure, TicketsListResponseEntity>> getTickets(
      GetTicketsListParams params,
      );
  Future<Either<Failure, AddNoteRespoEntity>> addNote(AddNoteReq params);
}
